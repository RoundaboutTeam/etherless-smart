pragma solidity >=0.4.22 <0.7.0;

import "./EtherlessStorage.sol";
import "./EtherlessEscrow.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/Initializable.sol";

contract EtherlessSmart is Initializable {
  /**
  * @title main Etherless contract
  * @author Roundabout team
  */

  address payable ownerAddress;
  address serverAddress;
  uint256 contractBalance;
  uint256 requestId;
  uint256 fprice;

  EtherlessStorage private ethStorage;
  EtherlessEscrow private escrow;

  //events
  event deployRequest(string funcname, string signature, string funchash, uint256 indexed id);
  event runRequest(string funcname, string param, address indexed addr, uint256 indexed id);
  event deleteRequest(string funcname, uint256 indexed id);
  event editRequest(string name, string signature, string funcHash, uint256 indexed requestId);
  event resultOk(string result, uint256 indexed id);
  event resultError(string result, uint256 indexed id);

  modifier onlyServer(address invokedFrom) {
    require(invokedFrom == serverAddress, "You are not the designated address!");
    _;
  }

  //TODO: check for removal of contractBalance
  /**
  * @dev EtherlessSmart contract initializer function
  */
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

  //[DEPLOY] adds a function to the list
  /**
  * @dev forwards the deployment request for a function, emits deployRequest event
  * @param name: name of the function to deploy
  * @param signature: should contain the signature of the function
  * @param description: should contain the description of the function
  * @param funchash: should contain the IPFS hash of the function code
  */
  function deployFunction(string memory name, string memory signature, string memory description, string memory funchash) public payable {
    require(ethStorage.existsFunction(name) == false, "A function with the same name already exist!");
    require(msg.value >= fprice, "Insufficient amount sent! :(");

    getNewId();
    escrow.deposit{value: fprice}(msg.sender, ownerAddress, fprice, requestId);
    ethStorage.insertNewFunction(name, signature, fprice, msg.sender, description);
    
    deployRequest(name, signature, funchash, requestId);
  }

  //[RUN] runFunction -> requests execution of the function
  /**
  * @dev forwards the run request for a specified function, emits runRequest event
  * @param funcName: name of the function to run
  * @param param: parameters passed to the function
  */
  function runFunction(string memory funcName, string memory param) public payable {
    require(ethStorage.existsFunction(funcName), "The function you're looking for does not exist! :'(");
    uint256 funcPrice = ethStorage.getFuncPrice(funcName);
    address payable funcDev = ethStorage.getFuncDev(funcName);

    require(msg.value >= funcPrice, "Insufficient amount sent! :'(");
    //contractBalance += msg.value;
    getNewId();
    escrow.deposit{value: funcPrice}(msg.sender, funcDev, funcPrice, requestId);
    emit runRequest(funcName, param, msg.sender, requestId);
  }

  // [DELETE] deleteFunction -> requests the deletion of a function
  /**
  * @dev forwards the deletion request for a specified function, emits deleteRequest event
  * @param name: name of the function to delete
  */
  function deleteFunction(string memory name) public payable {
    require(ethStorage.existsFunction(name) == true, "The function you're looking for does not exist! :'(");
    require(msg.value >= fprice, "Insufficient amount sent! :(");
    require(ethStorage.getFuncDev(name) == msg.sender, "You are not the owner of the function!");

    getNewId();
    escrow.deposit{value: fprice}(msg.sender, ownerAddress, fprice, requestId);
    emit deleteRequest(name, requestId);
  }

  //[EDIT] editFunction -> requests modification of the function
  /**
  * @dev forwards the modification request for a specified function, emits editRequest event
  * @param name: name of the function to modify
  * @param signature: signature of the function to be modified
  * @param funchash: should contain the IPFS hash of the function code
  */
  function editFunction(string memory name, string memory signature, string memory funcHash) public payable {
    require(ethStorage.existsFunction(name) == true, "The function you're looking for does not exist! :'(");
    require(msg.value >= fprice, "Insufficient amount sent! :(");
    require(msg.sender == ethStorage.getFuncDev(name), "You are not the owner of the function!");

    getNewId();
    escrow.deposit{value: fprice}(msg.sender, ownerAddress, fprice, requestId);
    emit editRequest(name, signature, funcHash, requestId);
  }

  //[EDIT] editFuncDescr -> requests modification of the function's description
  /**
  * @dev forwards the modification request for a specified function's description, emits either resultOk or resultError event
  * @param name: name of the function to be modified
  * @param descr: should contain the new description
  */
  function editFunctionDescr(string memory name, string memory descr) public payable {
    require(ethStorage.existsFunction(name) == true, "The function you're looking for does not exist! :'(");
    require(msg.value >= fprice, "Insufficient amount sent! :(");
    require(msg.sender == ethStorage.getFuncDev(name), "You are not the owner of the function!");

    getNewId();
    escrow.deposit{value: fprice}(msg.sender, ownerAddress, fprice, requestId);
    bool modified = ethStorage.modifyFuncDescr(name, descr);
    if(modified == true)
      emit resultOk("The function's description has been successfully modified!", requestId);
    else
      emit resultError("The function's description couldn't be modified :(", requestId);
  }

  /**
  * @dev forwards the deployment result, only callable from 
  *     "Etherless" server address, emits deployOk or 
  *      deployError events based on the parameter "succesful"
  * @param message: result message string
  * @param name: name of the deployment function
  * @param id: id of the deployment request
  * @param successful: indicates the success or failure of the respective deployment request
  */
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

  /**
  * @dev forwards the run result, only callable from 
  *     "Etherless" server address, emits runOk or 
  *      runError events based on the parameter "succesful"
  * @param message: result message string
  * @param id: id of the run request
  * @param successful: indicates the success or failure of the respective run request
  */
  function runResult(string memory message, uint256 id, bool successful) public onlyServer(msg.sender) {
     if(successful == true) {
      escrow.withdraw(escrow.getBeneficiary(id), id);
      emit resultOk(message, id);
    } else {
      escrow.withdraw(escrow.getSender(id), id);
      emit resultError(message, id);
    }
  }
  
  /**
  * @dev forwards the delete result, only callable from 
  *     "Etherless" server address, emits resultOk or 
  *      resultError events based on the parameter "succesful"
  * @param message: result message string
  * @param name: name of the function to be deleted
  * @param id: id of the run request
  * @param successful: indicates the success or failure of the respective delete request
  */
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

  /**
  * @dev forwards the edit result, only callable from 
  *     "Etherless" server address, emits resultOk or 
  *      reultError events based on the parameter "succesful"
  * @param message: result message string
  * @param name: name of the function to be modified
  * @param id: id of the run request
  * @param successful: indicates the success or failure of the respective edit request
  */
  function editResult(string memory message, string memory name, string memory signature, uint256 id, bool successful) public onlyServer(msg.sender) {
    if(successful == true) {
      escrow.withdraw(escrow.getBeneficiary(id), id);
      ethStorage.modifyFunction(name, signature);
      emit resultOk(message, id);
    } else {
      escrow.withdraw(escrow.getSender(id), id);
      emit resultError(message, id);
    }
  }

  /**
  * @dev returns the excecution cost for a specified function
  * @param funcName: name of the function
  * @return specified function's cost
  */
  function getCost(string memory funcName) public view returns (uint256){
    return ethStorage.getFuncPrice(funcName);
  }

  /**
  * @dev returns the full information of a single function
  * @param funcName: name of the function
  * @return json formatted string containing the function's info
  */
  function getInfo(string memory funcName) public view returns (string memory){
    require(ethStorage.existsFunction(funcName), "The function you're looking for does not exist! :'(");
    return ethStorage.getFuncInfo(funcName);
  }

  /**
  * @dev returns a list of all the available functions
  * @return json formatted string containing the function list
  */
  function getFuncList() public view returns (string memory){
    return ethStorage.getList();
  }
  
  /**
  * @dev returns a list of all the available functions, of a specific owner
  * @param dev: address of the owner to return the list of
  * @return json formatted string containing the developer's function list
  */
  function getOwnedList(address payable dev) public view returns (string memory){
    return ethStorage.getDevList(dev);
  }

  /**
  * @dev increments the request id by 1
  * @return incremented request id
  */
  function getNewId() private returns (uint256){
    requestId = requestId+1;
    return requestId;
  }

  /**
  * @dev returns the deposited ether of a specific request id
  * @param id: request id
  * @return deposit of the specified request id
  */
  function getDeposit(uint256 id) public view returns (uint256){
    return escrow.depositsOf(id);
  }

  /**
  * @dev returns the current request id
  * @return current request id
  */
  function getId() public view returns (uint256){
    return requestId;
  }

  fallback() external payable {}
  receive() external payable {
    contractBalance = msg.value;
  }
}