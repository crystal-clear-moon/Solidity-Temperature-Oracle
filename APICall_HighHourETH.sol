// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

// (1) Change your network to Kovan before deploying
// (2) Request testnet LINK and ETH here: https://faucets.chain.link/
// (3) For preventing errors you must provide some LINK for this contract before executing any function
// (4) Then click on the requestData() to update the highHour variable
// (5) Wait a while to see change variable changing

contract APIConsumer is ChainlinkClient {
    using Chainlink for Chainlink.Request;
  
    uint256 public highHour;
    
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    address public submiter;
    
    // Here we specify who can modify the highHour
    constructor(address _submiter) {
        setPublicChainlinkToken();
        submiter = _submiter;
        oracle = 0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8;
        jobId = "d5270d1c311941d0b08bead21fea7747";
        fee = 0.1 * 10 ** 18; 
    }
    
    function requestVolumeData() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        
        request.add("get", "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD");

        request.add("path", "RAW.ETH.USD.HIGHHOUR");

        return sendChainlinkRequestTo(oracle, request, fee);
    }
    
    function fulfill(bytes32 _requestId, uint256 _number) public recordChainlinkFulfillment(_requestId)
    {
        highHour = _number;
    }

    // Our getter function
    function getHigh() public view returns(uint) {
        return highHour;
    }

    // Our setter function
    function setHigh(uint _number) public returns(uint) {
        require(msg.sender == submiter, "You don't have permission!");
        highHour = _number;
        return highHour;
    } 
}
