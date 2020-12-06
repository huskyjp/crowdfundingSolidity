const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');


// delete the build folder
const buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath);


// read 'Campaign.sol' from the 'contracts' folder
const campaignPath = path.resolve(__dirname, 'contracts', 'Campaign.sol');
const source = fs.readFileSync(campaignPath, 'utf-8');

// compile both contracts with solidity compiler
// output contains campaign contract and campaign factory
const output = solc.compile(source, 1).contracts;

// recreate the folder
fs.ensureDirSync(buildPath);

// write output to the 'build' directory
for (let contract in output) {
  fs.outputJsonSync(
    path.resolve(buildPath, contract + '.json'),
    output[contract]
  );
}