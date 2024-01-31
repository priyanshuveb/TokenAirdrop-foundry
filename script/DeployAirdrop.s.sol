// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Airdrop} from "../src/Airdrop.sol";

contract DeployAirdrop is Script {
    // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_SEPOLIA");

    function run(address tokenAddress, address owner) public returns (Airdrop) {
        // vm.startBroadcast(deployerPrivateKey);
        vm.startBroadcast();
        Airdrop airdrop = new Airdrop(tokenAddress, owner);
        vm.stopBroadcast();
        return airdrop;
    }
}
