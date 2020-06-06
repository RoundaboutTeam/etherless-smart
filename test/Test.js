const EtherlessSmart = artifacts.require('EtherlessSmart');
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
        await instance.runFunction(fname, "10,2", {from: pippo, value: 15});
        const deposit = await instance.getDeposit(1);
        console.log(deposit);
        assert.equal(exists, expected, 'function was not added correctly');
        assert.equal(deposit, expected2, 'function was not run correctly');
    });

});

/*const ethers = require('ethers');
const EtherlessSmart = artifacts.require('EtherlessSmart');
let provider = new ethers.providers.Web3Provider(web3.currentProvider)
const signer = provider.getSigner(0);

describe('EthSmart', async function () {
    it('tests contract id', async function () {
            let cf = ethers.ContractFactory.fromSolidity(EtherlessSmart);
            let contract = await cf.deploy("Hello World");
            console.log(contract.address);
            console.log(contract.deployTransaction.hash);
            await contract.deployed()
        });
});*/