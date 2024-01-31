// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Throws when restricted functions are called by a user other than the owner of Airdrop
error NotOwner();
/// @notice Throws when number of users and number of amounts don't match
error MismatchUsersToAmountLength(uint256 userListLength, uint256 amountListLength);
/// @notice Throws when a user not eligible tries to claim the airdrop
error NotEligible();
/// @notice Throws when a user who has already claimed the airdrop tries to call the claim()
error UserHasClaimed();
/// @notice Throws when one tries to claim airdrop after the deadlince
error ClaimDeadlinePassed();
/// @notice Throws when timeline params are invalid
error InvalidTimeline(uint256 startTime, uint256 endTime);
/// @notice Throws when user tried to claim after the airdrop has ended
error ClaimExpired();
/// @notice Throws when user tried to claim before the airdrop has started
error ClaimNotStarted();
error TokenTrasferFailed();

/// @title Airdrop contract
/// @author Priyanshu Bindal
/// @notice You can use this contract to airdrop tokens to specified users, the user
/// would have to claim the tokens
contract Airdrop {
    IERC20 private immutable tokenContract;

    // Current owner of the contract
    address public owner;

    // Airdrop starting timestamp
    uint256 private startTime;
    // Airdrop ending timestamp
    uint256 private endTime;

    // List of users eligible for airdrop
    address[] private eligibleUsers;

    // User's address to his claim status
    mapping(address => bool) private hasClaimed;
    // User's address to his eligible amount
    mapping(address => uint256) private usersToAmount;

    /// @dev Prevents calling a function from anyone except the owner's address
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /// @notice Emitted when ownership is transferred
    /// @param newOwner The new owner of the Airdrop
    event OwnershipTransferred(address newOwner);
    /// @notice Emitted when user has successfully claimed the airdrop
    /// @param user The address who claimed
    /// @param amount The amount of tokens got claimed
    event Claimed(address user, uint256 amount);

    constructor(address tokenContractAddress, address _owner) {
        owner = _owner;
        tokenContract = IERC20(tokenContractAddress);
    }

    /// @notice Transfer the ownsership of this contract to a new address
    /// @param _owner The new owner of the Airdrop
    function transferOwnership(address _owner) external onlyOwner {
        owner = _owner;
        emit OwnershipTransferred(_owner);
    }

    /// @notice Sets the start and end time for the airdrop claim
    /// @param _startTime The start time for the airdrop
    /// @param _endTime The end time for the airdrop
    function setAirdropTimeline(uint256 _startTime, uint256 _endTime) external onlyOwner {
        if (_endTime < _startTime) revert InvalidTimeline(_startTime, _endTime);
        startTime = _startTime;
        endTime = _endTime;
    }

    /// @notice Updates the list of eligible users for the airdrop and their corresponding amounts
    /// @param _eligibleUsers The list of the users eligible for the airdrop
    /// @param _eligibleAmounts The list of amounts each user is eligible for
    /// @return Returns true upon successful execution
    function setUsersAmount(address[] memory _eligibleUsers, uint256[] memory _eligibleAmounts)
        external
        onlyOwner
        returns (bool)
    {
        eligibleUsers = _eligibleUsers;
        uint256 numberOfUsers = _eligibleUsers.length;
        if (numberOfUsers != _eligibleAmounts.length) {
            revert MismatchUsersToAmountLength(numberOfUsers, _eligibleAmounts.length);
        }
        for (uint256 i = 0; i < numberOfUsers; i++) {
            usersToAmount[eligibleUsers[i]] = _eligibleAmounts[i];
            hasClaimed[eligibleUsers[i]];
        }
        return true;
    }

    /// @notice User can call this function to claim airdrop if eligible
    /// @dev Will revert if a user who is not eligible or has already claimed tries to call this function
    function claim() external {
        if (endTime <= block.timestamp) revert ClaimExpired();
        if (startTime >= block.timestamp) revert ClaimNotStarted();
        uint256 amount = checkEligibleAmount(msg.sender);
        if (amount == 0) revert NotEligible();
        if (hasClaimed[msg.sender]) revert UserHasClaimed();
        hasClaimed[msg.sender] = true;
        if (!tokenContract.transferFrom(owner, msg.sender, amount)) {
            revert TokenTrasferFailed();
        }
        emit Claimed(msg.sender, amount);
    }

    // view/pure functions

    /// @notice Checks for the amount of airdrop tokens user is eligible for
    /// @param userAddress The address to check for the airdrop amount
    /// @return Returns the amount of airdrop tokens the user is eligible for
    function checkEligibleAmount(address userAddress) public view returns (uint256) {
        return usersToAmount[userAddress];
    }

    /// @notice Returns the start time of the airdrop
    function claimStartsAt() external view returns (uint256) {
        return startTime;
    }

    /// @notice Returns the end time of the airdrop
    function claimEndsAt() external view returns (uint256) {
        return endTime;
    }
}
