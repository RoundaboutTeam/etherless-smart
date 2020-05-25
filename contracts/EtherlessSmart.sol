pragma solidity >=0.4.22 <0.7.0;

import "./EtherlessStorage.sol";
import "./EtherlessEscrow.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";

contract EtherlessSmart is Initializable {

  address ownerAddress;
  uint256 contractBalance;
  uint256 requestId;

  EtherlessStorage private ethStorage;
  EtherlessEscrow private escrow;

  //events
  //event run
  event runRequest(string funcname, string param, uint256 indexed id);
  //event response
  event response(string result, uint256 indexed id);

  modifier onlyOwner(address _invokedFrom) {
    require(_invokedFrom == ownerAddress, "You are not the owner of the contract!");
    _;
  }

  //TODO: check for removal of contractBalance
  function initialize (EtherlessStorage _functions) initializer public{
    contractBalance = 0;
    requestId = 0;
    ownerAddress = msg.sender;
    ethStorage = _functions;
    escrow = new EtherlessEscrow();
  }

  //TODO: finish function deploy
  //adds a function to the list
  function addFunction(string memory name, string memory signature, uint256 price, string memory description) public payable {
    require(ethStorage.existsFunction(name) == false, "A function with the same name already exist!");
    ethStorage.insertNewFunction(name, signature, price, description);
  }

  //runFunction -> requests execution of the function
  function runFunction(string memory funcName, string memory param) public payable {
    require(ethStorage.existsFunction(funcName), "The function you're looking for does not exist! :'(");
    uint256 funcPrice = ethStorage.getFuncPrice(funcName);
    address payable funcDev = ethStorage.getFuncDev(funcName);

    require(msg.value >= funcPrice, "Insufficient amount sent! :'(");
    //contractBalance += msg.value;
    getNewId();
    escrow.deposit(msg.sender, funcDev, funcPrice, requestId);
    emit runRequest(funcName, param, requestId);
  }

  //resultFunction -> returns the result of a function execution
  function resultFunction(string memory result, uint256 id) public onlyOwner(ownerAddress){
    escrow.withdraw(escrow.getBeneficiary(id), id);
    emit response(result, id);
  }

  //errorFunction -> returns the failure message of a function execution
  function errorFunction(string memory result, uint256 id) public onlyOwner(ownerAddress){
    escrow.withdraw(escrow.getSender(id), id);
    emit response(result, id);
  }

  function getCost(string memory _funcName) public view returns (uint256){
    return ethStorage.getFuncPrice(_funcName);
  }

  function getInfo(string memory _funcName) public view returns (string memory){
    require(ethStorage.existsFunction(_funcName), "The function you're looking for does not exist! :'(");
    return ethStorage.getFuncInfo(_funcName);
  }

  function getFuncList() public view returns (string memory){
    return ethStorage.getList();
  }

  //getNewId -> increments requestId
  function getNewId() private returns (uint256){
    return requestId++;
  }
}