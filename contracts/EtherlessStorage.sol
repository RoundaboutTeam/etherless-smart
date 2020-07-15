pragma solidity >=0.4.22 <0.7.0;

contract EtherlessStorage {

  struct jsFunction {
      string name;
      string signature;
      uint256 price; // wei
      address payable developer;
      string description;
      bool exists;
    }

  mapping (string => jsFunction) private availableFunctions; //check if struct in mapping is set to 0 by default
  string[] functionNames;

  /**
  * @dev checks if the function name is in functionNames
  * @param name: name of the function
  * @return existance of the function
  */
  function existsFunction(string memory name) public view returns (bool) {
    for (uint index = 0; index < functionNames.length; index++) {
        if(compareString(functionNames[index], name)){
            return true;
        }
    }
    return false;
  }

    /**
  * @dev checks if the function name exists in availableFunctions
  * @param name: name of the function
  * @return existance of the function
  */
  function isDeploying(string memory name) public view returns (bool) {
    if(availableFunctions[name].exists){
        return true;
    }
    return false;
  }

  /**
  * @dev adds a function that has just been deployed to the list (availableFunctions)
  * @param name: name of the function
  * @param signature: signature of the function
  * @param price: price of the function
  * @param dev: owner of the function
  * @param description: description of the function
  */
  function insertNewFunction(string memory name, string memory signature, uint256 price, address payable dev, string memory description) public {
      availableFunctions[name] = jsFunction(name, signature, price, dev, description, true);
  }

  /**
  * @dev adds a function that has just been deployed to the array (functionNames)
  * @param name: name of the function
  */
  function insertInArray(string memory name) public {
      functionNames.push(name);
  }

  /**
  * @dev  removes a given function from availableFunctions list
  * @param toRemove: name of the function
  */
  function removeFunction(string memory toRemove) public {
      delete availableFunctions[toRemove];
  }

  /**
  * @dev  removes a given function from availableFunctions list
  * @param name: name of the function
  */
  function removeFromArray(string memory name) public {
    for (uint index = 0; index < functionNames.length; index++) {
      if(compareString(functionNames[index], name)) {
          //delete functionNames[index]; //check if length is correct after deleting an element
          functionNames[index] = functionNames[functionNames.length - 1];
          functionNames.pop();
      }
    }
  }

  /**
  * @dev edits a function's signature
  * @param name: name of the function
  * @param newSignature: signature to update to
  */
  function modifyFunction(string memory name, string memory newSignature) public {
    availableFunctions[name].signature = newSignature;
  }

  /**
  * @dev edits a function's description
  * @param name: name of the function
  * @param newDescription: description to update to
  */
  function modifyFuncDescr(string memory name, string memory newDescription) public returns (bool){
    availableFunctions[name].description = newDescription;
    if(compareString(availableFunctions[name].description, newDescription) == true)
        return true;
    else return false;
  }

  /**
  * @dev returns the function's price
  * @param funcName: name of the function
  * @return price of the function
  */
  function getFuncPrice(string memory funcName) public view returns(uint256){
    uint256 _price = availableFunctions[funcName].price;
    return _price;
  }

  /**
  * @dev returns the function's owner
  * @param funcName: name of the function
  * @return owner of the function
  */
  function getFuncDev(string memory funcName) public view returns(address payable){
    address payable dev = availableFunctions[funcName].developer;
    return dev;
  }


  /**
  * @dev returns the list of functions in this format (all in one line) :
          [{"name":"function name","signature","function signature","price":"price of function"},
          {"name":"function name 2","signature","function signature 2","price":"price of function 2"},...]
  * @return list of functions in the described format
  */
  function getList () public view returns(string memory){
    string memory result;
    for(uint index = 0; index < functionNames.length; index++){
      string memory _name = functionNames[index];
      result = string(abi.encodePacked(result, singleFuncJson(_name, false)));
      if(index != functionNames.length - 1){result = string(abi.encodePacked(result, ","));}
    }
    return string(abi.encodePacked("{\"functionArray\":[",result,"]}"));
  }

  /**
  * @dev returns the list of functions owned by a developer in this format (all in one line) :
          [{"name":"function name","signature","function signature","price":"price of function"},
          {"name":"function name 2","signature","function signature 2","price":"price of function 2"},...]
  * @param dev: owner of whitch to list the fuctions
  * @return list of the owner's functions in the described format
  */
  function getDevList (address payable dev) public view returns(string memory){
    string memory result;
    uint256 count;
    for(uint index = 0; index < functionNames.length; index++){
      string memory _name = functionNames[index];
      if(getFuncDev(_name) == dev){count = count+1;}
    }
    for(uint index = 0; index < functionNames.length && count > 0; index++){
      string memory _name = functionNames[index];
      if(getFuncDev(_name) == dev){
        result = string(abi.encodePacked(result, singleFuncJson(_name, false)));
        if(count != 1){result = string(abi.encodePacked(result, ","));}
        count--;
      }
    }
    return string(abi.encodePacked("{\"functionArray\":[",result,"]}"));
  }
  /**
  * @dev returns all the information of a single function in this format:
          {"name":"function name","signature","function signature",...}
  * @param funcName name of the function
  * @return list of functions in the described format
  */
  function getFuncInfo (string memory funcName) public view returns(string memory){
    return singleFuncJson(funcName, true);
  }

  /**
  * @dev returns the information of a single function in this format:
          {"name":"function name","signature","function signature",...}
          when info is false --> containing only name, signature and price
          when info is true --> adding description and developer
  * @param funcName name of the function
  * @return list of functions in the described format
  */
  function singleFuncJson (string memory funcName, bool info) private view returns(string memory){
    string memory result;
    string memory price = uintToString((availableFunctions[funcName].price));
    string memory sign = availableFunctions[funcName].signature;
    result = string(abi.encodePacked("{\"name\":","\"",funcName,"\",","\"signature\":","\"",sign,"\",","\"price\":","\"",price,"\""));
    if(info){
      string memory desc = availableFunctions[funcName].description;
      string memory dev = addressToString(availableFunctions[funcName].developer);
      result = string(abi.encodePacked(result,",","\"description\":","\"",desc,"\",","\"developer\":","\"",dev,"\""));
    }
    result = string(abi.encodePacked(result,"}"));
    return result;
  }

  /**
  * @dev converts address into string
  * @param addr address to convert
  * @return string containing the converted address
  */
  function addressToString(address addr) private pure returns(string memory) {
    bytes32 value = bytes32(uint256(addr));
    bytes memory alphabet = "0123456789abcdef";
    bytes memory str = new bytes(42);
    str[0] = '0';
    str[1] = 'x';
    for (uint i = 0; i < 20; i++) {
      str[2+i*2] = alphabet[uint(uint8(value[i + 12] >> 4))];
      str[3+i*2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
    }
    return string(str);
  }

  /**
  * @dev converts uint256 into string
  * @param x uint256 to convert
  */
  function uintToString(uint256 x) private pure returns (string memory _uintAsString) {
    uint256 _i = x;
    if (_i == 0) {return "0";}
    uint256 j = _i;
    uint256 len;
    while (j != 0) {len++; j /= 10;}
    bytes memory bstr = new bytes(len);
    uint256 k = len - 1;
    while (_i != 0) {bstr[k--] = bytes1(uint8(48 + (_i % 10))); _i /= 10;}
    return string(bstr);
  }

  /**
  * @dev checks if two strings are equal (case sensitive)
  * @param s1 first string
  * @param s2 second string
  * @return if the two string are equal
  */
  function compareString(string memory s1, string memory s2) private pure returns (bool) {
    if(bytes(s1).length != bytes(s2).length) {
      return false;
    } else {
      return (keccak256(abi.encodePacked((s1))) == keccak256(abi.encodePacked((s2))));
    }
  }
}
