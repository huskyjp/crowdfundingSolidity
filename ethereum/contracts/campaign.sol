pragma solidity >=0.4.17 < 0.8.0;


contract CampaignFactory {
  address[] public deployedCampaigns;

  function createCampaign(uint minimum) public {
    address newCampaign = address(new Campaign(minimum, msg.sender)); // pass sender address
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
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
        
    }
    
    Request[] public requests;
    address public manager;
    uint public minContribution;
    mapping(address => bool) public approvers;
    uint public approversCount;
    
    
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
    
    constructor (uint minimum, address campaignCreator) public payable {
        manager = campaignCreator;
        minContribution = minimum;
    }
    
    function contribute() public payable {
        require(msg.value > minContribution);
        
        approvers[msg.sender] = true;    
        approversCount++;
        
    }
    
    
    function createRequest(string memory description, uint value, address recipient) public restricted {
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
        Request storage request = requests[index];
        
        require(request.approvalCount > (approversCount / 2));
        require(!request.complete);
        
        
        request.recipient.transfer(request.value);
        request.complete = true;
    }
}