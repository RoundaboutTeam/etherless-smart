pragma solidity >=0.4.22 <0.7.0;

import "./EtherlessStorage.sol";
import '@openzeppelin/upgrades/contracts/Initializable.sol';

contract EtherlessSmart is Initializable {

  address ownerAddress;
  uint256 contractBalance;
  uint256 requestId;

  EtherlessStorage private ethStorage;

  //events
  //event run
  event runRequest(string funcname, string param, uint256 indexed id);
  //event response
  event response(string result, uint256 indexed id);

  modifier onlyOwner(address _invokedFrom) {
    require(_invokedFrom == ownerAddress, "You are not the owner of the contract!");
    _;
  }

  function initialize (EtherlessStorage _functions, uint256 x) initializer public{
    contractBalance = x;
    requestId = 0;
    ownerAddress = msg.sender;
    ethStorage = _functions;
  }

  //MAIN COMMANDS
  //runFunction -> requests execution of the function
  function runFunction(string memory funcName, string memory param) public payable {
    require(ethStorage.existsFunction(funcName), "The function you're looking for does not exist! :'(");
    uint256 funcPrice = ethStorage.getFuncPrice(funcName);
    address payable funcDev = ethStorage.getFuncDev(funcName);

    require(msg.value >= funcPrice, "Insufficient amount sent! :'(");
    contractBalance += msg.value;

    sendAmount(funcDev, funcPrice);

    getNewId();
    emit runRequest(funcName, param, requestId);
  }

  //resultFunction -> returns the result of a function execution
  function resultFunction(string memory result, uint256 id) public onlyOwner(msg.sender){
    emit response(result, id);
  }

  function getBalance() public view returns (uint256){
    return contractBalance;
 }

 function getFuncList() public view returns (string memory){
   return ethStorage.getList();
 }

  //sendAmount -> sends the given amount to a certain address
 function sendAmount(address payable to, uint256 amount) public {
   contractBalance -= amount; //remainder from payment
   to.transfer(amount);
 }

  //getNewId -> increments requestId
 function getNewId() private returns (uint256){
   return requestId++;
 }

}