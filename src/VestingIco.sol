// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ShibaPinu} from "./ShibaPinu.sol";

import "./AggregatorV3Interface.sol";

contract VestingIco{

//events
event PresaleBuy(address indexed buyer, uint256 amount);
 
event Claim(address indexed claimer, uint256 amount); 

//importants variables
address public s_owner; 

bool public isStageOneActive; 

bool public isStageTwoActive; 

bool public isStageThreeActive; 

bool public isButtonClaimActive;

address public shibaPinuAddress; 

uint256 public totalEthFundedOnPresale; 

uint256 public tokenPriceAtStageOne = 5 * 1e15; //   --> equals to a price of 0.005 USDT

uint256 public tokenPriceAtStageTwo = 1 * 1e16;  //  --> equals to a price of 0.01 USDT

uint256 public tokenPriceAtStageThree = 5 * 1e16; // --> equals to a price of 0.05 USDT

uint256 public constant vestingPeriod = 7776000; // --> equals to 30 days

uint256 public s_timestampVesting; 

mapping(address => uint256)public addressToAmountOfTokensBuyedInPresale; 

event VestingClaim(address indexed claimer, uint256 amount);

constructor(address _owner){
s_owner = _owner; 
}

function buyShibaPinuPresaleTokensStageOne()public payable{
require(isStageOneActive == true, "Stage one is not more active"); 
require(isStageTwoActive == false, "Stage two is already active"); 
require(isStageThreeActive == false, "Stage three is already active"); 
require(msg.value > 0, "Value need to be higher than zero"); 
uint256 ethPrice = uint256(returnEthUsdPrice());
uint256 numberOfUsdWhenBuying = msg.value * ethPrice; 
uint256 numberOfTokensBuyed = (numberOfUsdWhenBuying * 1e18) / tokenPriceAtStageOne; 
addressToAmountOfTokensBuyedInPresale[msg.sender] += numberOfTokensBuyed * 1e18; 
totalEthFundedOnPresale = totalEthFundedOnPresale + msg.value; 
emit PresaleBuy(msg.sender, msg.value); 
}

function buyShibaPinuPresaleTokensStageTwo()public payable{
require(isStageOneActive == false, "Stage two is not already active"); 
require(isStageTwoActive == true, "Stage two is not already active"); 
require(isStageThreeActive == false, "Stage three is already active"); 
require(msg.value > 0, "Value need to be higher than zero"); 
uint256 ethPrice = uint256(returnEthUsdPrice());
uint256 numberOfUsdWhenBuying = msg.value * ethPrice; 
uint256 numberOfTokensBuyed = (numberOfUsdWhenBuying * 1e18) / tokenPriceAtStageTwo; 
addressToAmountOfTokensBuyedInPresale[msg.sender] += (numberOfTokensBuyed * 1e18); 
totalEthFundedOnPresale = totalEthFundedOnPresale + msg.value; 
emit PresaleBuy(msg.sender, msg.value); 
}

function buyShibaPinuPresaleTokensStageThree()public payable{
require(isStageOneActive == false, "Stage three is not already active"); 
require(isStageTwoActive == false, "Stage three is not already active"); 
require(isStageThreeActive == true, "Stage three is not already active"); 
require(msg.value > 0, "Value need to be higher than zero"); 
uint256 ethPrice = uint256(returnEthUsdPrice());
uint256 numberOfUsdWhenBuying = msg.value * ethPrice; 
uint256 numberOfTokensBuyed = (numberOfUsdWhenBuying * 1e18) / tokenPriceAtStageThree; 
addressToAmountOfTokensBuyedInPresale[msg.sender] += (numberOfTokensBuyed * 1e18);
totalEthFundedOnPresale = totalEthFundedOnPresale + msg.value;  
emit PresaleBuy(msg.sender, msg.value); 
}

function claimTokensAtEndOfPresale(uint256 amount)public{
require(isStageOneActive == false, "Stage 1 is still open"); 
require(isStageTwoActive == false, "Stage 2 is still open"); 
require(isStageThreeActive == false, "Stage 3 is still open");
require(isButtonClaimActive == true, "Button claim is not active"); 
require((block.timestamp - s_timestampVesting) >=  vestingPeriod, "Vesting period not finished");
require(addressToAmountOfTokensBuyedInPresale[msg.sender] >= amount, "Can't claim tokens"); 
ShibaPinu(shibaPinuAddress).mint(address(this),msg.sender, amount, "canClaim(address,uint256)");
}

function ownerWithdraw(uint256 amount)public{
require(msg.sender == s_owner, "Sender is not the owner"); 
require(amount > 0 && amount <= address(this).balance, "Invalid amount"); 
(bool success, ) = payable(msg.sender).call{value: amount}(""); 
require(success, "TRANSFER FAILED"); 
}

function setStage1Active()public{
require(msg.sender == s_owner , "Sender is  not the owner"); 
isStageOneActive = true; 
}

function setStage1NotActive()public{
require(msg.sender == s_owner , "Sender is  not the owner"); 
isStageOneActive = false; 
}

function setStage2Active()public{
require(msg.sender == s_owner, "Sender is not the owner"); 
isStageTwoActive = true; 
}

function setStage2NotActive()public{
require(msg.sender == s_owner, "Sender is not the owenr"); 
isStageTwoActive = false; 
}

function setStage3Active()public{
require(msg.sender == s_owner, "Sender is not the owner"); 
isStageThreeActive = true; 
}

function setStage3NotActive()public{
require(msg.sender == s_owner, "Sende is not the owner"); 
isStageThreeActive = false; 
}

function setButtonClaimActive()public{
require(isStageOneActive == false, "Stage 1 is active"); 
require(isStageTwoActive == false, "Stage 2 is active"); 
require(isStageThreeActive == false, "Stage 3 is active"); 
require(msg.sender == s_owner, "Sender is not the owner"); 
isButtonClaimActive = true; 
s_timestampVesting = block.timestamp; 
}


function setShibaPinuAddress(address _shibaPinuAddress)public{
require(msg.sender == s_owner, "Sender is not the owner"); 
shibaPinuAddress = _shibaPinuAddress; 
}

function returnNumberOfEthDuringPresale()public view returns(uint256){
return totalEthFundedOnPresale; 
}

function returnUserTokensBuyedInPresale()public view returns(uint256){
return addressToAmountOfTokensBuyedInPresale[msg.sender]; 
}

function returnEthUsdPrice()public view returns(int256){
AggregatorV3Interface aggregator = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306); 
(, int256 answer, , , ) = aggregator.latestRoundData();
return answer / 1e8; 
}

function canClaim(address user, uint256 amount)public view returns(bool){
require(isStageOneActive == false, "Stage 1 is still open"); 
require(isStageTwoActive == false, "Stage 2 is still open"); 
require(isStageThreeActive == false, "Stage 3 is still open");
require(isButtonClaimActive == true, "Button claim is not active"); 
require((block.timestamp - s_timestampVesting) >  vestingPeriod, "Vesting period not finished");
if(addressToAmountOfTokensBuyedInPresale[user] >= amount){
return true; 
}else{
return false;
}
}

}