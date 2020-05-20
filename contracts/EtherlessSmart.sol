pragma solidity >=0.4.22 <0.7.0;

import './EtherlessStorage.sol';
import '@openzeppelin/upgrades/contracts/Initializable.sol';

contract EtherlessSmart is Initializable {

  address ownerAddress;
  uint256 contractBalance;
  uint256 requestId;

  EtherlessStorage private functions;

  //events
  //event run
  event runRequest(string funcname, string param, uint256 indexed id);
  //event response
  event response(string result, uint256 indexed id);

  modifier onlyOwner(address _invokedFrom) {
    require(_invokedFrom == ownerAddress, "You are not the owner of the contract!");
    _;
  }

  function initialize () public initializer {
    contractBalance = 0;
    requestId = 0;
    ownerAddress = msg.sender;
  }

  //MAIN COMMANDS
  //runFunction -> requests execution of the function
  function runFunction(string memory funcName, string memory param) public payable {
    require(functions.existsFunction(funcName), "The function you're looking for does not exist! :'(");
    uint256 funcPrice = functions.availableFunctions[funcName].price;
    address payable funcDev = functions.availableFunctions[funcName].developer;

    require(msg.value >= funcPrice, "Insufficient amount sent! :'(");
    balance += msg.value;

    sendAmount(funcDev, funcPrice);

    getNewId();
    emit runRequest(funcName, param, requestId);
  }

  //resultFunction -> returns the result of a function execution
  function resultFunction(string memory result, uint256 id) public onlyOwner(msg.sender){
    emit response(result, id);
  }

  function getBalance() public view returns (uint256){
    return balance;
 }

  //sendAmount -> sends the given amount to a certain address
 function sendAmount(address payable to, uint256 amount) public {
   balance -= amount; //remainder from payment
   to.transfer(amount);
 }

  //getNewId -> increments requestId
 function getNewId() private returns (uint256){
   return requestId++;
 }

}
/*pragma solidity >=0.4.22 <0.7.0;

import './EtherlessStorage.sol';

//TO DO//
//getFuncInfo -> returns all the info stored in the mapping
//deployFunction -> deployes the user developed function
//deleteFunction -> delete one of the caller's owned functions in AWS

contract EtherlessSmart {
  address ownerAddress;
  uint256 balance = 0;
  uint256 requestId; //incremented at every run request

  EtherlessStorage private functions;

  //events
  //event run
  event runRequest(string funcname, string param, uint256 indexed id);
  //event response
  event response(string result, uint256 indexed id);

  constructor() public {
    ownerAddress = msg.sender;
    requestId = 0;
  }

  modifier onlyOwner(address _invokedFrom) {
    require(_invokedFrom == ownerAddress, "You are not the owner of the contract!");
    _;
  }

//MAIN COMMANDS
  //runFunction -> requests execution of the function
  function runFunction(string memory funcName, string memory param) public payable {
    require(functions.existsFunction(funcName), "The function you're looking for does not exist! :'(");
    uint256 funcPrice = functions.availableFunctions[funcName].price;
    address payable funcDev = functions.availableFunctions[funcName].developer;

    require(msg.value >= funcPrice, "Insufficient amount sent! :'(");
    balance += msg.value;

    sendAmount(funcDev, funcPrice);

    getNewId();
    emit runRequest(funcName, param, requestId);
  }

  //resultFunction -> returns the result of a function execution
  function resultFunction(string memory result, uint256 id) public onlyOwner(msg.sender){
    emit response(result, id);
  }

  function getBalance() public view returns (uint256){
    return balance;
 }

  //sendAmount -> sends the given amount to a certain address
 function sendAmount(address payable to, uint256 amount) public {
   balance -= amount; //remainder from payment
   to.transfer(amount);
 }

  //getNewId -> increments requestId
 function getNewId() private returns (uint256){
   return requestId++;
 }
}*/
