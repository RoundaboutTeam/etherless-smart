const ethers = require ('ethers');
const smart = require('../build/contracts/EtherlessSmart.json');
const storage = require('../build/contracts/EtherlessStorage.json');
const escrow = require('../build/contracts/EtherlessEscrow.json');
//let abi = smart.abi;
//let bytecode = smart.bytecode;
//let provider = new ethers.providers.JsonRpcProvider();
let provider = new ethers.providers.Web3Provider(web3.currentProvider);
let signer = provider.getSigner();

//contract deployment
(async function () {
    //deploy EtherlessStorage contract
    let factoryst = new ethers.ContractFactory.fromSolidity(storage, signer);
    storage_contr = await factoryst.deploy();
    await storage_contr.deployed();

    //deploy EtherlessSmart contract
    let factory = new ethers.ContractFactory.fromSolidity(smart, signer);
    smart_contr = await factory.deploy();
    await smart_contr.deployed();
})();

//tests
describe('JS Test Smart', function () {
    it('tests initial id', async function () {
        await smart_contr.initialize(storage_contr.address, signer.getAddress(), 15);
        let id = await smart_contr.getId();
        assert.equal(id, 0, "id is not zero");
    });

    it('at start, list should be empty', async () => {
        const expected = "{\"functionArray\":[]}";
        const list = await smart_contr.getFuncList();
        assert.equal(list, expected, 'list is not empty');
    });

    it('should correctly add a function', async () => {
        const expected = true;
        const fname = "test_func";
        const fsign = "sign";
        const fdesc = "description";
        const fprice = 15;
        smart_contr.connect(signer);
        await smart_contr.addFunction(fname, fsign, fprice, fdesc);
        const exists = await storage_contr.existsFunction(fname);
        assert.equal(exists, expected, 'function was not added correctly');
    });

    it('should correctly return the function list', async () => {
        const fname = "test_func";
        const fsign = "sign";
        const fprice = 15;
        const expected = "{\"functionArray\":[{\"name\":\""+fname+"\",\"signature\":\""+fsign+"\",\"price\":\""+fprice+"\"}]}";
        const list = await smart_contr.getFuncList();
        assert.equal(list, expected, 'function list is not what expected');
    });

    it('should correctly run a function', async () => {
        const expectedDeposit = 15;
        const expectedId = 1;
        const fname = "test_func";
        const exists = await storage_contr.existsFunction(fname);
        await smart_contr.runFunction(fname, "10,2", { value: 15 });
        const deposit = await smart_contr.getDeposit(1);
        const id = await smart_contr.getId();
        assert.equal(deposit, expectedDeposit, 'function was not run correctly');
        assert.equal(id, expectedId, 'function was not run correctly');
    });
});


/*const EtherlessSmart = artifacts.require('EtherlessSmart');
const EtherlessStorage = artifacts.require('EtherlessStorage');
const EtherlessEscrow = artifacts.require('EtherlessEscrow');

//const SERVICE_FEE = 10;

contract('EtherlessSmart', (accounts) => {
    const [pippo, pluto] = accounts;

    it('at start, list should be empty', async () => {
        const expected = "{\"functionArray\":[]}";
        const instance = await EtherlessSmart.new();
        const storage = await EtherlessStorage.new();
        await instance.initialize(storage.address, pippo);
        const id = await instance.getId();
        const list = await instance.getFuncList();
        console.log(list);
        assert.equal(list, expected, 'list is not empty');
    });

    it('should correctly add a function', async () => {
        const expected = true;
        const fname = "test_func";
        const instance = await EtherlessSmart.new();
        const storage = await EtherlessStorage.new();
        await instance.initialize(storage.address, pippo);
        await instance.addFunction(fname, "sign", 15, "description");
        const list = await instance.getFuncList();
        const exists = await storage.existsFunction(fname);
        console.log(list);
        assert.equal(exists, expected, 'function was not added correctly');
    });

    it('should correctly run a function', async () => {
        const expected = true;
        const expected2 = 15;
        const fname = "test_func";
        const instance = await EtherlessSmart.new();
        const storage = await EtherlessStorage.new();
        await instance.initialize(storage.address, pippo);
        await instance.addFunction(fname, "sign", 15, "description");
        //const list = await instance.getFuncList();
        const exists = await storage.existsFunction(fname);
        await instance.runFunction(fname, "10,2", { from: pippo, value: 15 });
        const deposit = await instance.getDeposit(1);
        console.log(deposit);
        assert.equal(exists, expected, 'function was not added correctly');
        assert.equal(deposit, expected2, 'function was not run correctly');
    });

});*/
