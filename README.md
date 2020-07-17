# Etherless-smart
Smart contract component of Etherless, a module that handles etherless-cli / etherless-server communication (and payment of this work).

**This module is made to work in conjunction with the other components of Etherless**

## Requirements
In order to make this module work, you need to have these installed:
- [Nodejs LTS](https://nodejs.org/it/download/)
- Truffle <code>npm install -g truffle</code>
- Ganache-cli <code>npm install -g ganache-cli</code>

## Installation
- Download this repo
- From inside of the downloaded repo run the command <code>npm install</code> to install all the missing dependencies

## Interacting with the Ropsten testnet and Ganache
In order to interact with the Ropsten testnet, before beginning the installation process you need two keys: an Infura project id (from your own Infura account) and the mnemonic phrase of your Ethereum account.  Having these credentials you need to create a `.env` file with the following structure:
<br /> <br />
		`"MNENOMIC = // Your metamask’s recovery words` <br />
		`"INFURA_API_KEY = // Your Infura API Key after its registration`<br />
<br /> <br />
Replace the matching fields with your own.

## Etherless-smart contracts deployment
In order to be accessible, Etherless-smart contracts should be deployed, to the chosen network from the ones, defined in the `networks.js` file, in the same file values like gasLimit and gasPrice can be set. The contract deployment should be done using the Openzeppelin-cli, in order to easily upgrade the contracts in the future. 
For detailed instructions on deploying a contract from the Openzeppelin-cli refer to the [documentation](https://docs.openzeppelin.com/learn/deploying-and-interacting#deploying-a-smart-contract).
The contracts should be deployed as follows:
- run the command `truffle compile`;
- the EtherlessStorage contract should be deployed first, using `npx oz deploy` and the resulting contract address should be stored somewhere safe;
- then the EtherlessSmart contract should be deployed, using `npx oz deploy` and calling the initialize function as prompted by the cli. The initializer functions requires:
    - the address of the storage contract, previously deployed;
    - the address used for the Etherless-server module;
    - the service fee that should be applied to the requests;
