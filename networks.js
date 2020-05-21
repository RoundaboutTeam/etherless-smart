const HDWalletProvider = require('@truffle/hdwallet-provider');
const mnemonic = "onion addict episode afraid budget crawl voyage draft skirt display sock electric";

module.exports = {
    networks: {
        ganache: {
            protocol: 'http',
            host: 'localhost',
            port: 7545,
            gas: 5000000,
            gasPrice: 5e9,
            networkId: '*',
        },
        ropsten: {
            provider: function () {
                return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/v3/8a157000ad9148529a02513177b904bd");
            },
            network_id: '3',
        },
    },
};