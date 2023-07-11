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

contract NGNEngine {

  function depositCollateralAndMint() external {}

  function depositCollateralforNGNC() external {}

  function redeemCollateralforNGNC() external {}

  function redeemCollateral() external {}

  function mintNGNC() external {}

  function burnNGNc() external {}

  function liquidate() external {}

  function getHealthFactor() external {}
}