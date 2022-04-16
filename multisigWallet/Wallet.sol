pragma solidity 0.7.5;
pragma abicoder v2;
/*
- Anyone should be able to deposit ether into the smart contract
– The contract creator should be able to input (1): the addresses of the owners and (2):  the numbers of approvals required for a transfer, in the constructor. For example, input 3 addresses and set the approval limit to 2. 
– Anyone of the owners should be able to create a transfer request. The creator of the transfer request will specify what amount and to what address the transfer will be made.
– Owners should be able to approve transfer requests.
– When a transfer request has the required approvals, the transfer should be sent. 
*/

contract multiSigWallet{

   address[] public owners;
   uint limit;

   struct transfer{
       uint amount;
       address payable recipient;
       uint approvals;
       bool sent;
       uint id;
   } 

   transfer[] transferRequests;

   event TransferRequestCreated(uint id, uint amount, address initiator, address recipient);
   event ApprovalReceived(uint id, uint approvals, address approver);
   event TransferApproved(uint id);

   mapping(address =>mapping(uint => bool)) approvals;

   //mapping[address][transfer id] => true/false
  //mapping[msg.sender][5] = true;

   modifier onlyOwners(){
     bool isOwner = false;
     for(uint i = 0; i < owners.length; i++){
         if(owners[i] == msg.sender){
             isOwner = true;
         }
       }
       require(isOwner == true);
       _;
   }

   constructor(address[] memory _owners, uint _limit){
          owners = _owners;
          limit = _limit;
   }

 
  function deposit() public payable{}

  function createTransfer(uint _amount,address payable _recipient) public onlyOwners{
    require(address(this).balance >= _amount);
    emit TransferRequestCreated(transferRequests.length, _amount, msg.sender,  _recipient);
    transferRequests.push(
        transfer(_amount,_recipient,0,false,transferRequests.length)
        );

  }

  function approve(uint id) public onlyOwners{
    require(approvals[msg.sender][id] == false);
    require(transferRequests[id].sent == false);

    approvals[msg.sender][id] = true;
    transferRequests[id].approvals++;
    emit ApprovalReceived(id,transferRequests[id].approvals,msg.sender);

    if(transferRequests[id].approvals >= limit){
        transferRequests[id].sent = true;
        transferRequests[id].recipient.transfer(transferRequests[id].amount);
        emit TransferApproved(id);
    }
  }

  function getTransferRequests() public view returns(transfer[] memory){
      return transferRequests;
      }

  function getBalance() public view returns(uint){
      return address(this).balance;
  }

}