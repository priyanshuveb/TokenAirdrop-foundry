// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {TestToken} from "../src/TestToken.sol";

contract Interactions is Script {
    TestToken testToken;
    function run() public {
        testToken = TestToken(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        getTotalSupply();
    }

    function getTotalSupply() public view {
        uint256 totalSupply = testToken.totalSupply();
        console.log('total supply %s',totalSupply);
    }

    function getBalanceOf(address user) public view {
        uint256 balance = testToken.balanceOf(user);
        console.log('balance of user %s is %s',user,balance);
    }
}