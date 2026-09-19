// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title UnihoodToken
/// @notice Fixed-supply ERC-20 launched through the Unihood factory. No owner, no mint,
///         no transfer tax. Burning is a plain transfer to 0xdEaD, open to anyone.
/// @dev Deliberately no immutables: every launch shares the exact same runtime bytecode, so once
///      one token is source-verified on Blockscout, every later launch is auto-detected as its
///      verified twin. Scanners (GMGN-style) read that instead of flagging "not open-sourced".
contract UnihoodToken {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    /// @notice Wallet that created the launch. Read by the hook for fee routing.
    address public creator;
    /// @notice On-chain metadata (data: URI or https/ipfs URL), fixed at launch.
    string public metaURI;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    error InsufficientBalance();
    error InsufficientAllowance();

    constructor(string memory name_, string memory symbol_, string memory metaURI_, address creator_, uint256 supply_) {
        name = name_;
        symbol = symbol_;
        metaURI = metaURI_;
        creator = creator_;
        totalSupply = supply_;
        balanceOf[msg.sender] = supply_;
        emit Transfer(address(0), msg.sender, supply_);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        if (allowed != type(uint256).max) {
            if (allowed < amount) revert InsufficientAllowance();
            allowance[from][msg.sender] = allowed - amount;
        }
        _transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 bal = balanceOf[from];
        if (bal < amount) revert InsufficientBalance();
        unchecked {
            balanceOf[from] = bal - amount;
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }
}
