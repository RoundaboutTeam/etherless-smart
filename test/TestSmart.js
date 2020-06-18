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
        assert.equal(exists, expected, 'function exists');
    });

    it('should correctly send request to add a function', async () => {
        const expected = 10;
        const fname = "test_func";
        const receipt = await instance.deployFunction(fname, "sign", "description","hash", {from: pippo, value: 10});
        expectEvent(receipt, 'deployRequest', { funcname: fname, signature: "sign", funchash: "hash", id: new BN(1) });
        const deposit = await instance.getDeposit(1);
        assert.equal(deposit, expected, 'function was not added correctly');
    });

    it('should correctly send request to run a function', async () => {
        const expected = 10;
        const fname = "test_func";
        //mock deployed function
        await storage.insertNewFunction(fname, "sign", 10, pippo, "description", { from: pippo});
        await storage.insertInArray(fname,{ from: pippo});
        const receipt = await instance.runFunction(fname, "10,2", { from: pippo, value: 10 });
        const deposit = await instance.getDeposit(1);
        expectEvent(receipt, 'runRequest', { funcname: fname, param:"10,2", id: new BN(1) });
        assert.equal(deposit, expected, 'function was not run correctly');
    });

    it('should correctly send request to delete a function', async () => {
        const expected = 10;
        const fname = "test_func";
        //mock deployed function
        await storage.insertNewFunction(fname, "sign", 10, pippo, "description", { from: pippo });
        await storage.insertInArray(fname, { from: pippo });
        //const list = await instance.getFuncList();
        const receipt = await instance.deleteFunction(fname, { from: pippo, value: 10 });
        const deposit = await instance.getDeposit(1);
        expectEvent(receipt, 'deleteRequest', { funcname: fname, id: new BN(1) });
        assert.equal(deposit, expected, 'function was not deleted correctly');
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
            instance.runResult("run result message", 1, true, { from: pluto }),
            "You are not the designated address!",
        );
    });

    it('should limit the access to deleteResult', async () => {
        const fname = "test_func";
        await expectRevert(
            instance.deleteResult("delete result message", fname, 1, true, { from: pluto }),
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
