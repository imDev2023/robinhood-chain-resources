// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

/// @title LaunchToken
/// @notice Immutable fixed-supply ERC20 used by non-Base launchpad deployments. The constructor mints once to
///         factory-supplied genesis recipients. There is no owner, minter, burner, pauser, upgrade hook, or admin.
contract LaunchToken is IERC20, IERC20Metadata, IERC20Errors {
    struct GenesisParams {
        address factory;
        string name;
        string symbol;
        string contractURI;
        address metadataAuthority;
        address[] recipients;
        uint256[] amounts;
        string[] metadataKeys;
        string[] metadataValues;
    }

    bytes32 public constant DEFAULT_ADMIN_ROLE = bytes32(0);
    bytes32 public constant METADATA_ROLE = keccak256("METADATA_ROLE");

    uint8 public constant decimals = 18;

    address public immutable factory;
    address public immutable metadataAuthority;
    uint256 public immutable supplyCap;

    string private _name;
    string private _symbol;
    string public contractURI;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(string => string) public extraMetadata;

    event ContractURIUpdated();
    event NameUpdated(address indexed updater, string newName);
    event SymbolUpdated(address indexed updater, string newSymbol);
    event ExtraMetadataUpdated(string key, string value);

    error InvalidConfig();
    error MetadataUnauthorized(address account);

    constructor(GenesisParams memory p) {
        if (
            p.factory == address(0) || bytes(p.name).length == 0 || bytes(p.symbol).length == 0
                || p.recipients.length == 0 || p.recipients.length != p.amounts.length
                || p.metadataKeys.length != p.metadataValues.length
        ) revert InvalidConfig();

        factory = p.factory;
        metadataAuthority = p.metadataAuthority;
        _name = p.name;
        _symbol = p.symbol;
        contractURI = p.contractURI;

        uint256 supply;
        for (uint256 i = 0; i < p.recipients.length; i++) {
            address recipient = p.recipients[i];
            uint256 amount = p.amounts[i];
            if (recipient == address(0)) revert ERC20InvalidReceiver(address(0));
            if (amount == 0) revert InvalidConfig();
            _balances[recipient] += amount;
            supply += amount;
            emit Transfer(address(0), recipient, amount);
        }
        supplyCap = supply;

        for (uint256 i = 0; i < p.metadataKeys.length; i++) {
            if (bytes(p.metadataKeys[i]).length == 0) revert InvalidConfig();
            extraMetadata[p.metadataKeys[i]] = p.metadataValues[i];
            emit ExtraMetadataUpdated(p.metadataKeys[i], p.metadataValues[i]);
        }
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view returns (uint256) {
        return supplyCap;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = _allowances[from][msg.sender];
        if (allowed != type(uint256).max) {
            if (allowed < amount) revert ERC20InsufficientAllowance(msg.sender, allowed, amount);
            unchecked {
                _allowances[from][msg.sender] = allowed - amount;
            }
        }
        _transfer(from, to, amount);
        return true;
    }

    function updateName(string calldata newName) external onlyMetadata {
        if (bytes(newName).length == 0) revert InvalidConfig();
        _name = newName;
        emit NameUpdated(msg.sender, newName);
    }

    function updateSymbol(string calldata newSymbol) external onlyMetadata {
        if (bytes(newSymbol).length == 0) revert InvalidConfig();
        _symbol = newSymbol;
        emit SymbolUpdated(msg.sender, newSymbol);
    }

    function updateContractURI(string calldata newURI) external onlyMetadata {
        contractURI = newURI;
        emit ContractURIUpdated();
    }

    function updateExtraMetadata(string calldata key, string calldata value) external onlyMetadata {
        if (bytes(key).length == 0) revert InvalidConfig();
        extraMetadata[key] = value;
        emit ExtraMetadataUpdated(key, value);
    }

    function hasRole(bytes32 role, address account) external view returns (bool) {
        return role == METADATA_ROLE && account != address(0) && account == metadataAuthority;
    }

    modifier onlyMetadata() {
        if (msg.sender != metadataAuthority) revert MetadataUnauthorized(msg.sender);
        _;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        if (from == address(0)) revert ERC20InvalidSender(address(0));
        if (to == address(0)) revert ERC20InvalidReceiver(address(0));
        uint256 bal = _balances[from];
        if (bal < amount) revert ERC20InsufficientBalance(from, bal, amount);
        unchecked {
            _balances[from] = bal - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        if (owner == address(0)) revert ERC20InvalidApprover(address(0));
        if (spender == address(0)) revert ERC20InvalidSpender(address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
