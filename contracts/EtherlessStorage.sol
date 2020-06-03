pragma solidity >=0.4.22 <0.7.0;

contract EtherlessStorage {

struct jsFunction {
    string name;
    string signature;
    //maybe add function signature!
    uint256 price; // wei
    address payable developer;
    string description;
    bool exists;
  }

  mapping (string => jsFunction) private availableFunctions; //check if struct in mapping is set to 0 by default
  string[] functionNames;

  //FUNCTIONS THAT IMPLEMENT OPERATIONS ON THE AVAILABLEFUNCTIONS LIST
  //existsFunction -> checks if a certain function is in the availableFunctions list
  function existsFunction(string memory name) public view returns (bool) {
    if(availableFunctions[name].exists) {
        return true;
    } else {
        return false;
    }
  }

  //addFunction -> adds a function that has just been deployed to the list
function insertNewFunction(string memory name, string memory signature, uint256 price, address payable dev, string memory description) public {
    availableFunctions[name] = jsFunction(name, signature, price, dev, description, true);
    functionNames.push(name);
}

//removeFunction -> removes a given function from availableFunctions list
    function removeFunction(string memory toRemove) public {
        delete availableFunctions[toRemove];
        for (uint index = 0; index < functionNames.length; index++) {
            if(compareString(functionNames[index], toRemove)) {
                //delete functionNames[index]; //check if length is correct after deleting an element
                functionNames[index] = functionNames[functionNames.length - 1];
                functionNames.pop();
            }
        }
    }

    //returns the function price
    function getFuncPrice(string memory funcName) public view returns(uint256){
        uint256 _price = availableFunctions[funcName].price;
        return _price;
    }

    //returns the function developer
    function getFuncDev(string memory funcName) public view returns(address payable){
        address payable dev = availableFunctions[funcName].developer;
        return dev;
    }

    //returns the list of functions in this format (all in one line) :
    /*[{"name":"function name","price":"price of function","developer","developer address"},
        {"name":"function name 2","price":"price of function 2","developer","developer address"},...]*/
    function getList () public view returns(string memory){
        string memory result;
        for(uint index = 0; index < functionNames.length; index++){
            string memory _name = functionNames[index];
            result = string(abi.encodePacked(result, singleFuncJson(_name, false)));
            if(index != functionNames.length - 1){result = string(abi.encodePacked(result, ","));}
        }
        return string(abi.encodePacked("{\"functionArray\":[",result,"]}"));
    }

    //returns the information of a single function
    function getFuncInfo (string memory funcName) public view returns(string memory){
        return singleFuncJson(funcName, true);
    }

    //formats the information of a single object
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

    function compareString(string memory s1, string memory s2) private pure returns (bool) {
        if(bytes(s1).length != bytes(s2).length) {
            return false;
        } else {
            return (keccak256(abi.encodePacked((s1))) == keccak256(abi.encodePacked((s2))));
        }
    }
}