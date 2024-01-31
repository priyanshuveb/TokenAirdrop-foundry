// SPDX-License-Identifier: MIT

pragma solidity >=0.8.18 <0.9.0;

// we can import console from Test.sol because it is already importing the console.sol in itself
import {Test, console} from "forge-std/Test.sol";
import {TestToken} from "../src/TestToken.sol";
import {DeployTestToken} from "../script/DeployTestToken.s.sol";
import "../src/Airdrop.sol"; // Since the custom errors are defined outside the Airdrop contract hence we are importing the whole solidity file
import {DeployAirdrop} from "../script/DeployAirdrop.s.sol";

contract AirdropTest is Test {
    TestToken tokenContract;
    Airdrop airdropContract;
    address ALICE = makeAddr("alice");
    address RILEY = makeAddr("riley");

    function setUp() external {
        DeployTestToken deployTestToken = new DeployTestToken();
        tokenContract = deployTestToken.run("GameStop", "GSTP", 1 * 10 ** 8, 18);
        DeployAirdrop deployAirdrop = new DeployAirdrop();
        airdropContract = deployAirdrop.run(address(tokenContract), RILEY);
    }

    function test_TransferOwnership() external {
        vm.prank(RILEY);
        airdropContract.transferOwnership(ALICE);
        assertEq(airdropContract.owner(), ALICE);
    }

    function test_IfNotOwnerTrasnferOwnership() external {
        vm.expectRevert(NotOwner.selector);
        vm.prank(ALICE);
        airdropContract.transferOwnership(ALICE);
    }

    function test_SetAirdropTimeline() external {
        vm.prank(RILEY);
        airdropContract.setAirdropTimeline(block.timestamp + 10, block.timestamp + 10000);
        uint256 startTime = airdropContract.claimStartsAt();
        uint256 endTime = airdropContract.claimEndsAt();
        console.log('starts at %s and ends at %s',startTime, endTime);
    }
}
