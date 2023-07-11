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

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/*
 * @title NGN stablecoin
 * @author Great Adams
 * Collateral: Exogenous (ETH & BTC)
 * Minting: Algorithmic
 * Relative Stability: Pegged to NGN
 *
 * This the contract to be governed by SCEngine. This is just an implementation of ERC20 stablecoin
 *
 */

contract NGNCoin is ERC20Burnable, Ownable {

  error NGNCoin_MustBeMoreThanZero();
  error NGNCoin_BurnAmountExceedsBalance();
  error NGNCoin_NotZeroAddress();

  constructor()ERC20("Naira coin",  "NGNC") {

  }


  function burn(uint256 _amount) public override onlyOwner {
    uint256 balance = balanceOf(msg.sender);
    if(_amount <=0) {
      revert NGNCoin_MustBeMoreThanZero();
    }

    if(balance < _amount) {
      revert NGNCoin_BurnAmountExceedsBalance();
    }

    super.burn(_amount);
  }


  function mint (address _to, uint256 _amount) external onlyOwner returns(bool) {
    if(_to == address(0)){
      revert NGNCoin_NotZeroAddress();
    }

    if(_amount <= 0) {
      revert NGNCoin_MustBeMoreThanZero();
    }

    _mint(_to, _amount);

    return true;
  }



}