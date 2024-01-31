// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error TestToken__NotOwner();

contract TestToken is ERC20 {
    uint8 decimalValue;
    address immutable OWNER;
    modifier onlyOwner() {
        if (msg.sender != OWNER) revert TestToken__NotOwner();
        _;
    }

    constructor(string memory name, string memory symbol, uint256 totalSupply, uint8 decimal) ERC20(name, symbol) {
        decimalValue = decimal;
        OWNER = msg.sender;
        _mint(msg.sender, totalSupply);
    }

    function decimals() public view override returns (uint8) {
        return decimalValue;
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function mint(uint256 amount) external onlyOwner {
        _mint(msg.sender, amount);
    }
}
