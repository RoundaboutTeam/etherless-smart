pragma solidity >=0.4.22 <0.7.0;

import '@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol';
import '@openzeppelin/contracts-ethereum-package/contracts/utils/Address.sol';
import '@openzeppelin/contracts-ethereum-package/contracts/Initializable.sol';

contract EtherlessEscrow is OwnableUpgradeSafe {
  using Address for address payable;

  //structure of a payment's information
  struct depositInfo {
    address payable sender;
    address payable beneficiary;
    uint256 amount;
  }

  mapping(uint256 => depositInfo) private deposits;

  /**
  *@dev contract inizialization, sets EtherlessEscrow's owner
  */
  function initialize() public initializer {
    OwnableUpgradeSafe.__Ownable_init();
  }

  /**
  *@dev returns a payment's baenficiary
  *@param index: unique identifier of the payment
  *@returns beneficiary's address
  */
  function getBeneficiary(uint256 index) public view returns (address payable) {
    return deposits[index].beneficiary;
  }

  /**
  *@dev returns a payment's sender
  *@param index: unique identifier of the payment
  *@returns sender's address
  */
  function getSender(uint256 index) public view returns (address payable) {
    return deposits[index].sender;
  }

  /**
  *@dev returns a payment's amount
  *@param index: unique identifier of the payment
  *@returns the payment amount
  */
  function depositsOf(uint256 index) public view returns (uint256) {
    return deposits[index].amount;
  }

  /**
  *@dev Stores the given amount of the payment with the beneficiary and sender addresses and the unique identifier
  *@param sender: address of the payment sender
  *@param beneficiary: address of the payment beneficiary
  *@param amount: payment amount
  *@param index: unique identifier of the payment
  */
  function deposit(address payable sender, address payable beneficiary, uint256 amount, uint256 index) public virtual payable onlyOwner {
    deposits[index] = depositInfo(sender, beneficiary, amount);
  }

  //Sends the given amount to the payee adress
  /**
  *@dev resolves a payment, sending the amount to the explicited payee
  *@param payee: beneficiary of the payment
  *@param index: unique identifier of the payment
  */
  function withdraw(address payable payee, uint256 index) public virtual onlyOwner {
    uint256 payment = deposits[index].amount;
    delete deposits[index];
    payee.sendValue(payment);
  }
}
