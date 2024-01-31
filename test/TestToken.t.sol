// SPDX-License-Identifier: MIT

pragma solidity >=0.8.18 <0.9.0;

// we can import console from Test.sol because it is already importing the console.sol in itself
import {Test, console} from "forge-std/Test.sol";
import {TestToken} from "../src/TestToken.sol";
import {DeployTestToken} from "../script/DeployTestToken.s.sol";

contract TestTokenTest is Test {
    TestToken testToken;

    address immutable ALICE = makeAddr("alice");
    address immutable MALONE = makeAddr("malone");

    function setUp() external {
        DeployTestToken deployTestToken = new DeployTestToken();
        testToken = deployTestToken.run("GameStop", "GSTP", 1 * 10 ** 6, 18);
    }

    function test_OwnerBalanceIs1000000() external {
        uint256 balance = testToken.balanceOf(msg.sender);
        assertEq(balance, 1 * 10 ** 6);
    }

    function test_TransferToAlice() external {
        uint256 transferAmount = 1e2;
        vm.prank(msg.sender);
        testToken.transfer(ALICE, transferAmount);
        uint256 balanceOfAlice = testToken.balanceOf(ALICE);
        console.log(balanceOfAlice);
        assertEq(transferAmount, balanceOfAlice);
    }

    function test_Approval() external {
        vm.prank(msg.sender);
        uint256 approvalAmount = 1e2;
        testToken.approve(ALICE, approvalAmount);
        uint256 allowanceOfAlice = testToken.allowance(msg.sender, ALICE);
        assertEq(approvalAmount, allowanceOfAlice);
    }

    function test_TransferFrom() external {
        uint256 approvalAmount = 1e2;
        vm.prank(msg.sender);
        testToken.approve(ALICE, approvalAmount);
        uint256 balanceOfAlice = testToken.balanceOf(ALICE);
        hoax(ALICE, 1 ether);
        testToken.transferFrom(msg.sender, MALONE, approvalAmount);
        uint256 balanceOfMalone = testToken.balanceOf(MALONE);
        assertEq(balanceOfMalone, approvalAmount);
        assertEq(balanceOfAlice, 0);
    }

    function testFail_TransferFromMoreThanApproved() external {
        uint256 approvalAmount = 1e1;
        uint256 transferFromAmount = 1e2;
        vm.prank(msg.sender);
        testToken.approve(ALICE, approvalAmount);
        hoax(ALICE, 1 ether);
        testToken.transferFrom(msg.sender, MALONE, transferFromAmount);
    }

    function test_BurnToken() external {
        uint256 tokensToBurn = 5 * 10 ** 5;
        uint256 initialTotalSupply = testToken.totalSupply();
        vm.prank(msg.sender);
        testToken.burn(tokensToBurn);
        uint256 totalSupplyAfterBurn = testToken.totalSupply();
        assertEq(totalSupplyAfterBurn, initialTotalSupply - tokensToBurn);
    }

    function test_OnlyOwnerCanMint() external {
        uint256 amountToMint = 5 * 10 ** 5;
        uint256 initialTotalSupply = testToken.totalSupply();
        vm.prank(msg.sender);
        testToken.mint(amountToMint);
        uint256 newTokenSupply = testToken.totalSupply();
        assertEq(newTokenSupply, initialTotalSupply + amountToMint);
    }

    function testFail_NonOwnerCannotMint() external {
        uint256 amountToMint = 5 * 10 ** 5;
        vm.prank(ALICE);
        testToken.mint(amountToMint);
    }
}
