// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "forge-std/Test.sol";

import "../../script/DeployNGNC.s.sol";
import "../../src/NGNcoin.sol";
import "../../src/NGNEngine.sol";
import "../../script/HelperConfig.s.sol";

contract NGNEngineTest is Test{
  DeployNGNC deployer;
  NGNCoin ngncoin;
  NGNEngine ngnengine;
  HelperConfig config;
  address ethNGNPriceFeed;
  address weth;

  function setUp() public {
    deployer = new DeployNGNC(); 
    (ngncoin, ngnengine, config) = deployer.run();
    (ethNGNPriceFeed, , weth, ,) = config.activeNetworkConfig();
  }

  /////////////////
  // Price test //
 /////////////////

  function testGetNgnValue() public {
    uint256 ethAmount = 15e18;
    uint256 expectedNgn = 3000e18;
    uint256 actualNgn = ngnengine.getNGNValue(weth, ethAmount);
    assertEq(expectedNgn, actualNgn);

  }

}