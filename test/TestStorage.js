const {
    BN,           // Big Number support
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');

const EtherlessSmart = artifacts.require('EtherlessSmart');
const EtherlessStorage = artifacts.require('EtherlessStorage');
const EtherlessEscrow = artifacts.require('EtherlessEscrow');

contract('EtherlessStorage', (accounts) => {
    const [pippo, pluto] = accounts;
    let instance
    let storage
    beforeEach(async function setup() {
        //instance = await EtherlessSmart.new();
        storage = await EtherlessStorage.new();
        //await instance.initialize(storage.address, pippo, 10);
    });

    it('function should not exist', async () => {
        const fname = "test_func";
        const expected = false;
        const exists = await storage.existsFunction(fname);
        assert.equal(exists, expected, 'function exists');
    });

    it('should make a function available', async () => {
        const fname = "test_func";
        const expected = true;
        await storage.insertNewFunction(fname,"signature", 15, pippo,"description");
        await storage.insertInArray(fname);
        const exists = await storage.existsFunction(fname);
        assert.equal(exists, expected, 'function does not exists');
    });

    it('should remove a function', async () => {
        const fname = "test_func";
        const expected = false;
        const add_expc = true;
        await storage.insertNewFunction(fname, "signature", 15, pippo, "description");
        await storage.insertInArray(fname);
        const add_exists = await storage.existsFunction(fname);
        assert.equal(add_exists, add_expc, 'function not added');

        await storage.removeFunction(fname);
        await storage.removeFromArray(fname);
        const exists = await storage.existsFunction(fname);
        assert.equal(exists, expected, 'function exists');
    });

    it('should return function info', async () => {
        const fname = "test_func";
        //const expected = "{\"functionArray\":\"[{}]\"}";
        const expected = "{\"name\":\""+ fname +"\",\"signature\":\"sign\",\"price\":\"15\",\"description\":\"desc\",\"developer\":\""+ pippo +"\"}";
        await storage.insertNewFunction(fname, "sign", 15, pippo, "desc");
        await storage.insertInArray(fname);
        
        const info = await storage.getFuncInfo(fname);
        assert.equal(info, expected.toLowerCase(), 'the function info was not returned as expected');
    });

    it('should return the function list', async () => {
        const fname = "test_func";
        const sec_fname = "testfunc_two";
        const expected = "{\"functionArray\":[" + 
        "{\"name\":\"" + fname + "\",\"signature\":\"sign\",\"price\":\"15\"}," +
        "{\"name\":\"" + sec_fname + "\",\"signature\":\"sign\",\"price\":\"15\"}"         
        + "]}";
        //const expected = "";
        await storage.insertNewFunction(fname, "sign", 15, pippo, "desc");
        await storage.insertInArray(fname);
        await storage.insertNewFunction(sec_fname, "sign", 15, pippo, "desc");
        await storage.insertInArray(sec_fname);

        const list = await storage.getList();
        assert.equal(list, expected, 'the function list was not returned as expected');
    });

    it('should return the function list for a single owner', async () => {
        const fname = "test_func";
        const sec_fname = "another_test_func";
        const other_fname = "other_owner_func";
        const expected = "{\"functionArray\":[" +
            "{\"name\":\"" + fname + "\",\"signature\":\"sign\",\"price\":\"15\"}," +
            "{\"name\":\"" + sec_fname + "\",\"signature\":\"sign\",\"price\":\"15\"}"
            + "]}";
        //const expected = "";
        await storage.insertNewFunction(fname, "sign", 15, pippo, "desc");
        await storage.insertInArray(fname);
        await storage.insertNewFunction(sec_fname, "sign", 15, pippo, "desc");
        await storage.insertInArray(sec_fname);

        await storage.insertNewFunction(other_fname, "sign", 15, pluto, "desc");
        await storage.insertInArray(other_fname);


        const list = await storage.getDevList(pippo);
        assert.equal(list, expected, 'the function list was not returned as expected');
    });

    it('should return the function\'s price', async () => {
        const fname = "test_func";
        const expected = 15;
        await storage.insertNewFunction(fname, "signature", expected, pippo, "description");
        await storage.insertInArray(fname);
        const price = await storage.getFuncPrice(fname);
        assert.equal(price, expected, 'price is not exact');
    });

    it('should return the function\'s developer', async () => {
        const fname = "test_func";
        const expected = pippo;
        await storage.insertNewFunction(fname, "signature", 15, expected, "description");
        await storage.insertInArray(fname);
        const dev = await storage.getFuncDev(fname);
        assert.equal(dev, expected, 'developer is not the expected address');
    });

    /*it('should correctly compare two strings', async () => {
        const expected_f = false;
        const expected_t = true;
        const s1 = "first_test_string''@";
        const s2 = "second_test_string''@";
        const isnotequal = await storage.compareString(s1,s2);
        const isequal = await storage.compareString(s1,s1);
        assert.equal(isnotequal, expected_f, 'strings were not compared correctly');
        assert.equal(isequal, expected_f, 'strings were not compared correctly');
    });*/
});
