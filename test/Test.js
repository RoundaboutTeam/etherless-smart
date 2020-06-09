const {
    BN,           // Big Number support
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');

const EtherlessSmart = artifacts.require('EtherlessSmart');
const EtherlessStorage = artifacts.require('EtherlessStorage');
const EtherlessEscrow = artifacts.require('EtherlessEscrow');

contract('EtherlessSmart', (accounts) => {
    const [pippo, pluto] = accounts;
    let instance
    let storage
    beforeEach(async function setup() {
        instance = await EtherlessSmart.new();
        storage = await EtherlessStorage.new();
        await instance.initialize(storage.address, pippo, 10);
    });

    it('at start, list should be empty', async () => {
        const expected = "{\"functionArray\":[]}";
        const id = await instance.getId();
        const list = await instance.getFuncList();
        assert.equal(list, expected, 'list is not empty');
    });
    it('func should not exist', async () => {
        const fname = "test_func";
        const expected = false;
        const exists = await storage.existsFunction(fname);
        assert.equal(exists, expected, 'list is not empty');
    });

    it('should correctly add a function', async () => {
        const expected = true;
        const fname = "test_func";
        await instance.deployFunction(fname, "sign", "description","hash", {from: pippo, value: 10});
        const deposit = await instance.getDeposit(1);
        //console.log(deposit);
        const list = await instance.getFuncList();
        const exists = await storage.existsFunction(fname);
        //console.log(exists);
        //await instance.deployResult("deployed", fname, 1, true,{from: pippo, value: 10});
        assert.equal(exists, expected, 'function was not added correctly');
    });

    it('should correctly run a function', async () => {
        const expected = true;
        const expected2 = 10;
        const fname = "test_func";
        await instance.deployFunction(fname, "sign", "description", "hash", { from: pippo, value: 10});
        //const list = await instance.getFuncList();
        const exists = await storage.existsFunction(fname);
        await instance.runFunction(fname, "10,2", { from: pippo, value: 10 });
        const deposit = await instance.getDeposit(1);
        //console.log(deposit);
        assert.equal(exists, expected, 'function was not added correctly');
        assert.equal(deposit, expected2, 'function was not run correctly');
    });

    it('should limit the access to deployResult', async () => {
        const fname = "test_func";
        await expectRevert(
            instance.deployResult("deploy result message", fname, 1, true, { from: pluto }),
            "You are not the designated address!",
        );
    });

    it('should limit the access to runResult', async () => {
        const fname = "test_func";
        await expectRevert(
            instance.runResult("deploy result message", 1, true, { from: pluto }),
            "You are not the designated address!",
        );
    });

    it('should emit the event for succesful runResult', async () => {
        const expected = true;
        const fname = "test_func";
        //await instance.deployFunction(fname, "sign", "description", "hash", { from: pluto, value: 10 });
        const receipt = await instance.runResult("success message", 1, true,{ from: pippo});
        expectEvent(receipt, 'resultOk', { result: "success message", id: new BN(1) });
    });

    it('should emit the event for succesful deployResult', async () => {
        const expected = true;
        const fname = "test_func";
        //await instance.deployFunction(fname, "sign", "description", "hash", { from: pluto, value: 10 });
        const receipt = await instance.deployResult("success message", fname, 1, true,{ from: pippo});
        expectEvent(receipt, 'resultOk', { result: "success message", id: new BN(1) });
    });

    it('should emit the event for unsuccesful runResult', async () => {
        const expected = true;
        const fname = "test_func";
        //await instance.deployFunction(fname, "sign", "description", "hash", { from: pluto, value: 10 });
        const receipt = await instance.runResult("error message", 1, false,{ from: pippo});
        expectEvent(receipt, 'resultError', { result: "error message", id: new BN(1) });
    });

    it('should emit the event for unsuccesful deployResult', async () => {
        const expected = true;
        const fname = "test_func";
        //await instance.deployFunction(fname, "sign", "description", "hash", { from: pluto, value: 10 });
        const receipt = await instance.deployResult("error message", fname, 1, false,{ from: pippo});
        expectEvent(receipt, 'resultError', { result: "error message", id: new BN(1) });
    });
});
