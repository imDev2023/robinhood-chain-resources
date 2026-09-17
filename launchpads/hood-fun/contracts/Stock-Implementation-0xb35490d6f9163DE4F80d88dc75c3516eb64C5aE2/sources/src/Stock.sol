// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IStock.sol";
import "./AccessControlled.sol";
import "./OraclePausable.sol";
import "./Roles.sol";
import "./ERC20ScaledUIUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

contract Stock is IStock, AccessControlled, OraclePausable, ERC20ScaledUIUpgradeable {
    event MetaDataUpdated(string name, string symbol);

    error IsPaused();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address registry) AccessControlled(registry) {
        _disableInitializers();
    }

    /// @custom:storage-location erc7201:robinhood.storage.Stock
    struct StockStorage {
        bytes32 uid;
        bool paused;
    }

    bytes32 private constant StockStorageLocation = 0x8d25ea8ee309999a79f0af498fbab0e424669497170669bd9e93b81a62babc00;

    modifier onlyNotPaused() {
        if (paused()) {
            revert IsPaused();
        }
        _;
    }

    function initialize(bytes32 uid_, string calldata name_, string calldata symbol_) external override initializer {
        StockStorage storage $ = _getStockStorage();
        __ERC20_init(name_, symbol_);
        $.uid = uid_;
    }

    function _getStockStorage() private pure returns (StockStorage storage $) {
        assembly {
            $.slot := StockStorageLocation
        }
    }

    /// @dev Storage from the base ERC20 contract
    function _getERC20StorageFromBase() internal pure returns (ERC20Storage storage $) {
        assembly {
            // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC20")) - 1)) & ~bytes32(uint256(0xff))
            $.slot := 0x52c63247e1f47db19d5ce0460030c497f067ca4cebf71ba98eeadabe20bace00
        }
    }

    function transfer(address to, uint256 value)
        public
        override
        onlyNotPaused
        onlyNotBlocked(to)
        onlyNotBlocked(_msgSender())
        returns (bool)
    {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value)
        public
        override
        onlyNotPaused
        onlyNotBlocked(from)
        onlyNotBlocked(to)
        onlyNotBlocked(_msgSender())
        returns (bool)
    {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value)
        public
        override
        onlyNotPaused
        onlyNotBlocked(spender)
        onlyNotBlocked(_msgSender())
        returns (bool)
    {
        return super.approve(spender, value);
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        public
        override
        onlyNotPaused
        onlyNotBlocked(owner)
        onlyNotBlocked(spender)
        onlyNotBlocked(_msgSender())
    {
        super.permit(owner, spender, value, deadline, v, r, s);
    }

    function mint(address to, uint256 amount)
        public
        override
        onlyRole(MINTER_ROLE)
        onlyNotPaused
        onlyNotBlocked(to)
        onlyNotBlocked(_msgSender())
    {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount)
        public
        override
        onlyRole(BURNER_ROLE)
        onlyNotPaused
        onlyNotBlocked(from)
        onlyNotBlocked(_msgSender())
    {
        _burn(from, amount);
    }

    function adminBurn(address from, uint256 amount) public override onlyRole(ADMIN_BURNER_ROLE) {
        _burn(from, amount);
    }

    function uid() public view returns (bytes32) {
        StockStorage storage $ = _getStockStorage();
        return $.uid;
    }

    function terms() public pure returns (string memory) {
        return "https://robinhood.com/stocktoken/rhj";
    }

    function paused() public view returns (bool) {
        StockStorage storage $ = _getStockStorage();
        return $.paused || IAccessControlsRegistry(ACCESS_CONTROLLED_REGISTRY).paused();
    }

    function tokenPaused() public view returns (bool) {
        StockStorage storage $ = _getStockStorage();
        return $.paused;
    }

    function pause() public onlyRole(TOKEN_PAUSER_ROLE) {
        StockStorage storage $ = _getStockStorage();
        $.paused = true;
        emit Paused();
    }

    function unpause() public onlyRole(TOKEN_PAUSER_ROLE) {
        StockStorage storage $ = _getStockStorage();
        $.paused = false;
        emit Unpaused();
    }

    function updateMultiplier(uint256 newMultiplier) public onlyNotPaused onlyRole(MULTIPLIER_UPDATER_ROLE) {
        _updateUIMultiplier(newMultiplier);
    }

    function updateMultiplier(uint256 newMultiplier, uint256 effectiveAt_)
        public
        onlyNotPaused
        onlyRole(MULTIPLIER_UPDATER_ROLE)
    {
        _updateUIMultiplier(newMultiplier, effectiveAt_);
    }

    function pauseOracle() external onlyRole(ORACLE_PAUSER_ROLE) {
        _pauseOracle();
    }

    function unpauseOracle() external onlyRole(ORACLE_PAUSER_ROLE) {
        _unpauseOracle();
    }

    function setMetadata(string calldata _name, string calldata _symbol) public onlyRole(METADATA_UPDATER_ROLE) {
        _getERC20StorageFromBase()._name = _name;
        _getERC20StorageFromBase()._symbol = _symbol;
        emit MetaDataUpdated(_name, _symbol);
    }

    function _EIP712Name() internal view virtual override returns (string memory) {
        return name();
    }

    function _EIP712Version() internal view virtual override returns (string memory) {
        return "1";
    }
}
