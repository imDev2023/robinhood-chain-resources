// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IQuotronReflections} from "../interfaces/IQuotronReflections.sol";

interface IQuotron404V2View {
    function ownerOfId(uint256 id) external view returns (address);
    function isHardwired(uint256 id) external view returns (bool);
}

interface IERC721BalanceV2 {
    function balanceOf(address owner) external view returns (uint256);
}

interface IERC20RewardsV2 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/// @title QuotronReflectionsV2
/// @notice Stock-denominated rewards for hardwired V2 terminals. Fresh WETH
/// fees are converted to stock before entering this contract. Legacy V1
/// rewards are pulled from the immutable migrator and remain attached to the
/// same terminal id.
contract QuotronReflectionsV2 is IQuotronReflections {
    uint256 public constant BASKET_BPS = 1250;
    uint256 public constant GOLD_BPS = 500;
    uint256 public constant BOOST_NUM = 125;
    uint256 public constant BOOST_DEN = 100;
    uint256 internal constant ACC_SCALE = 1e18;

    uint8 public constant FLOOR_BASKET = 10;
    uint8 public constant FLOOR_GOLD = 11;
    uint256 public constant BASKET_FIRST_ID = 4441;
    uint256 public constant BASKET_LAST_ID = 4443;
    uint256 public constant GOLD_ID = 4444;

    address public owner;
    address public notifier;
    address public migrator;
    IQuotron404V2View public immutable quotron;
    IERC721BalanceV2 public immutable brokers;
    IERC20RewardsV2 public immutable paxg;
    bool public wiringSealed;
    bool public inflowsPaused;

    address[10] public floorStocks;
    bool public stocksSet;

    /// @dev packed: 0x80 set flag | floorCode | tierIdx << 4.
    mapping(uint256 => uint8) public packedAttr;
    uint256 public attrCount;
    bool public attributesSealed;
    uint16[4] public tierWeights = [100, 150, 250, 500];

    struct Floor {
        uint256 accPerWeight;
        uint256 totalWeight;
        uint256 potPending;
    }

    Floor[10] public floors;

    struct Terminal {
        uint128 weight;
        uint128 reserved;
        uint256 rewardDebt;
        uint256 credited;
        bool active;
    }

    mapping(uint256 => Terminal) public terminals;

    mapping(address => uint256) public basketAcc;
    mapping(uint256 => mapping(address => uint256)) public basketClaimed;
    mapping(address => uint256) public goldPot;
    mapping(address => uint256) public goldClaimed;

    /// @notice V1 rewards claimed during migration and escrowed for the exact
    /// V2 id. Used for normal floors, basket stocks, and legacy PAXG.
    mapping(uint256 => mapping(address => uint256)) public legacyCredit;

    event FeesNotified(uint8 indexed floorIdx, uint256 amount, uint256 toFloor, uint256 toBasket, uint256 toGold);
    event LegacyCredited(uint256 indexed id, address indexed token, uint256 amount);
    event Claimed(uint256 indexed id, address indexed to, address stock, uint256 amount);
    event Poked(uint256 indexed id, uint256 oldWeight, uint256 newWeight);
    event FloorPotClaimed(uint8 indexed floorIdx, uint256 indexed id, uint256 amount);
    event WiringSealed(address indexed notifier, address indexed migrator);
    event InflowsPaused(bool paused);

    error NotOwner();
    error NotNotifier();
    error NotMigrator();
    error NotQuotron();
    error AlreadySet();
    error NotSealed();
    error AttributesSealed_();
    error InvalidAttribute();
    error NotHardwiredId();
    error NotIdOwner();
    error InvalidLegacyToken();
    error InflowsArePaused();
    error Reentrancy();
    error TokenTransferFailed();
    error ZeroAddress();

    uint256 private _lock = 1;

    modifier nonReentrant() {
        if (_lock != 1) revert Reentrancy();
        _lock = 2;
        _;
        _lock = 1;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(address quotron_, address brokers_, address legacyPaxg_) {
        if (quotron_ == address(0) || brokers_ == address(0) || legacyPaxg_ == address(0)) {
            revert ZeroAddress();
        }
        owner = msg.sender;
        quotron = IQuotron404V2View(quotron_);
        brokers = IERC721BalanceV2(brokers_);
        paxg = IERC20RewardsV2(legacyPaxg_);
    }

    // ── one-time wiring ─────────────────────────────────────────────

    function setNotifier(address notifier_) external onlyOwner {
        if (wiringSealed || notifier != address(0)) revert AlreadySet();
        if (notifier_ == address(0)) revert ZeroAddress();
        notifier = notifier_;
    }

    function setMigrator(address migrator_) external onlyOwner {
        if (wiringSealed || migrator != address(0)) revert AlreadySet();
        if (migrator_ == address(0)) revert ZeroAddress();
        migrator = migrator_;
    }

    function setFloorStocks(address[10] calldata stocks) external onlyOwner {
        if (wiringSealed || stocksSet) revert AlreadySet();
        for (uint256 i; i < 10; ++i) {
            if (stocks[i] == address(0)) revert ZeroAddress();
        }
        floorStocks = stocks;
        stocksSet = true;
    }

    function sealWiring() external onlyOwner {
        if (wiringSealed) revert AlreadySet();
        if (notifier == address(0) || migrator == address(0) || !stocksSet) {
            revert NotSealed();
        }
        wiringSealed = true;
        emit WiringSealed(notifier, migrator);
    }

    function setInflowsPaused(bool paused_) external onlyOwner {
        inflowsPaused = paused_;
        emit InflowsPaused(paused_);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        owner = newOwner;
    }

    // ── immutable attributes ────────────────────────────────────────

    function setAttributes(uint16[] calldata ids, uint8[] calldata packed) external onlyOwner {
        if (attributesSealed) revert AttributesSealed_();
        require(ids.length == packed.length, "len");
        for (uint256 i; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint8 value = packed[i];
            require(id >= 1 && id <= 4444, "id");
            uint8 floorCode = value & 0x0f;
            uint8 tierIdx = (value >> 4) & 0x07;
            bool basketId = id >= BASKET_FIRST_ID && id <= BASKET_LAST_ID;
            if (
                value & 0x80 == 0 || tierIdx > 3 || (basketId && floorCode != FLOOR_BASKET)
                    || (id == GOLD_ID && floorCode != FLOOR_GOLD) || (id >= BASKET_FIRST_ID && tierIdx != 0)
                    || (id < BASKET_FIRST_ID && floorCode >= FLOOR_BASKET)
            ) {
                revert InvalidAttribute();
            }
            if (packedAttr[id] == 0) ++attrCount;
            packedAttr[id] = value;
        }
    }

    function sealAttributes() external onlyOwner {
        require(attrCount == 4444, "incomplete");
        attributesSealed = true;
    }

    function attributesOf(uint256 id) public view returns (uint8 floorCode, uint8 tierIdx) {
        uint8 packed = packedAttr[id];
        require(packed != 0, "unset");
        floorCode = packed & 0x0f;
        tierIdx = (packed >> 4) & 0x07;
    }

    // ── fresh + legacy inflows ──────────────────────────────────────

    /// @notice Pulls converted stock from the sealed notifier, then splits it.
    function notifyFees(uint8 floorIdx, uint256 amount) external nonReentrant {
        if (msg.sender != notifier) revert NotNotifier();
        if (!wiringSealed || !attributesSealed) revert NotSealed();
        if (inflowsPaused) revert InflowsArePaused();
        require(floorIdx < 10 && amount != 0, "input");

        address stock = floorStocks[floorIdx];
        _safeTransferFrom(stock, msg.sender, address(this), amount);

        uint256 toBasket = (amount * BASKET_BPS) / 10_000;
        uint256 toGold = (amount * GOLD_BPS) / 10_000;
        uint256 toFloor = amount - toBasket - toGold;

        basketAcc[stock] += toBasket;
        goldPot[stock] += toGold;

        Floor storage floor = floors[floorIdx];
        if (floor.totalWeight == 0) {
            floor.potPending += toFloor;
        } else {
            floor.accPerWeight += (toFloor * ACC_SCALE) / floor.totalWeight;
        }
        emit FeesNotified(floorIdx, amount, toFloor, toBasket, toGold);
    }

    function creditLegacy(uint256 id, address token, uint256 amount) external nonReentrant {
        if (msg.sender != migrator) revert NotMigrator();
        if (!wiringSealed || !attributesSealed) revert NotSealed();
        if (!quotron.isHardwired(id)) revert NotHardwiredId();
        if (amount == 0 || !_validLegacyToken(id, token)) {
            revert InvalidLegacyToken();
        }

        _safeTransferFrom(token, msg.sender, address(this), amount);
        legacyCredit[id][token] += amount;
        emit LegacyCredited(id, token, amount);
    }

    function _validLegacyToken(uint256 id, address token) internal view returns (bool) {
        (uint8 floorCode,) = attributesOf(id);
        if (floorCode < 10) return token == floorStocks[floorCode];
        if (floorCode == FLOOR_GOLD && token == address(paxg)) return true;
        for (uint256 i; i < 10; ++i) {
            if (token == floorStocks[i]) return true;
        }
        return false;
    }

    // ── Quotron callbacks ───────────────────────────────────────────

    function onHardwire(uint256 id, address owner_) external {
        if (msg.sender != address(quotron)) revert NotQuotron();
        if (!wiringSealed || !attributesSealed) revert NotSealed();
        (uint8 floorCode, uint8 tierIdx) = attributesOf(id);
        if (floorCode >= 10) return;

        Floor storage floor = floors[floorCode];
        uint256 weight = uint256(tierWeights[tierIdx]) * _boost(owner_) / BOOST_DEN;
        Terminal storage terminal = terminals[id];
        terminal.active = true;
        terminal.weight = uint128(weight);
        terminal.rewardDebt = floor.accPerWeight;

        if (floor.totalWeight == 0 && floor.potPending != 0) {
            terminal.credited += floor.potPending;
            emit FloorPotClaimed(floorCode, id, floor.potPending);
            floor.potPending = 0;
        }
        floor.totalWeight += weight;
    }

    function onHardwiredTransfer(uint256 id, address, address to) external {
        if (msg.sender != address(quotron)) revert NotQuotron();
        _reprice(id, to);
    }

    // ── views + claims ──────────────────────────────────────────────

    function _boost(address account) internal view returns (uint256) {
        return brokers.balanceOf(account) > 0 ? BOOST_NUM : BOOST_DEN;
    }

    function weightOf(uint256 id) external view returns (uint256) {
        Terminal storage terminal = terminals[id];
        if (!terminal.active) return 0;
        (, uint8 tierIdx) = attributesOf(id);
        return uint256(tierWeights[tierIdx]) * _boost(quotron.ownerOfId(id)) / BOOST_DEN;
    }

    function pending(uint256 id) public view returns (uint256 amount, address stockToken) {
        (uint8 floorCode,) = attributesOf(id);
        if (floorCode >= 10) return (0, address(0));
        stockToken = floorStocks[floorCode];
        Terminal storage terminal = terminals[id];
        amount = legacyCredit[id][stockToken];
        if (!terminal.active) return (amount, stockToken);
        Floor storage floor = floors[floorCode];
        amount += terminal.credited + (uint256(terminal.weight) * (floor.accPerWeight - terminal.rewardDebt))
        / ACC_SCALE;
    }

    function claim(uint256[] calldata ids) external nonReentrant {
        for (uint256 i; i < ids.length; ++i) {
            uint256 id = ids[i];
            if (!quotron.isHardwired(id)) revert NotHardwiredId();
            address idOwner = quotron.ownerOfId(id);
            if (idOwner != msg.sender) revert NotIdOwner();

            (uint8 floorCode,) = attributesOf(id);
            if (floorCode < 10) {
                _claimFloor(id, floorCode, idOwner);
            } else if (floorCode == FLOOR_BASKET) {
                _claimBasket(id, idOwner);
            } else {
                _claimGold(id, idOwner);
            }
        }
    }

    function _claimFloor(uint256 id, uint8 floorCode, address to) internal {
        address stock = floorStocks[floorCode];
        Terminal storage terminal = terminals[id];
        Floor storage floor = floors[floorCode];
        uint256 amount = terminal.credited + legacyCredit[id][stock]
            + (uint256(terminal.weight) * (floor.accPerWeight - terminal.rewardDebt)) / ACC_SCALE;

        terminal.credited = 0;
        terminal.rewardDebt = floor.accPerWeight;
        delete legacyCredit[id][stock];
        _repriceStored(id, floorCode, to);

        if (amount != 0) {
            _safeTransfer(stock, to, amount);
            emit Claimed(id, to, stock, amount);
        }
    }

    function basketPending(uint256 id, address stock) public view returns (uint256) {
        return basketAcc[stock] / 3 - basketClaimed[id][stock] + legacyCredit[id][stock];
    }

    function _claimBasket(uint256 id, address to) internal {
        for (uint256 i; i < 10; ++i) {
            address stock = floorStocks[i];
            uint256 fresh = basketAcc[stock] / 3 - basketClaimed[id][stock];
            uint256 amount = fresh + legacyCredit[id][stock];
            if (fresh != 0) basketClaimed[id][stock] += fresh;
            delete legacyCredit[id][stock];
            if (amount != 0) {
                _safeTransfer(stock, to, amount);
                emit Claimed(id, to, stock, amount);
            }
        }
    }

    function goldPendingPaxg() public view returns (uint256) {
        return legacyCredit[GOLD_ID][address(paxg)];
    }

    function goldPendingStock(address stock) public view returns (uint256) {
        return goldPot[stock] - goldClaimed[stock] + legacyCredit[GOLD_ID][stock];
    }

    function _claimGold(uint256 id, address to) internal {
        for (uint256 i; i < 10; ++i) {
            address stock = floorStocks[i];
            uint256 fresh = goldPot[stock] - goldClaimed[stock];
            uint256 amount = fresh + legacyCredit[id][stock];
            if (fresh != 0) goldClaimed[stock] += fresh;
            delete legacyCredit[id][stock];
            if (amount != 0) {
                _safeTransfer(stock, to, amount);
                emit Claimed(id, to, stock, amount);
            }
        }

        uint256 legacyPaxg = legacyCredit[id][address(paxg)];
        delete legacyCredit[id][address(paxg)];
        if (legacyPaxg != 0) {
            _safeTransfer(address(paxg), to, legacyPaxg);
            emit Claimed(id, to, address(paxg), legacyPaxg);
        }
    }

    // ── boost repricing ─────────────────────────────────────────────

    function poke(uint256 id) external {
        if (!quotron.isHardwired(id)) revert NotHardwiredId();
        _reprice(id, quotron.ownerOfId(id));
    }

    function _reprice(uint256 id, address currentOwner) internal {
        (uint8 floorCode,) = attributesOf(id);
        if (floorCode >= 10) return;
        _settle(id, floorCode);
        _repriceStored(id, floorCode, currentOwner);
    }

    function _settle(uint256 id, uint8 floorCode) internal {
        Terminal storage terminal = terminals[id];
        if (!terminal.active) return;
        Floor storage floor = floors[floorCode];
        terminal.credited += (uint256(terminal.weight) * (floor.accPerWeight - terminal.rewardDebt)) / ACC_SCALE;
        terminal.rewardDebt = floor.accPerWeight;
    }

    function _repriceStored(uint256 id, uint8 floorCode, address currentOwner) internal {
        Terminal storage terminal = terminals[id];
        if (!terminal.active) return;
        (, uint8 tierIdx) = attributesOf(id);
        uint256 newWeight = uint256(tierWeights[tierIdx]) * _boost(currentOwner) / BOOST_DEN;
        uint256 oldWeight = terminal.weight;
        if (newWeight != oldWeight) {
            Floor storage floor = floors[floorCode];
            floor.totalWeight = floor.totalWeight - oldWeight + newWeight;
            terminal.weight = uint128(newWeight);
            emit Poked(id, oldWeight, newWeight);
        }
    }

    // ── token helpers ───────────────────────────────────────────────

    function _safeTransfer(address token, address to, uint256 amount) internal {
        (bool ok, bytes memory data) = token.call(abi.encodeCall(IERC20RewardsV2.transfer, (to, amount)));
        if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert TokenTransferFailed();
        }
    }

    function _safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        (bool ok, bytes memory data) = token.call(abi.encodeCall(IERC20RewardsV2.transferFrom, (from, to, amount)));
        if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert TokenTransferFailed();
        }
    }
}
