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
// internal & private view & pure functions
// external & public view & pure functions


//CEI : checks-effects-interactions

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/VRFCoordinatorV2.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title A Sample Raffle Contract
 * @author 0xkumar
 * @notice This contract is for creating a raffle
 * @dev Implements chainlik VRFv2
 */

contract Raffle is VRFConsumerBaseV2{

    error Raffle_NotEnoughEthSent();
    error Raffle_TransferFailed();
    error Raffle_RaffleNotOpened();
    error Raffle__UpKeepNotNeeded(
        uint256 balance,
        uint256 numPlayers,
        uint256 raffleState
    );

    /**bool lottery = open,closed,calculating
     * type declarations
     */

    enum Rafflestate{
        open,
        calculating
    }

    uint16 private constant REQUEST_CONFIRMATIONS = 2;
    uint8 private constant NUMWORDS = 1;

    uint private immutable i_entranceFee;
    //@dev Duration of the lottery in seconds
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gaslane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGaslimit;

    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    Rafflestate private s_Rafflestate;

    event enteredRaffle(address indexed player);
    event WinnerPicked(address indexed winner);

    constructor(uint entranceFee,uint256 interval,address vrfCoordinator,bytes32 keyhash,
    uint64 subscriptionId,
    uint32 callbackGasLimit)
    VRFConsumerBaseV2(vrfCoordinator) 
    {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gaslane = keyhash;
        i_subscriptionId = subscriptionId;
        i_callbackGaslimit = callbackGasLimit;
        s_Rafflestate = Rafflestate.open;
    }


    function enterRaffle() external  payable {
        if(msg.value <= i_entranceFee){
            revert Raffle_NotEnoughEthSent();
        }
        if(s_Rafflestate != Rafflestate.open){
            revert Raffle_RaffleNotOpened();
        }
        s_players.push(payable(msg.sender));
        emit enteredRaffle(msg.sender);

    }
    //When the winner supposed to be picked?
    /**
     * @dev This is the function that the Chainlink Automation nodes call
     * to see if its time to perform an upkeep.
     * The following should be true for this to return true:
     * 1.The time interval has passed between raffle runs
     * 2.The raffle is in the open state
     * 3.The contract has ETH (aka, players)
     * 4.(I,plicit) The subscription is fundedwith link
     */

    function checkUpkeep(bytes memory /**checkData*/) public view returns(bool upkeepNeeded, bytes memory /** performData */){
        bool timeHasPassed = (block.timestamp - s_lastTimeStamp) >= i_interval;
        bool isOpen = s_Rafflestate == Rafflestate.open;
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = (timeHasPassed && isOpen && hasBalance);
        return (upkeepNeeded,"0x0");
    }

    /** 1.Get the number automatically from chainlink VRF
     * 2.Use the random number to pick a winner 
     * 3.Be automatically called
     */

     function performUpkeep(bytes calldata /* performData */) external {
        (bool upkeepNeeded,) = checkUpkeep("");
        if (!upkeepNeeded){
            revert Raffle__UpKeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_Rafflestate)

            );
        }

        s_Rafflestate = Rafflestate.calculating;
        //1.request the RNG
        //2.Get the random number
        i_vrfCoordinator.requestRandomWords(
            i_gaslane, //gas lane
            i_subscriptionId, 
            REQUEST_CONFIRMATIONS, //no.of block confirmations for your random number to be considered to be good
            i_callbackGaslimit,
            NUMWORDS //no,of random numbers
        );

    }

    function fulfillRandomWords(
        uint256 /*requestId*/,
        uint256[] memory randomwords
    ) internal override {
        //checks
        //effects (our own contracts)
        uint256 indexOfWinner = randomwords[0] % s_players.length;
        address  payable Winner = s_players[indexOfWinner];
        s_recentWinner = Winner;
        s_Rafflestate = Rafflestate.open;

        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        //Interactions (Other Contracts)
        (bool success,) = Winner.call{value:address(this).balance}("");
        if(!success){
            revert Raffle_TransferFailed();
        }
        s_Rafflestate = Rafflestate.open;
        emit WinnerPicked(Winner);
        
    }

    /** getter functions of this contract */

    function getEntranceFees() public view returns(uint){
        return i_entranceFee;
    }

    function testing() public {

    }
}
 