// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

import {VestingIco} from "../src/VestingIco.sol"; 

import {console} from "forge-std/console.sol";

import {ShibaPinu} from "../src/ShibaPinu.sol";

//In order to test this: forge test --fork-url https://eth-sepolia.g.alchemy.com/v2/Z4iZqIYn02E4azjwQ6-utMqyFgY6ZSUX --match-path test/ShibaPinu.t.sol -vvv

contract ShibaPinuTest is Test{

error AddressNotAccepted(address _address); 

ShibaPinu public _ERC20Contract;

VestingIco public _contract; 

function setUp()public{
_ERC20Contract = new ShibaPinu(address(1));
_contract = new VestingIco(address(1)); 
}

//TEST ADD ALLOWED COLLATERAL
function test_pushAllowedContract()public{
vm.startPrank(address(1));
_ERC20Contract.addAddressAllowed(address(_contract)); 
}

function testFail_pushAllowedContractNotTheOwner()public{
vm.startPrank(address(10));
_ERC20Contract.addAddressAllowed(address(_contract)); 
}

function testFail_pushAllowedContractAlreadyExistent()public{
vm.startPrank(address(1));
_ERC20Contract.addAddressAllowed(address(_contract)); 
_ERC20Contract.addAddressAllowed(address(_contract)); 
}


//TEST CAN MINT
function testFail_canMintFalse()public{
vm.startPrank(address(1));
_ERC20Contract.addAddressAllowed(address(_contract)); 
_ERC20Contract.addAcceptedSignature(address(_contract), "canClaim(address,uint256)"); 
bool result = _ERC20Contract.canMint(address(_contract), address(2), 10,"canClaim(address,uint256)"); 
console.log(result); 
}

function testFail_canMintBadContract()public{
vm.startPrank(address(1));
_ERC20Contract.addAddressAllowed(address(_contract)); 
_ERC20Contract.canMint(address(10), address(2), 10,"canClaim(address,uint256)"); 
}

function test_mintTokenIfPossible()public{
vm.startPrank(address(1));
_ERC20Contract.addAddressAllowed(address(_contract));
_ERC20Contract.addAcceptedSignature(address(_contract), "canClaim(address,uint256)"); 
_contract.setShibaPinuAddress(address(_ERC20Contract)); 
_contract.setStage3Active(); 
_contract.buyShibaPinuPresaleTokensStageThree{value: 5}();
_contract.setStage3NotActive(); 
_contract.setButtonClaimActive(); 
skip(7776001);
_ERC20Contract.mint(address(_contract), address(1), _contract.returnUserTokensBuyedInPresale()/ 2, "canClaim(address,uint256)"); 
console.log("User minted a part of the tokens buyed in presale, now his ERC20 balance is:  ", _ERC20Contract.balanceOf(address(1))); 
vm.stopPrank();
}

function test_mintTokenIfPossibleMultplesTimes()public{
vm.startPrank(address(1));
_ERC20Contract.addAddressAllowed(address(_contract));
_ERC20Contract.addAcceptedSignature(address(_contract), "canClaim(address,uint256)"); 
_contract.setShibaPinuAddress(address(_ERC20Contract)); 
_contract.setStage3Active(); 
_contract.buyShibaPinuPresaleTokensStageThree{value: 5}();
_contract.setStage3NotActive(); 
_contract.setButtonClaimActive(); 
skip(7776001);
_ERC20Contract.mint(address(_contract), address(1), _contract.returnUserTokensBuyedInPresale()/ 2, "canClaim(address,uint256)"); 
_ERC20Contract.mint(address(_contract), address(1), _contract.returnUserTokensBuyedInPresale()/ 2, "canClaim(address,uint256)"); 
console.log("User minted all the tokens he buyed in presale, now his ERC20 balance is:  ", _ERC20Contract.balanceOf(address(1))); 
vm.stopPrank();
}

//TEST ADD ACCEPTED SIGNATURE
function test_AddAcceptedSignature()public{
vm.startPrank(address(1));
_ERC20Contract.addAcceptedSignature(address(_contract), "canClaim(address,uint256)");
assertEq(_ERC20Contract.returnSignatureAllowed(address(_contract)), "canClaim(address,uint256)"); 
}

function testFail_AcceptedSignatureNotTheOwner()public{
vm.startPrank(address(10));
_ERC20Contract.addAcceptedSignature(address(_contract), "canClaim(address,uint256)");
}
}