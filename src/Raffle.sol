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
contract Raffl is VRFConsumerBaseV2{

    error Raffle__NotEnoughEthSent();
    error SendingPriceMoney_failed();

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

    event enteredRaffle(address indexed player);

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
    }


    function enterRaffle() external  payable {
        if(msg.value <= i_entranceFee){
            revert Raffle__NotEnoughEthSent();
        }
        s_players.push(payable(msg.sender));
        emit enteredRaffle(msg.sender);

    }
    /** 1.Get the number automatically from chainlink VRF
     * 2.Use the random number to pick a winner 
     * 3.Be automatically called
     */
    function pickWinner() public {
        if((block.timestamp - s_lastTimeStamp) < i_interval){
            revert();
        }
        //1.request the RNG
        //2.Get the random number
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gaslane, //gas lane
            i_subscriptionId, 
            REQUEST_CONFIRMATIONS, //no.of block confirmations for your random number to be considered to be good
            i_callbackGaslimit,
            NUMWORDS //no,of random numbers
        );

    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomwords
    ) internal override {

        uint256 indexOfWinner = randomwords[0] % s_players.length;
        address  payable Winner = s_players[indexOfWinner];
        s_recentWinner = Winner;
        (bool success,) = Winner.call{value:address(this).balance}("");
        if(!success){
            revert SendingPriceMoney_failed();
        }
        
    }

    /** getter functions of this contract */

    function getEntranceFees() public view returns(uint){
        return i_entranceFee;
    }

    function testing() public {
        
    }
}