// SPDX-License-Identifier: MIT
pragma solidity ^0.6.5;

contract CampaignFactory {
  address[] public deployedCampaigns;

  function createCampaign(uint minimumGas) public {
    address newCampaign = address(new Campaign(minimumGas, msg.sender)); // pass sender address
    deployedCampaigns.push(newCampaign);
  }

  function getDeployedCampaigns() public view returns (address[] memory) {
    return deployedCampaigns;
  }
}

contract Campaign {
    
    // not instance but type
    struct Request {
        string description;
        uint value;
        address payable recipient; // should set as payable
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
        
    }
    
    Request[] public requests;
    address payable public manager;
    uint public minContribution;
    mapping(address => bool) public approvers;
    uint public approversCount;
    
    
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
    
    constructor (uint minimum, address campaignCreator) public {
        manager = campaignCreator;
        minContribution = minimum;
    }
    
    function contribute() public payable {
        require(msg.value > minContribution);
        
        // count number of contributors
        if(!approvers[msg.sender]) {
            approversCount++;
        }

        approvers[msg.sender] = true;        
    }
    
    
    function createRequest(string memory description, uint value, address payable recipient) public restricted {
        // check request balance and current balance
        require(value <= address(this).balance);
        require(approvers[msg.sender]);
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });
        
        requests.push(newRequest);
    }
    
    function approveRequest(uint index) public {
        Request storage request = requests[index];
        
        // check if already donated
        require(approvers[msg.sender]);
        // if the person already voted and exist their address on the mapping
        require(!requests[index].approvals[msg.sender]);
        
        requests[index].approvals[msg.sender] == true;
        requests[index].approvalCount++;
    }

    
    function finalizeRequest (uint index) public restricted {
        // access specific index array
       //  Request storage request = requests[index];
        
        require(request[index].approvalCount > (approversCount / 2));
        require(!request[index].complete);
        
        // transfer money and marka as true: completed
        request[index].recipient.transfer(request[index].value);
        request[index].complete = true;
    }
}