// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Permit} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ZeroAddress} from "../libs/Errors.sol";

/// @title CollectionToken
/// @notice Fixed-supply ERC20 backing a Clutch NFT-Token AMM market.
///         No owner, no admin, no mint after deployment, no transfer fees,
///         no blacklist, no pause — a clean token for scanner compatibility.
contract CollectionToken is ERC20, ERC20Burnable, ERC20Permit {
    uint8 private constant TOKEN_DECIMALS = 18;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        address initialHolder_
    ) ERC20(name_, symbol_) ERC20Permit(name_) {
        if (initialHolder_ == address(0)) revert ZeroAddress();
        _mint(initialHolder_, totalSupply_);
    }

    function decimals() public pure override returns (uint8) {
        return TOKEN_DECIMALS;
    }
}
