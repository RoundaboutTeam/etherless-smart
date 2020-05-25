pragma solidity >=0.4.22 <0.7.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract EtherlessEscrow is Ownable {
    using Address for address payable;

    //do we really need events though?
    //event Deposited(address indexed payee, uint256 weiAmount);
    //event Withdrawn(address indexed payee, uint256 weiAmount);

    struct depositInfo {
        address payable _sender;
        address payable _beneficiary;
        uint256 _amount;
    }

    mapping(uint256 => depositInfo) private _deposits;

    function getBeneficiary(uint256 index) public view returns (address payable) {
        return _deposits[index]._beneficiary;
    }

    function getSender(uint256 index) public view returns (address payable) {
        return _deposits[index]._sender;
    }

    //TODO: maybe return an address??
    function depositsOf(uint256 index) public view returns (uint256) {
        return _deposits[index];
    }

    // Stores the given amount with the payee address
    function deposit(address sender, address beneficiary, uint256 amount, uint256 index) public virtual payable onlyOwner {
        _deposits[index] = depositInfo(sender, beneficiary, amount);

        //emit Deposited(payee, amount);
    }

    //Sends the given amount to the payee adress
    function withdraw(address payable payee, uint256 index) public virtual onlyOwner {
        uint256 payment = _deposits[index]._amount;

        _deposits[index] = 0;

        payee.sendValue(payment);

        //emit Withdrawn(payee, payment);
    }
}