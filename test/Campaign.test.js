const asset = require("asset");
const ganache = require("ganache-cli")
const Web3 = require("web3");
const web3 = new Web3(ganache.provider());

const compiledFactory = require("../ethereum/build/CampaignFactory.json");
const compiledCampaign = require("../ethereum/build/Campaign.json");

let accounts;
let factory;
let campaign;
let campaignAddress;


beforeEach(async () => {
  // get list of accounts
  accounts = await web3.eth.getAccounts();

  // get instance of factory contract by using compiledFactory
  // 1. get contract inside of web3
  // 2. deploy
  factory = await new web3.eth.Contract(compiledFactory.abi).deploy({
    data: compiledFactory.evm.bytecode.object
  }).send({
    from: accounts[0], gas: "1000000"
  });

  // access to createCampaign method which is one of the factory menthods
  // can't receive campaign address by only this call
  await factory.methods.createCampaign('100').send({
    from: accounts[0], // manager of this campaign
    gas: "1000000"
  });

  // get campaign address data by calling getDeployedCampaigns which is view method
  // it returns array of addresses but we just get the very first address, index 0
  [campaignAddress] = await factory.methods.getDeployedCampaigns().call();

  campaign = await new web3.eth.Contract(compiledCampaign.abi, campaignAddress);
});


describe('Campaigns', () => {
  it('deploys a factory and a campaign', () => {
    assert.ok(factory.options.address);
    assert.ok(campaign.options.address);
  });
});

