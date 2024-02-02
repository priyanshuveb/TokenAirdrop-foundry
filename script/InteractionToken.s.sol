// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {TestToken} from "../src/TestToken.sol";

contract TokenInstance {
    TestToken testToken = TestToken(0x94B46C7fE53Bac1Bbb94FA980975F53Bc7DF5F8D);
}

contract GetBalance is Script, TokenInstance {
    function run() public view returns (uint256) {
        return getBalance(msg.sender);
    }

    function getBalance(address user) public view returns (uint256) {
        uint256 balance = testToken.balanceOf(user);
        return balance;
    }
}

contract MintTokens is Script, TokenInstance {
    uint256 amount = 1 * 10 ** 8;

    function run() public {
        mint();
    }

    function mint() internal {
        vm.startBroadcast();
        testToken.mint(amount);
        vm.stopBroadcast();
    }
}

contract BurnTokens is Script, TokenInstance {
    uint256 amount = 1 * 10 ** 7;

    function run() external {
        burn();
    }

    function burn() internal {
        vm.startBroadcast();
        testToken.burn(amount);
        vm.stopBroadcast();
    }
}

contract Transfer is Script, TokenInstance {
    address to = 0xC6ad6C00877a05a0ac1BBD456e31792c6b561F8D;
    uint256 amount = 43 * 10 ** 2;

    function run() external {
        transfer();
    }

    function transfer() internal {
        vm.startBroadcast();
        testToken.transfer(to, amount);
        vm.stopBroadcast();
    }
}

contract GiveAllowanceToAirdropContract is Script, TokenInstance {
    uint256 amount = 1*10**8;
    address to = 0xd3E5c6b50f1e7B36Ce2923f3f72a2B01172282eC;
    function run() external {
        giveAllowance();
    }

    function giveAllowance() internal {
        vm.broadcast();
        testToken.approve(to, amount);
    }
}
