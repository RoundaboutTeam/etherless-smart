pragma solidity >=0.4.22 <0.7.0;

contract EtherlessStorage {

struct jsFunction {
    string name;
    //maybe add function signature!
    uint256 price; // wei
    address payable developer;
    bool exists;
  }

  mapping (string => jsFunction) public availableFunctions; //check if struct in mapping is set to 0 by default
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
function addFunction(string memory name, uint256 price) public {
    address payable developer = msg.sender;
    availableFunctions[name] = jsFunction(name, price, developer, true);
    functionNames.push(name);
}

//removeFunction -> removes a given function from availableFunctions list
    function removeFunction(string memory toRemove) public {
        delete availableFunctions[toRemove];
        for (uint index = 0; index < functionNames.length; index++) {
            if(keccak256(abi.encodePacked(functionNames[index])) == keccak256(abi.encodePacked(toRemove))){
                //delete functionNames[index]; //check if length is correct after deleting an element
                functionNames[index] = functionNames[functionNames.length - 1];
                functionNames.pop();
            }
        }
    }

    //returns the function price
    function getFuncPrice(string memory _funcName) public view returns(uint256){
        uint256 _price = availableFunctions[_funcName].price;
        return _price;
    }

    //returns the function price
    function getFuncDev(string memory _funcName) public view returns(address payable){
        address payable _dev = availableFunctions[_funcName].developer;
        return _dev;
    }

    //returns the list of functions in this format (all in one line) :
    /*
    {
        [
        {"name":"function name","price":"price of function","developer","developer address"},
        {"name":"function name 2","price":"price of function 2","developer","developer address"},
        ...
        ]
    }
    */
    function getList () public view returns(string memory){
        string memory result;
        for(uint index = 0; index < functionNames.length; index++){
            string memory _name = functionNames[index];
            string memory nome1 = availableFunctions[_name].name;
            string memory price1 = uint2str(availableFunctions[_name].price);
            string memory dev1 = addressToString(availableFunctions[_name].developer);

            if(index != functionNames.length - 1){
                result = string(abi.encodePacked(result, concat(nome1, price1, dev1), ","));
            }else{
                result = string(abi.encodePacked(result, concat(nome1, price1, dev1)));
            }
        }
        result = string(abi.encodePacked("{[",result,"]}"));
        return result;
    }


    //funzioni "interne" allo smart contract
    function concat(string memory s1, string memory s2, string memory s3) private pure returns (string memory) {
        string memory _s1 = string(abi.encodePacked("\"name\"",":","\"",s1,"\""));
        string memory _s2 = string(abi.encodePacked("\"price\"",":","\"",s2,"\""));
        string memory _s3 = string(abi.encodePacked("\"developer\"",":","\"",s3,"\""));
        string memory result = string(abi.encodePacked("{",_s1,",",_s2,",",_s3,"}"));
        return result;
    }

    function addressToString(address _addr) public pure returns(string memory) {
        bytes32 value = bytes32(uint256(_addr));
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

    function uint2str(uint256 _x) public pure returns (string memory _uintAsString) {
        uint256 _i = _x;
        if (_i == 0) {return "0";}
        uint256 j = _i;
        uint256 len;
        while (j != 0) {len++; j /= 10;}
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {bstr[k--] = bytes1(uint8(48 + (_i % 10))); _i /= 10;}
        return string(bstr);
    }
}