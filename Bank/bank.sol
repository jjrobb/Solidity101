pragma solidity 0.7.5;

import "./Destroyable.sol";

interface governmentInterface {
     function addTransaction(address _from, address _to, uint _amount) external;

}

contract Bank is Destroyable {

    governmentInterface governmentInstance = governmentInterface(0xaE036c65C649172b43ef7156b009c6221B596B8b); //create instance of external contract

mapping(address => uint) balance;

event depositMade(uint amount, address depositedTo);
event logTransfer(address addressFrom, address addressTo, uint amount);

function deposit() public payable returns (uint){
    balance[msg.sender] += msg.value;
    emit depositMade(msg.value, msg.sender);
    return balance[msg.sender];
}

function withdraw(uint amount) public returns (uint){
    require(balance[msg.sender] >= amount, "Insufficient Balace");
    msg.sender.transfer(amount);  
    balance[msg.sender] -= amount;
    return balance[msg.sender];
}

function getBalance() public view returns (uint){
    return balance[msg.sender];
}

function transfer(address recipient, uint amount) public{

    require(balance[msg.sender] >= amount, "Insufficient Balace");
    require(msg.sender != recipient, "Don't transfer money to yourself");

    uint previousSenderBalance = balance[msg.sender];

    _transfer(msg.sender, recipient, amount);

    governmentInstance.addTransaction(msg.sender, recipient, amount); //call to an external contract

    assert(balance[msg.sender] == previousSenderBalance - amount);
}

function _transfer(address from, address to, uint amount) private{
    balance[from] -= amount;
    balance[to] + amount;
    emit logTransfer(from, to, amount);
}


}
