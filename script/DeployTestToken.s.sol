// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TestToken} from "../src/TestToken.sol";

contract DeployTestToken is Script {

    function run() public returns(address) {
        vm.startBroadcast();
        TestToken testToken = new TestToken("Test","TST",700000);
        vm.stopBroadcast();
        return address(testToken);
    }
}
