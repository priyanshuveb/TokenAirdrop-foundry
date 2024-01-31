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
    address DEREK = makeAddr("derek");

    function setUp() external {
        DeployTestToken deployTestToken = new DeployTestToken();
        tokenContract = deployTestToken.run("GameStop", "GSTP", 1 * 10 ** 8, 18);
        DeployAirdrop deployAirdrop = new DeployAirdrop();
        airdropContract = deployAirdrop.run(address(tokenContract), RILEY);
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
        vm.expectRevert(abi.encodeWithSelector(InvalidTimeline.selector, 1800, 1500));
        airdropContract.setAirdropTimeline(1800, 1500);
    }

    function test_SetUsersAmount() external {
        // memory arrays cannot be dynamic
        address[] memory users = new address[](2);
        uint256[] memory amounts = new uint256[](2);
        users[0] = RILEY;
        users[1] = ALICE;
        amounts[0] = 700000;
        amounts[1] = 500000;
        vm.prank(ALICE);
        vm.expectRevert(NotOwner.selector);
        airdropContract.setUsersAmount(users, amounts);
        vm.prank(RILEY);
        // setUsersAmount returns true is successful
        assert(airdropContract.setUsersAmount(users, amounts));
    }

    function test_RevertIfMismatchedUsersAndAmounts() external {
        address[] memory users = new address[](2);
        uint256[] memory amounts = new uint256[](3);
        users[0] = RILEY;
        users[1] = ALICE;
        amounts[0] = 700000;
        amounts[1] = 500000;
        vm.prank(RILEY);
        vm.expectRevert(abi.encodeWithSelector(MismatchUsersToAmountLength.selector, users.length, amounts.length));
        assert(!airdropContract.setUsersAmount(users, amounts));
    }

    function test_Claim() external {
        vm.prank(RILEY);
        airdropContract.setAirdropTimeline(block.timestamp + 10, block.timestamp + 10000);

        address[] memory users = new address[](2);
        uint256[] memory amounts = new uint256[](2);
        users[0] = RILEY;
        users[1] = ALICE;
        amounts[0] = 700000;
        amounts[1] = 500000;

        // vm.roll(50); // inclrease block number by 50
        skip(200); // increase block.timestamp by 200

        vm.prank(msg.sender);
        tokenContract.transfer(RILEY, 10000000);

        vm.startPrank(RILEY);
        tokenContract.approve(address(airdropContract), 10000000);
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
        airdropContract.setAirdropTimeline(block.timestamp + 10, block.timestamp + 10000);

        address[] memory users = new address[](2);
        uint256[] memory amounts = new uint256[](2);
        users[0] = RILEY;
        users[1] = ALICE;
        amounts[0] = 700000;
        amounts[1] = 500000;

        // vm.roll(50); // inclrease block number by 50
        skip(200); // increase block.timestamp by 200
        vm.prank(msg.sender);
        tokenContract.transfer(RILEY, 10000000);

        vm.startPrank(RILEY);
        tokenContract.approve(address(airdropContract), 10000000);
        airdropContract.setUsersAmount(users, amounts);
        vm.stopPrank();

        vm.prank(DEREK);
        vm.expectRevert(NotEligible.selector);
        airdropContract.claim();
    }

    function test_RevertIfClaimOutsideTimeline() external {
        vm.prank(RILEY);
        airdropContract.setAirdropTimeline(block.timestamp + 10, block.timestamp + 10000);

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
        airdropContract.setAirdropTimeline(block.timestamp + 10, block.timestamp + 10000);

        address[] memory users = new address[](2);
        uint256[] memory amounts = new uint256[](2);
        users[0] = RILEY;
        users[1] = ALICE;
        amounts[0] = 700000;
        amounts[1] = 500000;

        // vm.roll(50); // inclrease block number by 50
        skip(200); // increase block.timestamp by 200

        vm.prank(msg.sender);
        tokenContract.transfer(RILEY, 10000000);

        vm.startPrank(RILEY);
        tokenContract.approve(address(airdropContract), 10000000);
        airdropContract.setUsersAmount(users, amounts);
        vm.stopPrank();

        vm.prank(ALICE);
        airdropContract.claim();

        vm.prank(ALICE);
        vm.expectRevert(UserHasClaimed.selector);
        airdropContract.claim();
    }

    function test_CheckELigibleAmount() external {
        
    }
}
