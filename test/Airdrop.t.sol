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

    uint256 initialTokenBal = 1 * 10 ** 7;
    uint256 startTime = block.timestamp + 10;
    uint256 endTime = block.timestamp + 10000;
    uint256[] amounts = [700000, 500000];

    address ALICE = makeAddr("alice");
    address RILEY = makeAddr("riley");
    address DEREK = makeAddr("derek");
    address[] users = [RILEY, ALICE];

    function setUp() external {
        DeployTestToken deployTestToken = new DeployTestToken();
        tokenContract = deployTestToken.run("GameStop", "GSTP", 1 * 10 ** 8, 18);
        DeployAirdrop deployAirdrop = new DeployAirdrop();
        airdropContract = deployAirdrop.run(address(tokenContract), RILEY);

        vm.prank(msg.sender);
        tokenContract.transfer(RILEY, initialTokenBal);
    }

    function test_TransferOwnership() external {
        vm.prank(RILEY);
        vm.expectEmit(true, true, true, true);
        emit Airdrop.OwnershipTransferred(ALICE);
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
        airdropContract.setAirdropTimeline(block.timestamp, block.timestamp + 10000);
    }

    function test_RevertIfInvalidTimeline() external {
        vm.prank(RILEY);
        vm.expectRevert(abi.encodeWithSelector(InvalidTimeline.selector, endTime, startTime));
        airdropContract.setAirdropTimeline(endTime, startTime);
    }

    function test_SetUsersAmount() external {
        vm.prank(ALICE);
        vm.expectRevert(NotOwner.selector);
        airdropContract.setUsersAmount(users, amounts);
        vm.prank(RILEY);
        // setUsersAmount returns true is successful
        assert(airdropContract.setUsersAmount(users, amounts));
    }

    function test_RevertIfMismatchedUsersAndAmounts() external {
        // Adding another user to the users array
        users.push(DEREK);
        vm.prank(RILEY);
        vm.expectRevert(abi.encodeWithSelector(MismatchUsersToAmountLength.selector, users.length, amounts.length));
        assert(!airdropContract.setUsersAmount(users, amounts));
    }

    function test_Claim() external {
        vm.prank(RILEY);
        airdropContract.setAirdropTimeline(startTime, endTime);

        // vm.roll(50); // inclrease block number by 50
        skip(200); // increase block.timestamp by 200

        uint256 amountToApprove = 1 * 10 ** 7;
        vm.startPrank(RILEY);
        tokenContract.approve(address(airdropContract), amountToApprove);
        airdropContract.setUsersAmount(users, amounts);
        vm.stopPrank();
        vm.prank(ALICE);
        vm.expectEmit(true, true, true, true);
        emit Airdrop.Claimed(ALICE, amounts[1]);
        airdropContract.claim();
        assertEq(tokenContract.balanceOf(ALICE), airdropContract.checkEligibleAmount(ALICE));
    }

    function test_RevertIfNotEligibleForClaim() external {
        vm.prank(RILEY);
        airdropContract.setAirdropTimeline(startTime, endTime);

        // vm.roll(50); // inclrease block number by 50

        // increase block.timestamp by 200
        skip(200);

        uint256 amountToApprove = 1 * 10 ** 7;

        vm.startPrank(RILEY);
        tokenContract.approve(address(airdropContract), amountToApprove);
        airdropContract.setUsersAmount(users, amounts);
        vm.stopPrank();

        vm.prank(DEREK);
        vm.expectRevert(NotEligible.selector);
        airdropContract.claim();
    }

    function test_RevertIfClaimOutsideTimeline() external {
        vm.prank(RILEY);
        airdropContract.setAirdropTimeline(startTime, endTime);

        vm.prank(DEREK);
        vm.expectRevert(ClaimNotStarted.selector);
        airdropContract.claim();

        skip(20000);

        vm.prank(DEREK);
        vm.expectRevert(ClaimExpired.selector);
        airdropContract.claim();
    }

    function test_RevertIfAlreadyClaimed() external {
        vm.prank(RILEY);
        airdropContract.setAirdropTimeline(startTime, endTime);

        // vm.roll(50); // inclrease block number by 50

        // Increase block.timestamp by 200
        skip(200);

        uint256 amountToApprove = 1 * 10 ** 7;

        vm.startPrank(RILEY);
        tokenContract.approve(address(airdropContract), amountToApprove);
        airdropContract.setUsersAmount(users, amounts);
        vm.stopPrank();

        vm.prank(ALICE);
        airdropContract.claim();

        vm.prank(ALICE);
        vm.expectRevert(UserHasClaimed.selector);
        airdropContract.claim();
    }

    function test_CheckELigibleAmountIsCorrect() external {
        vm.prank(RILEY);
        airdropContract.setUsersAmount(users, amounts);
        uint256 eligibleAmount = airdropContract.checkEligibleAmount(users[1]);
        assertEq(eligibleAmount, amounts[1]);
    }
}
