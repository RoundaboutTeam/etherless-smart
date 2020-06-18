pragma solidity >=0.4.22 <0.7.0;

import "./EtherlessStorage.sol";
import "./EtherlessEscrow.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/Initializable.sol";

contract EtherlessSmart is Initializable {

  address payable ownerAddress;
  address serverAddress;
  uint256 contractBalance;
  uint256 requestId;
  uint256 fprice;

  EtherlessStorage private ethStorage;
  EtherlessEscrow private escrow;

  //events
  event deployRequest(string funcname, string signature, string funchash, uint256 indexed id);
  event runRequest(string funcname, string param, uint256 indexed id);
  event deleteRequest(string funcname, uint256 indexed id);
  event resultOk(string result, uint256 indexed id);
  event resultError(string result, uint256 indexed id);

  modifier onlyServer(address invokedFrom) {
    require(invokedFrom == serverAddress, "You are not the designated address!");
    _;
  }

  //TODO: check for removal of contractBalance
  function initialize (EtherlessStorage functions, address serverAddr, uint256 price) initializer public {
    ownerAddress = payable(address(this));
    serverAddress = serverAddr;
    contractBalance = 0;
    requestId = 0;
    fprice = price;
    ethStorage = functions;
    escrow = new EtherlessEscrow();
    escrow.initialize();
  }

  //TODO: finish function deploy
  //[DEPLOY] adds a function to the list
  function deployFunction(string memory name, string memory signature, string memory description, string memory funchash) public payable {
    require(ethStorage.existsFunction(name) == false, "A function with the same name already exist!");
    require(msg.value >= fprice, "Insufficient amount sent! :(");

    getNewId();
    escrow.deposit{value: fprice}(msg.sender, ownerAddress, fprice, requestId);
    ethStorage.insertNewFunction(name, signature, fprice, msg.sender, description);
    
    deployRequest(name, signature, funchash, requestId);
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

  function deleteFunction(string memory name) public payable {
    require(ethStorage.existsFunction(name) == true, "The function you're looking for does not exist! :'(");
    require(msg.value >= fprice, "Insufficient amount sent! :(");
    //require(getFuncDev(name) == msg.sender, "You are not the owner of the function! :(");

    getNewId();
    escrow.deposit{value: fprice}(msg.sender, ownerAddress, fprice, requestId);
    emit deleteRequest(name, requestId);
  }

  function deployResult(string memory message, string memory name, uint256 id, bool successful) public onlyServer(msg.sender) {
    if(successful == true) {
      escrow.withdraw(escrow.getBeneficiary(id), id);
      ethStorage.insertInArray(name);
      emit resultOk(message, id);
    } else {
      escrow.withdraw(escrow.getSender(id), id);
      ethStorage.removeFunction(name);
      emit resultError(message, id);
    }
  }

  function runResult(string memory message, uint256 id, bool successful) public onlyServer(msg.sender) {
     if(successful == true) {
      escrow.withdraw(escrow.getBeneficiary(id), id);
      emit resultOk(message, id);
    } else {
      escrow.withdraw(escrow.getSender(id), id);
      emit resultError(message, id);
    }
  }

  function deleteResult(string memory message, string memory name, uint256 id, bool successful) public onlyServer(msg.sender) {
    if(successful == true) {
      escrow.withdraw(escrow.getBeneficiary(id), id);
      ethStorage.removeFunction(name);
      ethStorage.removeFromArray(name);
      emit resultOk(message, id);
    } else {
      escrow.withdraw(escrow.getSender(id), id);
      emit resultError(message, id);
    }
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
  //[LIST] returns a list of all the available functions
  function getOwnedList(address payable dev) public view returns (string memory){
    return ethStorage.getDevList(dev);
  }

  //TODO: test if id creation is fixed
  //getNewId -> increments requestId
  function getNewId() private returns (uint256){
    requestId = requestId+1;
    return requestId;
  }

  function getDeposit(uint256 id) public view returns (uint256){
    return escrow.depositsOf(id);
  }

  function getId() public view returns (uint256){
    return requestId;
  }

  fallback() external payable {}
  receive() external payable {
    contractBalance = msg.value;
  }
}