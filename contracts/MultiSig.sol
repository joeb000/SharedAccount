contract MultiSig {

  event WithdrawRequested(address _requestor, address _recipient, uint _amount);
  event WithdrawApproved(address _approver, address _recipient, uint _amount);
  event SimpleWithdraw(address _requestor, address _recipient, uint _amount);

  address public creator;
  address public partner;
  uint public period;
  mapping (address => uint) public contributors;
  mapping (address => PendingWithraw) public pendingWithdraws;
  mapping (address => uint) nextWithdrawValidTime;

  struct PendingWithraw {
    address requestor;
    uint amount;
  }

  modifier onlyPartners {
    if (msg.sender == creator || msg.sender == partner)
    _
  }


  function MultiSig(address _partner, uint _period){
    creator = msg.sender;
    partner = _partner;
    period = _period;
  }

  function setPeriod(uint _period) onlyPartners {
      period = _period;
  }

  function setPartner(address _partner) onlyPartners {
      partner = _partner;
  }

  function requestWithdraw(address _recip, uint _amt) onlyPartners {
    pendingWithdraws[_recip].amount = _amt;
    pendingWithdraws[_recip].requestor = msg.sender;
    WithdrawRequested(msg.sender, _recip, _amt);
  }

  function approveWithdraw(address _recip) onlyPartners {
    if (pendingWithdraws[_recip].requestor != msg.sender) {
      if (!_recip.send(pendingWithdraws[_recip].amount)){
        WithdrawApproved(msg.sender,_recip,pendingWithdraws[_recip].amount);
        pendingWithdraws[_recip].amount = 0;
        pendingWithdraws[_recip].requestor = 0x0;
      }
    }
  }

  function simpleWithdraw(address _recip, uint _amt) onlyPartners {
    if (nextWithdrawValidTime[msg.sender] < now){
      if (!_recip.send(_amt)){
        SimpleWithdraw(msg.sender, _recip, _amt);
        nextWithdrawValidTime[msg.sender] = now + period;
      }
    }
  }

  function fund(){
    contributors[msg.sender] += msg.value;
  }

}
