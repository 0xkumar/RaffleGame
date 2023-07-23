//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "lib/forge-std/src/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployRaffle is Script{

    function run() external returns (Raffle,HelperConfig){
        HelperConfig helperConfig = new HelperConfig();
        //NetworkConfig  config = helperConfig.ActiveNetworkConfig(); /** below is the nother way for this */
        (
            uint entranceFee,
            uint interval,
            bytes32 gaslane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address vrfCoordinator
        ) = helperConfig.ActiveNetworkConfig();

        vm.startBroadcast();
        Raffle raffle = new Raffle(entranceFee,interval,vrfCoordinator,gaslane,subscriptionId,callbackGasLimit);

        vm.stopBroadcast();
        return (raffle,helperConfig);
    }


}

     
