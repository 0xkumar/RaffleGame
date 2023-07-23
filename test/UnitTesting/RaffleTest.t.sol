//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test,console} from "../../lib/forge-std/src/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";


contract RaffleTest is  Test {
    Raffle raffle;
    HelperConfig helperConfig;

    uint entranceFee;
    uint interval;
    bytes32 gaslane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address vrfCoordinator;


    address public PLAYER = makeAddr("player");
    uint public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() public {
        DeployRaffle deployer = new DeployRaffle();
        (raffle,helperConfig)=deployer.run();
        (
             entranceFee,
             interval,
             gaslane,
             subscriptionId,
             callbackGasLimit,
             vrfCoordinator
        ) = helperConfig.ActiveNetworkConfig();
        vm.deal(PLAYER,STARTING_USER_BALANCE);
    }

    function testRaffleInitializesOpenState() public view  {
        assert(raffle.getRaffleState() == Raffle.Rafflestate.open);
    }


    
//////////// enter raffle
 function testRaffleRevertWhenYouDontPayEnough() public {
    //Arrange
    vm.prank(PLAYER);
    //Act
    vm.expectRevert(Raffle.Raffle_NotEnoughEthSent.selector);
    raffle.enterRaffle();

    //Assert
    
 }

 function testRaffleRecordsPlayerWhenTheyEnter() public {
    vm.prank(PLAYER);
    raffle.enterRaffle{value:1 ether}();
    address playerRecorded =  raffle.getPlayer(0);
    assert(playerRecorded == PLAYER);

      
 }
}

