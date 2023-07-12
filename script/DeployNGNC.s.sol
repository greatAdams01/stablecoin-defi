// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "forge-std/Script.sol";

import "../src/NGNcoin.sol";
import "../src/NGNEngine.sol";
import "./HelperConfig.s.sol";

contract DeployNGNC is Script {
  address [] tokenAddresses;
  address [] priceFeedAddresses;

  function run () external returns(NGNCoin, NGNEngine) {

    HelperConfig config = new HelperConfig();

    (
      address wethNGNPriceFeed,
      address wbtcNGNPriceFeed,
      address weth,
      address wbtc,
      uint256 deployerKey
    ) = config.activeNetworkConfig();

    tokenAddresses = [weth, wbtc];
    priceFeedAddresses = [wethNGNPriceFeed, wbtcNGNPriceFeed];

    vm.startBroadcast(deployerKey);
    NGNCoin NGNC = new NGNCoin();
    NGNEngine engine = new NGNEngine(tokenAddresses, priceFeedAddresses, address(NGNC));
    NGNC.transferOwnership(address(engine));
    vm.stopBroadcast();

    return (NGNC, engine);
  }
}