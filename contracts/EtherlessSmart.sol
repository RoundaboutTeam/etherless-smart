pragma solidity >=0.4.22 <0.7.0;

import "./EtherlessStorage.sol";
import "./EtherlessEscrow.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/Initializable.sol";

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
  //[DEPLOY] adds a function to the list
  function addFunction(string memory name, string memory signature, uint256 price, string memory description) public payable {
    require(ethStorage.existsFunction(name) == false, "A function with the same name already exist!");
    ethStorage.insertNewFunction(name, signature, price, msg.sender, description);
  }

  //[RUN] runFunction -> requests execution of the function
  function runFunction(string memory funcName, string memory param) public payable {
    require(ethStorage.existsFunction(funcName), "The function you're looking for does not exist! :'(");
    uint256 funcPrice = ethStorage.getFuncPrice(funcName);
    address payable funcDev = ethStorage.getFuncDev(funcName);

    require(msg.value >= funcPrice, "Insufficient amount sent! :'(");
    //contractBalance += msg.value;
    getNewId();
    escrow.deposit{value: funcPrice}(msg.sender, funcDev, funcPrice, requestId);
    emit runRequest(funcName, param, requestId);
  }

  //resultFunction -> returns the result of a function execution
  function resultFunction(string memory result, uint256 id) public /*onlyOwner(ownerAddress)*/{
    escrow.withdraw(escrow.getBeneficiary(id), id);
    emit response(result, id);
  }

  //errorFunction -> returns the failure message of a function execution
  function errorFunction(string memory result, uint256 id) public /*onlyOwner(ownerAddress)*/{
    escrow.withdraw(escrow.getSender(id), id);
    emit response(result, id);
  }

  //returns the price of a single function
  function getCost(string memory funcName) public view returns (uint256){
    return ethStorage.getFuncPrice(funcName);
  }

  //[INFO] returns the information of a single function
  function getInfo(string memory funcName) public view returns (string memory){
    require(ethStorage.existsFunction(funcName), "The function you're looking for does not exist! :'(");
    return ethStorage.getFuncInfo(funcName);
  }

  //[LIST] returns a list of all the available functions
  function getFuncList() public view returns (string memory){
    return ethStorage.getList();
  }

  //TODO: test if id creation is fixed
  //getNewId -> increments requestId
  function getNewId() private returns (uint256){
    requestId = requestId+1;
    return requestId;
  }
}