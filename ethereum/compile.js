const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');


// delete the build folder
const buildPath = path.resolve(__dirname, 'build');


// read 'Campaign.sol' from the 'contracts' folder
const campaignPath = path.resolve(__dirname, 'contracts', 'Campaign.sol');
const source = fs.readFileSync(campaignPath, 'utf-8');

// compile both contracts with solidity compiler
// output contains campaign contract and campaign factory

var input = {
  language: "Solidity",
  sources: {
    "Campaign.sol": {
      content: source
    }
  },
  settings: {
    outputSelection: {
      '*': {
        '*': ['*']
      }
    }
  }
};

const output = JSON.parse(solc.compile(JSON.stringify(input.interface)));

if(output.errors) {
  output.errors.forEach(err => {
    console.log(err.formattedMessage);
  });
} else {
  const contracts = output.contracts["Campaign.sol"];
// recreate the folder
  fs.ensureDirSync(buildPath);

// write output to the 'build' directory
  for (let contractName in contracts) {
    const contract = contracts[contractName];
    fs.writeFileSync(
      path.resolve(buildPath, `${contractName}.json`),
      JSON.stringify(contract, null, 2),
    " utf8"
  );
  }
}