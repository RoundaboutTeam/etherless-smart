pragma solidity >=0.4.22 <0.7.0;

import '@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol';
import '@openzeppelin/contracts-ethereum-package/contracts/utils/Address.sol';
import '@openzeppelin/contracts-ethereum-package/contracts/Initializable.sol';

contract EtherlessEscrow is OwnableUpgradeSafe {
    using Address for address payable;

    //do we really need events though?
    //event Deposited(address indexed payee, uint256 weiAmount);
    //event Withdrawn(address indexed payee, uint256 weiAmount);

    struct depositInfo {
        address payable sender;
        address payable beneficiary;
        uint256 amount;
    }

    mapping(uint256 => depositInfo) private deposits;

    function initialize() public initializer {
        OwnableUpgradeSafe.__Ownable_init();
    }

    function getBeneficiary(uint256 index) public view returns (address payable) {
        return deposits[index].beneficiary;
    }

    function getSender(uint256 index) public view returns (address payable) {
        return deposits[index].sender;
    }

    //TODO: maybe return an address??
    function depositsOf(uint256 index) public view returns (uint256) {
        return deposits[index].amount;
    }

    // Stores the given amount with the payee address
    function deposit(address payable sender, address payable beneficiary, uint256 amount, uint256 index) public virtual payable onlyOwner {
        deposits[index] = depositInfo(sender, beneficiary, amount);

        //emit Deposited(payee, amount);
    }

    //Sends the given amount to the payee adress
    function withdraw(address payable payee, uint256 index) public virtual onlyOwner {
        uint256 payment = deposits[index].amount;

        delete deposits[index];

        payee.sendValue(payment);

        //emit Withdrawn(payee, payment);
    }
}