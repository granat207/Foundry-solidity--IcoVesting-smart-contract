// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

import {VestingIco} from "../src/VestingIco.sol"; 

import {console} from "forge-std/console.sol";

import {ShibaPinu} from "../src/ShibaPinu.sol";

//In order to test this: forge test --fork-url (select your url) --match-path test/VestingIco.t.sol -vvv

contract CounterTest is Test {
    
    VestingIco public _contract;

    ShibaPinu public token; 

    event PresaleBuy(address indexed buyer, uint256 amount); 

    event Claim(address indexed claimer, uint256 amount); 

    function setUp() public {
    token = new ShibaPinu(address(1));
    _contract = new VestingIco(address(1));
    }

    function test_checkOwnerAtStart()public{
    address owner = _contract.s_owner(); 
    assertEq(owner, (address(1))); 
    }

    function test_Stage1StateAtStart()public{
    bool isStage1Active = _contract.isStageOneActive();
    assertEq(isStage1Active, false); 
    }

    function test_Stage2StateAtStart()public{
    bool isStage2Active = _contract.isStageTwoActive();
    assertEq(isStage2Active, false); 
    }

    function test_Stage3StateAtStart()public{
    bool isStage3Active = _contract.isStageThreeActive();
    assertEq(isStage3Active, false); 
    }

    function test_shibaPinuAddressAtStart()public{
    address shibaPinu = _contract.shibaPinuAddress(); 
    assertEq(shibaPinu, 0x0000000000000000000000000000000000000000); 
    }

    function test_totalNumberOfEthFundedAtStart()public{
    uint256 numberOfEth = _contract.returnNumberOfEthDuringPresale(); 
    assertEq(numberOfEth, 0); 
    }
    

    //This should be 0.005
    function test_ShibaPinuPriceAtStage1()public view{
    uint256 priceStage1 = _contract.tokenPriceAtStageOne(); 
    console.log(priceStage1); 
    }

    //This should be 0.01
    function test_ShibaPinuPriceAtStage2()public view{
    uint256 priceStage2 = _contract.tokenPriceAtStageTwo(); 
    console.log(priceStage2); 
    }

    //This should be 0.05
    function test_ShibaPinuPriceAtStage3()public view{
    uint256 priceStage3 = _contract.tokenPriceAtStageThree(); 
    console.log(priceStage3); 
    }


    function test_vestingPeriodAtStart()public{
    uint256 period = _contract.vestingPeriod(); 
    assertEq(period, 7776000); 
    }

    function test_timestampVestingAtStart()public{
    uint256 timestamp = _contract.s_timestampVesting(); 
    assertEq(timestamp, 0); 
    }


    //This should returns the correct price of eth/usd
    function test_V3AggregatorPrice()public view{
    int256 price = _contract.returnEthUsdPrice();
    console.logInt(price); 
    }

    //After the owner set the stage 1 active, the bool should uptades to true
    function test_SetStage1Active()public{
    vm.prank(address(1));
    _contract.setStage1Active(); 
    assertEq(_contract.isStageOneActive(), true); 
    }

    //If anyone(that is not the owner) calls the setStage1Active function it should reverts
    function testFail_SetStage1ActiveNotTheOwner()public{
    vm.prank(address(2));
    _contract.setStage1Active(); 
    }


    //After the owner set the stage 1 not active, the bool should uptades to false
    function test_SetStage1NotActive()public{
    vm.startPrank(address(1));
    _contract.setStage1Active(); 
    _contract.setStage1NotActive(); 
    vm.stopPrank();
    assertEq(_contract.isStageOneActive(), false); 
    }


    //If anyone(that is not the owner) calls the setStage1NotActive function it should reverts
    function testFail_SetStage1NotActiveNotTheOwner()public{
    vm.prank(address(2));
    _contract.setStage1Active(); 
    _contract.setStage1NotActive(); 
    }


    //After the owner set the stage 2 active, the bool should uptades to true
    function test_SetStage2Active()public{
    vm.prank(address(1));
    _contract.setStage2Active(); 
    assertEq(_contract.isStageTwoActive(), true); 
    }

    //If anyone(that is not the owner) calls the setStage2Active function it should reverts
    function testFail_SetStage2ActiveNotTheOwner()public{
    vm.prank(address(2));
    _contract.setStage2Active(); 
    }


    //After the owner set the stage 2 not active, the bool should uptades to false
    function test_SetStage2NotActive()public{
    vm.startPrank(address(1));
    _contract.setStage2Active(); 
    _contract.setStage2NotActive(); 
    vm.stopPrank();
    assertEq(_contract.isStageTwoActive(), false); 
    }


    //If anyone(that is not the owner) calls the setStage2NotActive function it should reverts
    function testFail_SetStage2NotActiveNotTheOwner()public{
    vm.prank(address(2));
    _contract.setStage2Active(); 
    _contract.setStage2NotActive(); 
    }


     //After the owner set the stage 3 active, the bool should uptades to true
    function test_SetStage3Active()public{
    vm.prank(address(1));
    _contract.setStage3Active(); 
    assertEq(_contract.isStageThreeActive(), true); 
    }

    //If anyone(that is not the owner) calls the setStage3Active function it should reverts
    function testFail_SetStage3ActiveNotTheOwner()public{
    vm.prank(address(2));
    _contract.setStage3Active(); 
    }


    //After the owner set the stage 3 not active, the bool should uptades to false
    function test_SetStage3NotActive()public{
    vm.startPrank(address(1));
    _contract.setStage3Active(); 
    _contract.setStage3NotActive(); 
    vm.stopPrank();
    assertEq(_contract.isStageThreeActive(), false); 
    }


    //If anyone(that is not the owner) calls the setStage3NotActive function it should reverts
    function testFail_SetStage3NotActiveNotTheOwner()public{
    vm.prank(address(2));
    _contract.setStage3Active(); 
    _contract.setStage3NotActive(); 
    }

    //Can set the claim button active if all the stages are not active and if the msg.sender is the owner
    function test_setClaimActive()public{
    vm.startPrank(address(1));
    _contract.setStage1Active(); 
    _contract.setStage1NotActive(); 
    _contract.setStage2Active();
    _contract.setStage2NotActive();
    _contract.setStage3Active();
    _contract.setStage3NotActive(); 
    _contract.setButtonClaimActive(); 
    vm.stopPrank(); 
    assertEq(_contract.isButtonClaimActive(), true); 
    }

    //Can't set the claim active if the sender is not the owner
    function test_setClaimActiveNotTheOwner()public{
     vm.startPrank(address(1));
    _contract.setStage1Active(); 
    _contract.setStage1NotActive(); 
    _contract.setStage2Active();
    _contract.setStage2NotActive();
    _contract.setStage3Active();
    _contract.setStage3NotActive(); 
    _contract.setButtonClaimActive(); 
    vm.stopPrank(); 
    vm.startPrank(address(2));
    vm.expectRevert("Sender is not the owner"); 
    _contract.setButtonClaimActive();
    vm.stopPrank();
    }

    //Can't set claim active button active if the stage 1 is active
    function test_setClaimActiveStage1Active()public{
     vm.startPrank(address(1));
    _contract.setStage1Active(); 
    _contract.setStage2Active();
    _contract.setStage2NotActive();
    _contract.setStage3Active();
    _contract.setStage3NotActive(); 
    vm.expectRevert("Stage 1 is active");
    _contract.setButtonClaimActive(); 
    vm.stopPrank(); 
    }

    //Can't set claim active button active if the stage 2 is active
    function test_setClaimActiveStage2Active()public{
     vm.startPrank(address(1));
    _contract.setStage1Active();
    _contract.setStage1NotActive(); 
    _contract.setStage2Active();
    _contract.setStage3Active();
    _contract.setStage3NotActive(); 
    vm.expectRevert("Stage 2 is active");
    _contract.setButtonClaimActive(); 
    vm.stopPrank(); 
    }

    //Can't set claim active button active if the stage 3 is active
    function test_setClaimActiveStage3Active()public{
     vm.startPrank(address(1));
    _contract.setStage1Active();
    _contract.setStage1NotActive(); 
    _contract.setStage2Active();
    _contract.setStage2NotActive();
    _contract.setStage3Active(); 
    vm.expectRevert("Stage 3 is active");
    _contract.setButtonClaimActive(); 
    vm.stopPrank(); 
    }

    //Can set correctly the shiba pinu address
    function test_setShibaPinuAddress()public{
    vm.startPrank(address(1));
    _contract.setShibaPinuAddress(address(token));
    vm.stopPrank(); 
    assertEq(_contract.shibaPinuAddress(), address(token)); 
    }

    //INVARIANTS TESTS 
    function invariant_testingOwner()public{
    assertEq(_contract.s_owner(), address(1)); 
    }

    function invariant_testingTokenPriceStage1()public{
    assertEq(_contract.tokenPriceAtStageOne(),  5 * 1e15); 
    }

    function invariant_testingTokenPriceStage2()public{
    assertEq(_contract.tokenPriceAtStageTwo(),  1 * 1e16); 
    }

    function invariant_testingTokenPriceStage3()public{
    assertEq(_contract.tokenPriceAtStageThree(),  5 * 1e16); 
    }

    function invariant_testingVestingPeriod() public{
    assertEq(_contract.vestingPeriod(), 7776000); 
    }


    //Can buy in the presale at stage 1 with any amount
    function test_buyShibaPinuAtStage1(uint256 amount)public{
    vm.startPrank(address(1));
    _contract.setStage1Active(); 
     vm.stopPrank();
     amount = bound(amount, 1, 1000); 
    _contract.buyShibaPinuPresaleTokensStageOne{value: amount}();
     }
   
    //After buying in the first stage the amount of tokens buyed should be correct
    function test_buyShibaPinuAtStage1TokensBuyed()public{
    vm.startPrank(address(1));
    _contract.setStage1Active(); 
    vm.stopPrank();
    _contract.buyShibaPinuPresaleTokensStageOne{value: 5}();
    console.log("User buyed", (_contract.returnUserTokensBuyedInPresale()) / 1e18, "tokens"); 
    }

    //After buying in the first stage the amount of eth funded should be well displayed
    function test_buyShibaPinuAtStage1EthDisplayed()public{
    vm.startPrank(address(1));
    _contract.setStage1Active(); 
    vm.stopPrank();
    _contract.buyShibaPinuPresaleTokensStageOne{value: 5}();
    console.log("Eth funded:", _contract.returnNumberOfEthDuringPresale()); 
    }

    function test_emitsWhenBuyingInTheFirstStage()public{
    vm.startPrank(address(1));
    _contract.setStage1Active(); 
    vm.expectEmit(true, true, true, false);
    emit PresaleBuy(address(1), 5);
    _contract.buyShibaPinuPresaleTokensStageOne{value: 5}();
    vm.stopPrank(); 
    }

    //User should be able to buy multiples times in stage 1
    function test_canBuyMultiplesTimesInStage1()public{
    vm.startPrank(address(1));
    _contract.setStage1Active(); 
    _contract.buyShibaPinuPresaleTokensStageOne{value: 5}();
    _contract.buyShibaPinuPresaleTokensStageOne{value: 10}(); 
    _contract.buyShibaPinuPresaleTokensStageOne{value: 100}(); 
    vm.stopPrank(); 
    }

    //If the buyShibaPinuAtStage1 function is called when the stage 1 is not active it should revert
    function test_buyShibaPinuStage1WhenStage1IsActive()public{
    vm.startPrank(address(1));
    vm.expectRevert("Stage one is not more active");
    _contract.buyShibaPinuPresaleTokensStageOne{value: 100}();
    }

    //If the buyShibaPinuAtStage1 function is called when the stage 2 is active it should revert
    function test_buyShibaPinuStage1WhenStage2IsActive()public{
    vm.startPrank(address(1));
    _contract.setStage1Active(); 
    _contract.setStage2Active();
    vm.expectRevert("Stage two is already active");
    _contract.buyShibaPinuPresaleTokensStageOne{value: 100}();
    }

    //If the buyShibaPinuAtStage1  function is called when the stage 3 is active it should revert
    function test_buyShibaPinuStage1WhenStage3IsActivee()public{
    vm.startPrank(address(1));
    _contract.setStage1Active(); 
    _contract.setStage3Active();
    vm.expectRevert("Stage three is already active");
    _contract.buyShibaPinuPresaleTokensStageOne{value: 100}();
    }

    //If the buyShibaPinuAtStage1 function is called with an amount of 0 it should reverts
    function test_buyShibapinuStage1AmountZero()public{
    vm.startPrank(address(1));
    _contract.setStage1Active(); 
    vm.expectRevert("Value need to be higher than zero");
    _contract.buyShibaPinuPresaleTokensStageOne{value: 0}(); 
    }

    //Can buy in the presale at stage 2 with any amount
    function test_buyShibaPinuAtStage2(uint256 amount)public{
    vm.startPrank(address(1));
    _contract.setStage2Active(); 
     vm.stopPrank();
     amount = bound(amount, 1, 1000); 
    _contract.buyShibaPinuPresaleTokensStageTwo{value: amount}();
     }
   
    //After buying in the second stage the amount of tokens buyed should be correct
    function test_buyShibaPinuAtStage2TokensBuyed()public{
    vm.startPrank(address(1));
    _contract.setStage2Active(); 
    vm.stopPrank();
    _contract.buyShibaPinuPresaleTokensStageTwo{value: 5}();
    console.log("User buyed", (_contract.returnUserTokensBuyedInPresale()) / 1e18, "tokens in stage 2"); 
    }

    //After buying in the second stage the amount of eth funded should be well displayed
    function test_buyShibaPinuAtStage2EthDisplayed()public{
    vm.startPrank(address(1));
    _contract.setStage2Active(); 
    vm.stopPrank();
    _contract.buyShibaPinuPresaleTokensStageTwo{value: 5}();
    console.log("Eth funded:", _contract.returnNumberOfEthDuringPresale()); 
    }

    function test_emitsWhenBuyingInTheSecondStage()public{
    vm.startPrank(address(1));
    _contract.setStage2Active(); 
    vm.expectEmit(true, true, true, false);
    emit PresaleBuy(address(1), 5);
    _contract.buyShibaPinuPresaleTokensStageTwo{value: 5}();
    vm.stopPrank(); 
    }

    //User should be able to buy multiples times in stage 2
    function test_canBuyMultiplesTimesInStage2()public{
    vm.startPrank(address(1));
    _contract.setStage2Active(); 
    _contract.buyShibaPinuPresaleTokensStageTwo{value: 5}();
    _contract.buyShibaPinuPresaleTokensStageTwo{value: 10}(); 
    _contract.buyShibaPinuPresaleTokensStageTwo{value: 100}(); 
    vm.stopPrank(); 
    }

    //If the buyShibaPinuAtStage2 function is called when the stage 1 is active it should revert
    function test_buyShibaPinuStage2WhenStage1IsActive()public{
    vm.startPrank(address(1));
    vm.expectRevert("Stage two is not already active");
    _contract.buyShibaPinuPresaleTokensStageTwo{value: 100}();
    }

    //If the buyShibaPinuAtStage2 function is called when the stage 3 is active it should revert
    function test_buyShibaPinuStage1WhenStage3IsActive()public{
    vm.startPrank(address(1));
    _contract.setStage2Active(); 
    _contract.setStage3Active();
    vm.expectRevert("Stage three is already active");
    _contract.buyShibaPinuPresaleTokensStageTwo{value: 100}();
    }

    //If the buyShibaPinuAtStage2  function is called when the stage 2 is not active it should revert
    function test_buyShibaPinuStage1WhenStage2IsNotActive()public{
    vm.startPrank(address(1));
    vm.expectRevert("Stage two is not already active");
    _contract.buyShibaPinuPresaleTokensStageTwo{value: 100}();
    }

    //If the buyShibaPinuAtStage2 function is called with an amount of 0 it should reverts
    function test_buyShibapinuStage2AmountZero()public{
    vm.startPrank(address(1));
    _contract.setStage2Active(); 
    vm.expectRevert("Value need to be higher than zero");
    _contract.buyShibaPinuPresaleTokensStageTwo{value: 0}(); 
    }


    //Can buy in the presale at stage 3 with any amount
    function test_buyShibaPinuAtStage3(uint256 amount)public{
    vm.startPrank(address(1));
    _contract.setStage3Active(); 
     vm.stopPrank();
     amount = bound(amount, 1, 1000); 
    _contract.buyShibaPinuPresaleTokensStageThree{value: amount}();
     }
   
    //After buying in the third stage the amount of tokens buyed should be correct
    function test_buyShibaPinuAtStage3TokensBuyed()public{
    vm.startPrank(address(1));
    _contract.setStage3Active(); 
    vm.stopPrank();
    _contract.buyShibaPinuPresaleTokensStageThree{value: 5}();
    console.log("User buyed", (_contract.returnUserTokensBuyedInPresale()) / 1e18, "tokens in stage 3"); 
    }

    //After buying in the third stage the amount of eth funded should be well displayed
    function test_buyShibaPinuAtStage3EthDisplayed()public{
    vm.startPrank(address(1));
    _contract.setStage3Active(); 
    vm.stopPrank();
    _contract.buyShibaPinuPresaleTokensStageThree{value: 5}();
    console.log("Eth funded:", _contract.returnNumberOfEthDuringPresale()); 
    }

    function test_emitsWhenBuyingInTheThirdStage()public{
    vm.startPrank(address(1));
    _contract.setStage3Active(); 
    vm.expectEmit(true, true, true, false);
    emit PresaleBuy(address(1), 5);
    _contract.buyShibaPinuPresaleTokensStageThree{value: 5}();
    vm.stopPrank(); 
    }

    //User should be able to buy multiples times in stage 3
    function test_canBuyMultiplesTimesInStage3()public{
    vm.startPrank(address(1));
    _contract.setStage3Active(); 
    _contract.buyShibaPinuPresaleTokensStageThree{value: 5}();
    _contract.buyShibaPinuPresaleTokensStageThree{value: 10}(); 
    _contract.buyShibaPinuPresaleTokensStageThree{value: 100}(); 
    vm.stopPrank(); 
    }

    //If the buyShibaPinuAtStage3 function is called when the stage 1 is active it should revert
    function test_buyShibaPinuStage3WhenStage1IsActive()public{
    vm.startPrank(address(1));
    _contract.setStage1Active();
    vm.expectRevert("Stage three is not already active");
    _contract.buyShibaPinuPresaleTokensStageThree{value: 100}();
    }

    //If the buyShibaPinuAtStage3 function is called when the stage 2 is active it should revert
    function test_buyShibaPinuStage3WhenStage2IsActive()public{
    vm.startPrank(address(1));
    _contract.setStage2Active(); 
    _contract.setStage3Active();
    vm.expectRevert("Stage three is not already active");
    _contract.buyShibaPinuPresaleTokensStageThree{value: 100}();
    }

    //If the buyShibaPinuAtStage3  function is called when the stage 3 is not active it should revert
    function test_buyShibaPinuStage1WhenStage2IsNotActiveActive()public{
    vm.startPrank(address(1));
    vm.expectRevert("Stage three is not already active");
    _contract.buyShibaPinuPresaleTokensStageThree{value: 100}();
    }

    //If the buyShibaPinuAtStage3 function is called with an amount of 0 it should reverts
    function test_buyShibapinuStage3AmountZero()public{
    vm.startPrank(address(1));
    _contract.setStage3Active(); 
    vm.expectRevert("Value need to be higher than zero");
    _contract.buyShibaPinuPresaleTokensStageThree{value: 0}(); 
    }


    //OWNER WITHDRAW FUNCTION

    //Owner can withdraw eth from smart contract
    function test_ownerCanWithdrawEth()public{
    vm.startPrank(address(1)); 
    _contract.setStage1Active(); 
    vm.stopPrank(); 
    vm.startPrank(address(100));
    _contract.buyShibaPinuPresaleTokensStageOne{value: 1}(); 
    vm.stopPrank(); 
    console.log("The total amount of eth funded to the contract is:", _contract.totalEthFundedOnPresale()); 
    vm.startPrank(address(1)); 
    uint256 ownerBalanceBeforeWithdraw = address(1).balance; 
    _contract.ownerWithdraw(1); 
    console.log("After the withdraw of 1 eth from the owner, the total amount of eth in the contract is:", address(_contract).balance);
    assertEq(ownerBalanceBeforeWithdraw + 1, address(1).balance); 
    }

    //If the withdrawFunction is called when the sender is not the owner it should revert
    function test_notTheOwnerCantWithdraw()public{
    vm.startPrank(address(100)); 
    vm.expectRevert("Sender is not the owner");
    _contract.ownerWithdraw(1); 
    }

    //If the withdrawFunction is called with an amount of 0 it should reverts
    function test_withdraw0Amount()public{
    vm.startPrank(address(1));
    _contract.setStage1Active(); 
    _contract.buyShibaPinuPresaleTokensStageOne{value: 1}(); 
    vm.expectRevert("Invalid amount");
    _contract.ownerWithdraw(0); 
    }

    //If the withdrawFunction is called with higher than the contract balance it should reverts
    function test_withdrawOutOfAmount()public{
    vm.startPrank(address(1));
    _contract.setStage1Active();
    _contract.buyShibaPinuPresaleTokensStageOne{value: 10}(); 
    vm.expectRevert("Invalid amount");
    _contract.ownerWithdraw(11);
    }

    //CLAIM TOKENS

    //User can't claim tokens if stage 1 is active
    function test_cantClaimTokenIfStage1Active()public{
    vm.startPrank(address(1));
    _contract.setStage1Active(); 
    vm.stopPrank(); 
    vm.startPrank((address(100)));
    vm.expectRevert("Stage 1 is still open"); 
    _contract.canClaim(msg.sender, 10);
    }

     //User can't claim tokens if stage 2 is active
    function test_cantClaimTokenIfStage2Active()public{
    vm.startPrank(address(1));
    _contract.setStage2Active(); 
    vm.stopPrank(); 
    vm.startPrank((address(100)));
    vm.expectRevert("Stage 2 is still open"); 
    _contract.canClaim(msg.sender, 10);
    }

     //User can't claim tokens if stage 3 is active
    function test_cantClaimTokenIfStage3Active()public{
    vm.startPrank(address(1));
    _contract.setStage3Active(); 
    vm.stopPrank(); 
    vm.startPrank((address(100)));
    vm.expectRevert("Stage 3 is still open"); 
    _contract.canClaim(msg.sender, 10);
    }

    //User can't claim tokens if the the claim button is not active
    function test_cantClaimTokensIfClaimIsNotActive()public{
    vm.startPrank(address(1)); 
    vm.expectRevert("Button claim is not active");
    _contract.canClaim(msg.sender, 10);
    }

    //User can't claim tokens if vesting period is not over
    function test_cantClaimTokensWithVestingPeriodNotOver()public{
    vm.startPrank(address(1)); 
    _contract.setButtonClaimActive(); 
    vm.expectRevert("Vesting period not finished");
    _contract.canClaim(msg.sender, 10);
    }


    //User can't claim tokens if he did not buyed in the presale
    function test_cantClaimTokensifUserDidNotBuyedInPresale()public{
    vm.startPrank(address(1)); 
    _contract.setButtonClaimActive(); 
    skip(7776001);
    vm.expectRevert("Can't claim tokens");
    _contract.claimTokensAtEndOfPresale(10);
    }    

     //User can't claim tokens if the amount is higher than the mintable amount
    function testFail_cantClaimTokensifAmountIsHigherThanTheMintableAmount()public{
    vm.startPrank(address(1));
     token.addAddressAllowed(address(_contract));
     token.addAcceptedSignature(address(_contract), "canClaim(address,uint256)"); 
    _contract.setShibaPinuAddress(address(token)); 
    _contract.setStage3Active(); 
    _contract.buyShibaPinuPresaleTokensStageThree{value: 5}();
    _contract.setStage3NotActive(); 
    _contract.setButtonClaimActive(); 
    skip(7776001);
    _contract.claimTokensAtEndOfPresale(_contract.returnUserTokensBuyedInPresale() + 100); 
    }    


    //User can't claim tokens if the amount is higher than the mintable amount 2
    function testFail_cantClaimTokensifAmountIsHigherThanTheMintableAmount2()public{
    vm.startPrank(address(1)); 
     token.addAddressAllowed(address(_contract));
     token.addAcceptedSignature(address(_contract), "canClaim(address,uint256)"); 
    _contract.setShibaPinuAddress(address(token)); 
    _contract.setStage3Active(); 
    _contract.buyShibaPinuPresaleTokensStageThree{value: 5}();
    _contract.setStage3NotActive(); 
    _contract.setButtonClaimActive(); 
    skip(7776001);
    _contract.claimTokensAtEndOfPresale(_contract.returnUserTokensBuyedInPresale() / 2); 
    _contract.claimTokensAtEndOfPresale(_contract.returnUserTokensBuyedInPresale()); 
    }    


    //User can't claim tokens if the amount is higher than the mintable amount 3
    function testFail_cantClaimTokensifAmountIsHigherThanTheMintableAmount3()public{
    vm.startPrank(address(1)); 
     token.addAddressAllowed(address(_contract));
     token.addAcceptedSignature(address(_contract), "canClaim(address,uint256)"); 
    _contract.setShibaPinuAddress(address(token)); 
    _contract.setStage3Active(); 
    _contract.buyShibaPinuPresaleTokensStageThree{value: 5}();
    _contract.setStage3NotActive(); 
    _contract.setButtonClaimActive(); 
    skip(7776001);
    _contract.claimTokensAtEndOfPresale(_contract.returnUserTokensBuyedInPresale() / 2); 
    _contract.claimTokensAtEndOfPresale((_contract.returnUserTokensBuyedInPresale()  / 2) + 500); 
    }    


    //User can claim tokens 1
    function test_canClaimTokens1()public{
    vm.startPrank(address(1)); 
     token.addAddressAllowed(address(_contract));
     token.addAcceptedSignature(address(_contract), "canClaim(address,uint256)"); 
    _contract.setShibaPinuAddress(address(token)); 
    _contract.setStage3Active(); 
    _contract.buyShibaPinuPresaleTokensStageThree{value: 5}();
    _contract.setStage3NotActive(); 
    _contract.setButtonClaimActive(); 
    skip(7776001);
    _contract.claimTokensAtEndOfPresale(10); 
    }    

    //User can claim tokens multiples times
    function test_canClaimTokensMultiplesTimes()public{
    vm.startPrank(address(1)); 
     token.addAddressAllowed(address(_contract));
     token.addAcceptedSignature(address(_contract), "canClaim(address,uint256)"); 
    _contract.setShibaPinuAddress(address(token)); 
    _contract.setStage3Active(); 
    _contract.buyShibaPinuPresaleTokensStageThree{value: 5}();
    _contract.setStage3NotActive(); 
    _contract.setButtonClaimActive(); 
    skip(7776001);
    _contract.claimTokensAtEndOfPresale(_contract.returnUserTokensBuyedInPresale() / 2); 
    _contract.claimTokensAtEndOfPresale(_contract.returnUserTokensBuyedInPresale() / 2); 
    console.log("The amount of SB tokens after the claim should be around 225.000 (with an eth price of 2250) and it is ", (token.balanceOf(address(1))) / 1e18); 
    }    

    //User can claim tokens and return the correct balance
    function test_canClaimTokensCorrectBalance()public{
    vm.startPrank(address(1)); 
     token.addAddressAllowed(address(_contract));
     token.addAcceptedSignature(address(_contract), "canClaim(address,uint256)"); 
    _contract.setShibaPinuAddress(address(token)); 
    _contract.setStage3Active(); 
    _contract.buyShibaPinuPresaleTokensStageThree{value: 5}();
    _contract.setStage3NotActive(); 
    _contract.setButtonClaimActive(); 
    skip(7776001);
    console.log("The amount of SB tokens before the claim is ", token.balanceOf(address(1))); 
    _contract.claimTokensAtEndOfPresale(_contract.returnUserTokensBuyedInPresale()); 
    console.log("The amount of SB tokens after the claim should be around 225.000 (with an eth price of 2250) and it is ", (token.balanceOf(address(1))) / 1e18); 
    }    

    //After the claim of the tokens, the mapping of the tokens minted should be well displayed on the ERC20 contract 1
    function test_canClaimTokensAndTokensMintedAreShowedCorrectly()public{
    vm.startPrank(address(1));
    token.addAddressAllowed(address(_contract));
    token.addAcceptedSignature(address(_contract), "canClaim(address,uint256)"); 
    _contract.setShibaPinuAddress(address(token)); 
    _contract.setStage3Active(); 
    _contract.buyShibaPinuPresaleTokensStageThree{value: 5}();
    _contract.setStage3NotActive(); 
    _contract.setButtonClaimActive(); 
    skip(7776001);
    _contract.claimTokensAtEndOfPresale(_contract.returnUserTokensBuyedInPresale()); 
    uint256 tokensMinted = token.returnTokensMinted(address(_contract));
    vm.stopPrank();
    console.log("The number of user tokens minted displayed on the ERC20 contract should be around 225.000 (with an eth price of 2250) and it is ", tokensMinted / 1e18); 
    }    
    
}
