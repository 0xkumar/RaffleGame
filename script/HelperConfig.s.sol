// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
contract helperConfig is Script{

    struct NetworkConfig{
        entranceFee;
        interval;
        gaslane;
        subscriptionId;
        callbackGasLimit;
        Rafflestate.open;
    }

    function getSepoliaTestNetwork() public view returns(NetworkConfig){
        returns NetworkConfig({
            entranceFee = 0.1 ETH;
            interval = 
            gaslane = 
        })
    }
}
