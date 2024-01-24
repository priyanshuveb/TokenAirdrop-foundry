// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TestToken} from "../src/TestToken.sol";

contract DeployTestToken is Script {

    function run(string memory name, string memory symbol, uint256 amount, uint8 decimal) public returns(TestToken) {
        vm.startBroadcast();
        TestToken testToken = new TestToken(name,symbol,amount,decimal);
        vm.stopBroadcast();
        return testToken;
    }
}
