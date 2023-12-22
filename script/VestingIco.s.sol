// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";

import {VestingIco} from "../src/VestingIco.sol"; 

import {console} from "forge-std/console.sol";

//In order to run this script: forge script script/VestingIco.s.sol 
//If you want to run this on a real blockchain (testnet or mainnet) simply add --rpc-url yourUrl to the past script 

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY"); 

        vm.startBroadcast(privateKey); 
        VestingIco _contract = new VestingIco(msg.sender); 

        console.log("Contract address is: ", address(_contract)); 
        vm.stopBroadcast();

    }
}
