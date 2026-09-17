// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./interfaces/IScaledUIAmount.sol";
import "./interfaces/IScaledUIAmountBalances.sol";
import "./interfaces/IScaledUIAmountNewUIMultiplier.sol";

contract ERC20ScaledUIUpgradeable is
    ERC20PermitUpgradeable,
    ERC165Upgradeable,
    IScaledUIAmount,
    IScaledUIAmountBalances,
    IScaledUIAmountNewUIMultiplier
{
    /// @custom:storage-location erc7201:robinhood.storage.ERC20Rebase
    struct ERC20ScaledUIStorage {
        uint256 _multiplier;
        uint256 _newMultiplier;
        uint256 _effectiveAt;
    }

    bytes32 private constant ERC20RebaseStorageLocation =
        0x395525728d1d6f4af44d273368682dd92b28e7464d750ef3212d3cb7f5959d00;

    function _getERC20ScaledUIStorage() private pure returns (ERC20ScaledUIStorage storage $) {
        assembly {
            $.slot := ERC20RebaseStorageLocation
        }
    }

    uint256 private constant DENOMINATOR = 1 ether;

    function _updateUIMultiplier(uint256 newMultiplier) internal virtual {
        _updateUIMultiplier(newMultiplier, block.timestamp);
    }

    function _updateUIMultiplier(uint256 newMultiplier, uint256 effectiveAt_) internal virtual {
        require(newMultiplier > 0, "New multiplier must be greater than 0");
        // slither-disable-next-line timestamp
        require(effectiveAt_ >= block.timestamp, "Effective time must not be in the past");

        ERC20ScaledUIStorage storage $ = _getERC20ScaledUIStorage();

        // Get the current effective multiplier and save it
        uint256 oldMultiplier = uiMultiplier();
        $._multiplier = oldMultiplier;

        // Set the new scheduled multiplier
        $._newMultiplier = newMultiplier;
        $._effectiveAt = effectiveAt_;

        emit UIMultiplierUpdated(oldMultiplier, newMultiplier, effectiveAt_);
    }

    function uiMultiplier() public view virtual returns (uint256) {
        ERC20ScaledUIStorage storage $ = _getERC20ScaledUIStorage();

        // Check if scheduled multiplier should be effective
        // slither-disable-next-line timestamp
        if (block.timestamp >= $._effectiveAt && $._newMultiplier != 0) {
            return $._newMultiplier;
        }

        // Return current multiplier, or default if not set
        uint256 _multiplier = $._multiplier;
        if (_multiplier == 0) {
            return DENOMINATOR;
        }
        return _multiplier;
    }

    function newUIMultiplier() public view virtual returns (uint256) {
        ERC20ScaledUIStorage storage $ = _getERC20ScaledUIStorage();
        uint256 _newMultiplier = $._newMultiplier;
        if (_newMultiplier == 0) {
            return DENOMINATOR;
        }
        return _newMultiplier;
    }

    function effectiveAt() public view virtual returns (uint256) {
        ERC20ScaledUIStorage storage $ = _getERC20ScaledUIStorage();
        return $._effectiveAt;
    }

    function balanceOfUI(address account) public view virtual returns (uint256) {
        return Math.mulDiv(balanceOf(account), uiMultiplier(), DENOMINATOR);
    }

    function totalSupplyUI() public view virtual returns (uint256) {
        return Math.mulDiv(totalSupply(), uiMultiplier(), DENOMINATOR);
    }

    function _update(address from, address to, uint256 value) internal virtual override {
        super._update(from, to, value);
        emit TransferWithScaledUI(from, to, value, Math.mulDiv(value, uiMultiplier(), DENOMINATOR));
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IScaledUIAmount).interfaceId
            || interfaceId == type(IScaledUIAmountBalances).interfaceId
            || interfaceId == type(IScaledUIAmountNewUIMultiplier).interfaceId || super.supportsInterface(interfaceId);
    }
}
