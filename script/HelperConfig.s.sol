// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
contract HelperConfig is Script{

    struct NetworkConfig{
        uint entranceFee;
        uint interval;
        bytes32 gaslane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
        address vrfCoordinator;
    }

 
    NetworkConfig public ActiveNetworkConfig;

    constructor() {
        if (block.chainid ==1115511){
           ActiveNetworkConfig =  getSepoliaEthConfig();
        }
        else{
            ActiveNetworkConfig = GetOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        return NetworkConfig({
            entranceFee : 0.01 ether,
            interval : 30,
            vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            gaslane : 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId : 0, //Update this with our subscription id
            callbackGasLimit : 200000
        });
    }

    uint96 baseFee = 0.25 ether; //0.25 LINK
    uint96 gasPriceLink = 1e9; //0.1 LINK


    function GetOrCreateAnvilEthConfig() public  returns (NetworkConfig memory){
         if (ActiveNetworkConfig.vrfCoordinator != address(0)){
            return ActiveNetworkConfig;
         }
         vm.startBroadcast();
         VRFCoordinatorV2Mock vrfCoordinatorMock = new VRFCoordinatorV2Mock(baseFee,gasPriceLink);
         vm.stopBroadcast();
            return NetworkConfig({
            entranceFee : 0.01 ether,
            interval : 30,
            vrfCoordinator: address(vrfCoordinatorMock),
            gaslane : 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, //This is not important now
            subscriptionId : 0, //script will add this!
            callbackGasLimit : 500000
            });

    }
}
