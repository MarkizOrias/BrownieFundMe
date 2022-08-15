//SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address owner;
    AggregatorV3Interface public priceFeed;

    //ganache/rinkeby mocking - replacing priceFeed variable with non-hardcoded

    constructor(address _priceFeed)
        public
    //constructor is instantly called when contract is deployed. You can assign an owner of the contract
    //without a risk o somebody else's taking over your contract
    {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
        //address of the owner that deploys the contract
    }

    function fund() public payable {
        uint256 minimumValue = 50 * 10**18;
        require(
            getConversionRate(msg.value) >= minimumValue,
            "You need to spend more GAS!"
        );

        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // );
        return priceFeed.version();
    }

    function callPrice() public view returns (uint256) {
        // AggregatorV3Interface priceCurrent = AggregatorV3Interface(
        //     0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // );
        // //calling the aggregator contract, naming the created variable and assigning data feed address to it (calling different contract)

        (, int256 answer, , , ) = priceFeed.latestRoundData();
        //using what we actually need from the table - priceCurrent switched to priceFeed variable

        return uint256(answer * 10**10);
        //converting answer to wei (18 decimal places)
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = callPrice(); // 10**18
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 10**18;
        return ethAmountInUSD;
    }

    function convertUSDtoETH(uint256 USDAmount) public view returns (uint256) {
        uint256 ethPrice = callPrice();
        uint256 conversionResult = (USDAmount * 10**36) / ethPrice; //e-18
        return conversionResult;
    }

    function getEntranceFee() public view returns (uint256) {
        //minimum USD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = callPrice();
        uint256 precision = 1 * 10**18;
        return ((minimumUSD * precision) / price) + 1;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Your account address is not an owner of the contract"
        );
        //run this than...
        _;
        //...all the rest
    }

    function showOwner() public view returns (address) {
        return owner;
    }

    function withdraw() public payable onlyOwner {
        require(msg.sender == owner);
        msg.sender.transfer(address(this).balance);
        //this is a contract we are in, address is the address of a contract.
        //balance is the current balance on a contract (a method)
        //msg.sender - whoever calls this function
        //transfer the balance

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //loop through all funders, read their address from an array and nullify their balances
        funders = new address[](0); //???
    }
}
