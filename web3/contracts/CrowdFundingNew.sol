// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@thirdweb-dev/contracts/extension/ContractMetadata.sol";

contract CrowdFunding {
    struct Campaign{
        address owner;
        string title;
        string description;
        uint target;
        uint deadLine;
        uint amountCollected;
        string image;//because we are going to use "URL" for the image.
        address[] donators;
        uint[] donations;
    }

    //now we will map out number of campaign with the struct campaign.
    mapping(uint => Campaign) public campaigns;
    uint public numberOfCampaigns = 0;//we have to keep recoed of campaigns to give them ids.

    //first function is to create a function

    function createCampaign(address _owner, string memory _title, string memory _description, uint _target, uint _deadline, string memory _image) public returns(uint){
        Campaign storage campaign  = campaigns[numberOfCampaigns];

        //require is similar to if statement in other language, it is used to check the conditions required.
        require(campaign.deadLine < block.timestamp , "deadline must be in future");
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadLine = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        numberOfCampaigns++;

        return numberOfCampaigns-1;
    }

    //payable is a function which is used to pay crypto currency.
    function donateToCampaign(uint _id) public payable{
        uint amount = msg.value;

        //here campaigns is a mapping we create above.
        Campaign storage campaign = campaigns[_id];

        //here we have added the user who is sending the money to campaign and add the name in donation array.
        campaign.donators.push(msg.sender);

        //here we have added the amount to be donated to campaign and add in donations array.
        campaign.donations.push(amount);

        //this is the main statement of the campaign, how to transfer money, on left side we have assigned one variable which is 'sent' actucally we have to assign 2 variables so we have put the ','. theb on right side the payable .
        (bool sent,) = payable(campaign.owner).call{value : amount}("");

        if(sent){
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }
    
    function getDonator(uint _id) view public returns(address[] memory, uint[] memory){
        return (campaigns[_id].donators , campaigns[_id].donations); 
    }

    function getCampaigns()public view returns(Campaign[] memory){

        //here we have created a new variable called allCampaigns which is a type of multiple campaign structure, so we are not actually getting all the campaigns but instead we are creating a new array which containes campaign equal to the numberOfCampaigns like [{},{},{},.....]
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        //now we will loop thorugh the campaign structure and populate that variable
        for(uint i = 0 ; i < numberOfCampaigns ; i++){
            Campaign storage item = campaigns[i];

            allCampaigns[i] = item;
        }

        return allCampaigns; 
    }   
}