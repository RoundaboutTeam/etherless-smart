pragma solidity >=0.4.25 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/EtherlessStorage.sol";
import "../contracts/EtherlessSmart.sol";
import "../contracts/EtherlessEscrow.sol";

contract TestSmart {
  function testInitialId() public {
    EtherlessSmart ethsm = new EtherlessSmart();

    uint256 expected = 0;

    Assert.equal(ethsm.getId(), expected, "Id should be 0 at start");
  }

  /*function testIdAfterRunRequest() public {
    EtherlessSmart ethsm = new EtherlessSmart();

    uint256 expected = 1;
    ethsm.addFunction("testfunc", "signature", 10, "description");

    Assert.equal(1, expected, "Id should be 1 at first increment");
  }*/
}