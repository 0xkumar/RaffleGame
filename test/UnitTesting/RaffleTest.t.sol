//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test,console} from "../../lib/forge-std/src/Test.sol";


contract RaffleTestis is  Test {
    Raffle raffle;

    address public PLAYER = makeAddr("player");
    uint public constant STARTING_BALANCE = 10 ether;

    function setUp() public {
        DeployRaffle deployer = new DeployRaffle();
        raffle=deployer.run();
    }
}