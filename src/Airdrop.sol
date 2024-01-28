// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

// onlyOwner
// Whitelisted addresses
// Claim airdrop
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error Airdrop_NotOwner();
error Airdrop_InvalidEndTimestamp();
error Airdrop_InvalidStartTimestamp();
error Airdrop_MismatchUsersToAmountLength();
error Airdrop_NotEligible();
error Airdrop_UserHasClaimed();
error Airdrop_ClaimDeadlinePassed();
error Airdrop_InvalidTimestampValues();
error Airdrop_ClaimNotStartedOrExpired();

contract Airdrop {
    IERC20 private immutable TOKEN_CONTRACT;
    address private owner;
    uint256 private startAirdropTimestamp;
    uint256 private endAirdropTimestamp;
    address[] public eligibleUsers;
    address[] private usersNotClaimed;
    mapping(address => bool) private hasClaimed;
    mapping(address => uint256) private usersToAmount;

    modifier onlyOwner() {
        if (msg.sender != owner) revert Airdrop_NotOwner();
        _;
    }

    constructor(IERC20 tokenContractAddress, address _owner) {
        owner = _owner;
        TOKEN_CONTRACT = tokenContractAddress;
    }

    function transferOwnership(address _owner) external onlyOwner {
        owner = _owner;
    }

    function setAirdropTimeline(
        uint256 _startAirdropTimestamp,
        uint256 _endAirdropTimestamp
    ) external onlyOwner {
        if (
            startAirdropTimestamp < block.timestamp ||
            _endAirdropTimestamp < _startAirdropTimestamp
        ) revert Airdrop_InvalidTimestampValues();
        startAirdropTimestamp = _startAirdropTimestamp;
        // if (
        //     endAirdropTimestamp < startAirdropTimestamp ||
        //     startAirdropTimestamp == 0
        // ) revert Airdrop_InvalidEndTimestamp();
        endAirdropTimestamp = _endAirdropTimestamp;
    }

    function doAirdrop() internal {}

    function setStartAirdropTimestamp(
        uint256 _startAirdropTimestamp
    ) external onlyOwner {
        if (startAirdropTimestamp < block.timestamp)
            revert Airdrop_InvalidStartTimestamp();
        startAirdropTimestamp = _startAirdropTimestamp;
    }

    function setEndAirdropTimestamp(
        uint256 _endAirdropTimestamp
    ) external onlyOwner {
        if (
            endAirdropTimestamp < startAirdropTimestamp ||
            startAirdropTimestamp == 0
        ) revert Airdrop_InvalidEndTimestamp();
        endAirdropTimestamp = _endAirdropTimestamp;
    }

    function setUsersAmount(
        address[] memory _eligibleUsers,
        uint256[] memory _usersAmount
    ) external onlyOwner {
        eligibleUsers = _eligibleUsers;
        uint256 numberOfUsers = _eligibleUsers.length;
        if (numberOfUsers != _usersAmount.length)
            revert Airdrop_MismatchUsersToAmountLength();
        for (uint i = 0; i < numberOfUsers; i++) {
            usersToAmount[_eligibleUsers[i]] = _usersAmount[i];
            hasClaimed[_eligibleUsers[i]];
        }
    }

    function claim() external {
        if (block.timestamp < startAirdropTimestamp || endAirdropTimestamp < block.timestamp)
            revert Airdrop_ClaimNotStartedOrExpired();
        uint256 amount = checkEligibleAmount(msg.sender);
        if (amount == 0) revert Airdrop_NotEligible();
        if (!hasClaimed[msg.sender]) revert Airdrop_UserHasClaimed();
        TOKEN_CONTRACT.transferFrom(address(this), msg.sender, amount);
    }

    // For the users who didn't claim their airpdrop, but with 50% penalty
    function sendBatchAmountWithPenalty() external onlyOwner {
        for (uint i = 0; i > eligibleUsers.length; i++) {
            if (!hasClaimed[eligibleUsers[i]]) {}
        }
    }

    // view/pure functions
    function checkEligibleAmount(
        address userAddress
    ) public view returns (uint256) {
        return usersToAmount[userAddress];
    }

    function claimStartTime() view external returns(uint256){
        return startAirdropTimestamp;
    }

    function claimEndTime() view external returns(uint256) {
        return endAirdropTimestamp;
    }
}

