// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity 0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "./NGNcoin.sol";

/*
 * @title NGNEngine
 * @author Great Adams
 *
 * The system is designed to be as minimal as possible and have the tokens maintain a 1 token == NGN 1 peg
 * This stablecoin has the propreties: 
 * - Exogenous collateral
 * - Naira pegged
 * - Algoritimically stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was backed by only WETH and WBTC.
 *
 * Our NGNcoin system should always be "overcollateralized". At no point should the value of all collateral <= the value of the NGNcoin
 *
 * @notice This contract is the core of the NGNcoin Stablecoin system. It handles all the logic
 * for minting and redeeming DSC, as well as depositing and withdrawing collateral.
 * @notice This contract is based on the MakerDAO DSS system  
 *
 */

contract NGNEngine is ReentrancyGuard {
    /**
     *
     *    Errors
     *
     */
    error NGNEngine__NeedsMoreThanZero();
    error NGNEngine__TokenAddressesAndPriceFeedAddressMustBeSameLength();
    error NGNEngine__NotAllowedToken();
    error NGNEngine__TransferFailed();
    error NGNEngine__BreaksHealthFactor(uint256 healthFactor);

    /**
     *
     *    State Variables
     *
     */
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50;
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1;

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping (address user => uint256 amountNGNcoinMinted) private s_NGNcoinMinted;
    address [] private s_collateralTokens;

    NGNCoin private immutable i_ngncoin;


    /**
     *
     *    Events
     *
     */

    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);


    /**
     *
     *    Modifiers
     *
     */

    modifier moreThanZero(uint256 amount) {
        if (amount <= 0) {
            revert NGNEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert NGNEngine__NotAllowedToken();
        }
        _;
    }

    /**
     *
     *    Functions
     *
     */
    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address ngncAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert NGNEngine__TokenAddressesAndPriceFeedAddressMustBeSameLength();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }

        i_ngncoin = NGNCoin(ngncAddress);
    }

    /**
     *
     *    External Functions
     *
     */

    function depositCollateralAndMint() external {}


    /*
     * @notice follows CEI (Checks, Effects interactions)
     * @param tokenCollateralAddress: The ERC20 token address of the collateral you're depositing
     * @param amountCollateral: The amount of collateral you're depositing
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if(!success) {
            revert NGNEngine__TransferFailed();
        }
    }

    function redeemCollateralforNGNC() external {}

    function redeemCollateral() external {}

    /*
     * @notice follows CEI (Checks, Effects interactions)
     * @param amountNGNcoinToMint the amount of NGNcoin to mint
     * @notice they must have more collateral value than the minimum threshold
     */
    function mintNGNC(uint256 amountNGNcoinToMint) external moreThanZero(amountNGNcoinToMint) nonReentrant {
        s_NGNcoinMinted[msg.sender] += amountNGNcoinToMint;

        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function burnNGNc() external {}

    function liquidate() external {}

    function getHealthFactor() external {}

    /**
     *
     *    private & internal Functions
     *
     */

    function _getAccountInformation(address user) private view returns(uint256 totlaNGNCoinMinted, uint256 collaterlValueInUsd) {
        totlaNGNCoinMinted = s_NGNcoinMinted[user];
        collaterlValueInUsd = getAccountCollateralValue(user);

    }


    /**
     * Returns how close to liquidation a user is 
     * If a user goes below 1, then they get liquidated
     */
    function _healthFactor(address user) private view returns (uint256) {
        (uint256 totlaNGNCoinMinted, uint256 collaterlValueInUsd) = _getAccountInformation(user);

        uint256 collateralAdjustedForThreshold = (collaterlValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;

        return (collateralAdjustedForThreshold * PRECISION) / totlaNGNCoinMinted;
    }

    // 1. Check health factor (do they have enough collateral?)
    // 2. Revert if they don't
    function _revertIfHealthFactorIsBroken(address user) internal view {
        uint256 userHealthFactor = _healthFactor(user);
        if(userHealthFactor < MIN_HEALTH_FACTOR){
            revert NGNEngine__BreaksHealthFactor(userHealthFactor);
        }
    }


    /**
     *
     *    public & External Functions
     *
     */

    function getAccountCollateralValue(address user) public view returns(uint256 totalCollateralValueInNGN) {
        // Loop through each collateral token, get the amount they have deposited, and map it to 
        // the price, to get usd value
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollateralValueInNGN +=getNGNValue(token, amount);
        }

        return totalCollateralValueInNGN;
    }


    function getNGNValue(address token, uint256 amount) public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
        (,int256 price,,,) = priceFeed.latestRoundData();

        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }

}
