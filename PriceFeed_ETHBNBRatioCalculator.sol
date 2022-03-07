// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ETHBNB_RatioCalculator {

    // this contract i smeant to be used on Kovan network
    // Both of the Interfaces retrieve data frim the kovan source contracts
    // Read the documentation if you want to implement another network 
    
    AggregatorV3Interface internal priceFeedETH;
    AggregatorV3Interface internal priceFeedBNB;

    int public priceETH;
    int public priceBNB;


    constructor() {
        priceFeedETH = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        priceFeedBNB = AggregatorV3Interface(0x8993ED705cdf5e84D0a3B754b5Ee0e1783fcdF16);
    }


    function getLatestPriceETH() public {
        (uint80 roundID, int price, uint startedAt, uint timeStamp, uint80 answeredInRound) = priceFeedETH.latestRoundData();
        priceETH = price;
    }

    function getLatestPriceBNB() public {
        (uint80 roundID, int price, uint startedAt, uint timeStamp, uint80 answeredInRound) = priceFeedBNB.latestRoundData();
        priceBNB = price;
    }


    function getRatio() public view returns(int) {
        require(priceETH > 0, "Retrieve the ETH price before executing this function :)");
        require(priceBNB > 0, "Retrieve the BNB price before executing this function :)");
        return priceETH/priceBNB;
    }
}
