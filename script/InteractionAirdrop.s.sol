// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Airdrop} from "../src/Airdrop.sol";

contract AirdropInstance {
    Airdrop airdrop = Airdrop(0xd3E5c6b50f1e7B36Ce2923f3f72a2B01172282eC);
}

contract SetAirdropTimeline is Script, AirdropInstance {
    uint256 startsAt = block.timestamp;
    uint256 endsAt = startsAt + 100000;

    function run() external {
        setTimeline();
    }

    function setTimeline() internal {
        vm.startBroadcast();
        airdrop.setAirdropTimeline(startsAt, endsAt);
        vm.stopBroadcast();
    }
}

contract GetTimeline is Script, AirdropInstance {
    function run() external view returns (uint256 startTimeIs, uint256 endTimeIs) {
        startTimeIs = airdrop.claimStartsAt();
        endTimeIs = airdrop.claimEndsAt();
        return (startTimeIs, endTimeIs);
    }
}

contract SetUsersAmount is Script, AirdropInstance {
    string addressFileName = "ethereum-addresses";
    string amountsFileName = "amounts";

    function run() external {
        setUsersAMount();
    }

    function readInput(string memory input) internal view returns (string memory) {
        string memory inputDir = string.concat(vm.projectRoot(), "/script/input/");
        string memory chainDir = string.concat(vm.toString(block.chainid), "/");
        string memory file = string.concat(input, ".json");
        return vm.readFile(string.concat(inputDir, chainDir, file));
    }

    function setUsersAMount() internal {
        string memory userAddresses = readInput(addressFileName);
        string memory userAmounts = readInput(amountsFileName);
        bytes memory userListEncoded = vm.parseJson(userAddresses);
        bytes memory userAmountsEncoded = vm.parseJson(userAmounts);
        // console.logBytes(userListEncoded);
        address[] memory decodedAddresses = abi.decode(userListEncoded, (address[]));
        uint256[] memory decodedAmounts = abi.decode(userAmountsEncoded, (uint256[]));
        vm.broadcast();
        airdrop.setUsersAmount(decodedAddresses, decodedAmounts);
        // console.log(decodedAddresses); // This will fail, use the for loop if you want to log array of addresses defined below
        // for (uint256 i = 0; i < decodedAddresses.length; i++) {
        //     address currentAddress = decodedAddresses[i];
        //     console.log(currentAddress); // Log each address to the console
        // }
    }
}

contract Claim is Script, AirdropInstance {
    function run() external {
        claim();
    }

    function claim() internal {
        vm.broadcast(msg.sender);
        airdrop.claim();
    }
}

contract checkAirdropAmount is Script, AirdropInstance {
    function run() external view {
        checkAmount(msg.sender);
    }

    function checkAmount(address user) internal view returns(uint256){
        return airdrop.checkEligibleAmount(user);
    }
} 
