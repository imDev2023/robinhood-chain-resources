// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IQuotronReflections} from "./interfaces/IQuotronReflections.sol";

interface IQuotron404View {
    function ownerOfId(uint256 id) external view returns (address);
    function isHardwired(uint256 id) external view returns (bool);
}

interface IERC721Balance {
    function balanceOf(address owner) external view returns (uint256);
}

interface IERC20Minimal {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address a) external view returns (uint256);
}

/// @title QuotronReflections — the reward engine for hardwired terminals
/// @notice Only HARDWIRED terminals earn. Fees arrive from the floor
/// hook denominated in each floor's stock token and split:
///   82.5% -> that floor's lit terminals (weight-based masterchef)
///   12.5% -> the three basket Relics (ids 4441-4443), split equally
///    5.0% -> the Gold Indicator pot (id 4444), keeper-converted to PAXG
/// (равивalent to the spec's 1.65% / 0.25% / 0.10% carve of a 2.0%
/// reflections share of volume.)
///
/// Weights: tier base (100/150/250/500) x live STONK BROKERS boost
/// (125/100 while the owner's wallet holds >= 1 Broker). Boost is
/// checkpointed at hardwire/transfer/claim and publicly re-priceable
/// via poke() — the Curve-kick pattern.
///
/// FCFS: a floor's fees accrued before its first hardwire pot up and
/// are credited to that floor's FIRST hardwired terminal. Relic streams
/// accrue from launch and belong to whoever hardwires the relic.
contract QuotronReflections is IQuotronReflections {
    // ── constants ───────────────────────────────────────────────────
    uint256 public constant BASKET_BPS = 1250; // of notified amount
    uint256 public constant GOLD_BPS = 500;
    uint256 public constant BOOST_NUM = 125; // 1.25x
    uint256 public constant BOOST_DEN = 100;
    uint256 internal constant ACC_SCALE = 1e18;

    uint8 public constant FLOOR_BASKET = 10; // attribute code: basket relic
    uint8 public constant FLOOR_GOLD = 11; // attribute code: gold indicator
    uint256 public constant GOLD_ID = 4444;

    // ── wiring ──────────────────────────────────────────────────────
    address public owner;
    address public hook;
    address public keeper;
    IQuotron404View public immutable quotron;
    IERC721Balance public immutable brokers;
    IERC20Minimal public paxg;

    // floorIndex (0-9) -> stock token
    address[10] public floorStocks;
    bool public stocksSet;

    // ── attributes (uploaded in batches, verified vs the commitment,
    //    then sealed forever) ────────────────────────────────────────
    /// @dev packed: floorCode (0-9 floor, 10 basket, 11 gold) | tierIdx << 4
    mapping(uint256 => uint8) public packedAttr;
    uint256 public attrCount;
    bool public attributesSealed;
    uint16[4] public tierWeights = [100, 150, 250, 500];

    // ── floor accounting (masterchef) ───────────────────────────────
    struct Floor {
        uint256 accPerWeight; // scaled by ACC_SCALE
        uint256 totalWeight;
        uint256 potPending; // fees accrued before first hardwire (FCFS)
    }

    Floor[10] public floors;

    struct Terminal {
        uint128 weight; // checkpointed: tier base x boost
        uint128 rewardDebtSlot; // unused padding safety
        uint256 rewardDebt; // accPerWeight snapshot units
        uint256 credited; // settled-but-unclaimed stock
        bool active;
    }

    mapping(uint256 => Terminal) public terminals;

    // ── relic accounting ────────────────────────────────────────────
    // basket: per-stock cumulative (total for all three), each relic
    // entitled to 1/3; claims tracked per relic per stock.
    mapping(address => uint256) public basketAcc;
    mapping(uint256 => mapping(address => uint256)) public basketClaimed;
    // gold indicator: per-stock pot awaiting conversion + PAXG ledger
    mapping(address => uint256) public goldPot;
    uint256 public paxgDeposited;
    uint256 public paxgClaimed;

    // ── events ──────────────────────────────────────────────────────
    event FeesNotified(uint8 indexed floorIdx, uint256 amount, uint256 toFloor, uint256 toBasket, uint256 toGold);
    event Claimed(uint256 indexed id, address indexed to, address stock, uint256 amount);
    event Poked(uint256 indexed id, uint256 oldWeight, uint256 newWeight);
    event FloorPotClaimed(uint8 indexed floorIdx, uint256 indexed id, uint256 amount);
    event GoldPulled(address indexed stock, uint256 amount, address to);
    event PaxgDeposited(uint256 amount);

    error NotOwner();
    error NotHook();
    error NotKeeper();
    error NotQuotron();
    error AttributesSealed_();
    error NotSealed();
    error NotHardwiredId();
    error NotIdOwner();
    error Reentrancy();

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

    constructor(address quotron_, address brokers_) {
        owner = msg.sender;
        quotron = IQuotron404View(quotron_);
        brokers = IERC721Balance(brokers_);
    }

    // ── admin wiring ────────────────────────────────────────────────
    function setHook(address h) external onlyOwner {
        hook = h;
    }

    function setKeeper(address k) external onlyOwner {
        keeper = k;
    }

    function setPaxg(address p) external onlyOwner {
        paxg = IERC20Minimal(p);
    }

    function setFloorStocks(address[10] calldata stocks) external onlyOwner {
        require(!stocksSet, "set");
        floorStocks = stocks;
        stocksSet = true;
    }

    function setAttributes(uint16[] calldata ids, uint8[] calldata packed) external onlyOwner {
        if (attributesSealed) revert AttributesSealed_();
        require(ids.length == packed.length, "len");
        for (uint256 i; i < ids.length; ++i) {
            require(ids[i] >= 1 && ids[i] <= 4444, "id");
            if (packedAttr[ids[i]] == 0) attrCount += 1;
            require(packed[i] != 0, "zero"); // encode floor 0 as 0x80 | ...
            packedAttr[ids[i]] = packed[i];
        }
    }

    function sealAttributes() external onlyOwner {
        require(attrCount == 4444, "incomplete");
        attributesSealed = true;
    }

    /// @dev floorCode 0-9 floor, 10 basket relic, 11 gold indicator.
    /// Stored with 0x80 flag so "unset" (0) is distinguishable.
    function attributesOf(uint256 id) public view returns (uint8 floorCode, uint8 tierIdx) {
        uint8 p = packedAttr[id];
        require(p != 0, "unset");
        floorCode = p & 0x0f;
        tierIdx = (p >> 4) & 0x07;
    }

    // ── hook inflow ─────────────────────────────────────────────────
    /// @notice Hook transfers `amount` of floor's stock here first, then
    /// notifies. Splits floor/basket/gold and advances the accumulator.
    function notifyFees(uint8 floorIdx, uint256 amount) external {
        if (msg.sender != hook) revert NotHook();
        require(floorIdx < 10, "floor");
        address stock = floorStocks[floorIdx];

        uint256 toBasket = (amount * BASKET_BPS) / 10_000;
        uint256 toGold = (amount * GOLD_BPS) / 10_000;
        uint256 toFloor = amount - toBasket - toGold;

        basketAcc[stock] += toBasket;
        goldPot[stock] += toGold;

        Floor storage f = floors[floorIdx];
        if (f.totalWeight == 0) {
            f.potPending += toFloor;
        } else {
            f.accPerWeight += (toFloor * ACC_SCALE) / f.totalWeight;
        }
        emit FeesNotified(floorIdx, amount, toFloor, toBasket, toGold);
    }

    // ── Quotron404 callbacks ────────────────────────────────────────
    function onHardwire(uint256 id, address owner_) external {
        if (msg.sender != address(quotron)) revert NotQuotron();
        if (!attributesSealed) revert NotSealed();
        (uint8 floorCode, uint8 tierIdx) = attributesOf(id);
        if (floorCode >= 10) return; // relics: pot-based, nothing to checkpoint

        Floor storage f = floors[uint8(floorCode)];
        uint256 w = uint256(tierWeights[tierIdx]) * _boost(owner_) / BOOST_DEN;

        Terminal storage t = terminals[id];
        t.active = true;
        t.weight = uint128(w);
        t.rewardDebt = f.accPerWeight;

        // FCFS: first lit terminal on the floor takes the whole pot
        if (f.totalWeight == 0 && f.potPending > 0) {
            t.credited += f.potPending;
            emit FloorPotClaimed(floorCode, id, f.potPending);
            f.potPending = 0;
        }
        f.totalWeight += w;
    }

    function onHardwiredTransfer(uint256 id, address, address to) external {
        if (msg.sender != address(quotron)) revert NotQuotron();
        _reprice(id, to);
    }

    // ── views + claims ──────────────────────────────────────────────
    function _boost(address a) internal view returns (uint256) {
        return brokers.balanceOf(a) > 0 ? BOOST_NUM : BOOST_DEN;
    }

    function weightOf(uint256 id) external view returns (uint256) {
        Terminal storage t = terminals[id];
        if (!t.active) return 0;
        (, uint8 tierIdx) = attributesOf(id);
        return uint256(tierWeights[tierIdx]) * _boost(quotron.ownerOfId(id)) / BOOST_DEN;
    }

    function pending(uint256 id) public view returns (uint256 amount, address stockToken) {
        (uint8 floorCode,) = attributesOf(id);
        if (floorCode >= 10) return (0, address(0)); // use relic views
        Terminal storage t = terminals[id];
        if (!t.active) return (0, floorStocks[floorCode]);
        Floor storage f = floors[floorCode];
        amount = t.credited + (uint256(t.weight) * (f.accPerWeight - t.rewardDebt)) / ACC_SCALE;
        stockToken = floorStocks[floorCode];
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
                _claimGold(idOwner);
            }
        }
    }

    function _claimFloor(uint256 id, uint8 floorCode, address to) internal {
        Terminal storage t = terminals[id];
        Floor storage f = floors[floorCode];
        uint256 amt = t.credited + (uint256(t.weight) * (f.accPerWeight - t.rewardDebt)) / ACC_SCALE;
        t.credited = 0;
        t.rewardDebt = f.accPerWeight;
        // reprice boost at claim (live check)
        _repriceStored(id, floorCode, to);
        if (amt > 0) {
            address stock = floorStocks[floorCode];
            require(IERC20Minimal(stock).transfer(to, amt), "transfer");
            emit Claimed(id, to, stock, amt);
        }
    }

    /// @notice Basket relic pending for one stock.
    function basketPending(uint256 id, address stock) public view returns (uint256) {
        return basketAcc[stock] / 3 - basketClaimed[id][stock];
    }

    function _claimBasket(uint256 id, address to) internal {
        for (uint256 s; s < 10; ++s) {
            address stock = floorStocks[s];
            uint256 amt = basketAcc[stock] / 3 - basketClaimed[id][stock];
            if (amt > 0) {
                basketClaimed[id][stock] += amt;
                require(IERC20Minimal(stock).transfer(to, amt), "transfer");
                emit Claimed(id, to, stock, amt);
            }
        }
    }

    function goldPendingPaxg() public view returns (uint256) {
        return paxgDeposited - paxgClaimed;
    }

    function _claimGold(address to) internal {
        uint256 amt = paxgDeposited - paxgClaimed;
        if (amt > 0) {
            paxgClaimed += amt;
            require(paxg.transfer(to, amt), "transfer");
            emit Claimed(GOLD_ID, to, address(paxg), amt);
        }
    }

    // ── boost repricing (Curve-kick pattern) ────────────────────────
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
        Terminal storage t = terminals[id];
        if (!t.active) return;
        Floor storage f = floors[floorCode];
        t.credited += (uint256(t.weight) * (f.accPerWeight - t.rewardDebt)) / ACC_SCALE;
        t.rewardDebt = f.accPerWeight;
    }

    function _repriceStored(uint256 id, uint8 floorCode, address currentOwner) internal {
        Terminal storage t = terminals[id];
        if (!t.active) return;
        (, uint8 tierIdx) = attributesOf(id);
        uint256 newW = uint256(tierWeights[tierIdx]) * _boost(currentOwner) / BOOST_DEN;
        uint256 oldW = t.weight;
        if (newW != oldW) {
            Floor storage f = floors[floorCode];
            f.totalWeight = f.totalWeight - oldW + newW;
            t.weight = uint128(newW);
            emit Poked(id, oldW, newW);
        }
    }

    // ── Gold Indicator keeper rail ──────────────────────────────────
    /// @notice Keeper pulls accrued stock for offchain conversion to
    /// PAXG (Relay route: stock -> USDG -> bridge -> PAXG -> bridge in).
    function pullGoldPot(address stock, uint256 amount, address to) external {
        if (msg.sender != keeper) revert NotKeeper();
        require(goldPot[stock] >= amount, "pot");
        goldPot[stock] -= amount;
        require(IERC20Minimal(stock).transfer(to, amount), "transfer");
        emit GoldPulled(stock, amount, to);
    }

    /// @notice Keeper deposits converted PAXG for the Gold Indicator.
    function depositPaxg(uint256 amount) external {
        if (msg.sender != keeper) revert NotKeeper();
        require(paxg.transferFrom(msg.sender, address(this), amount), "transferFrom");
        paxgDeposited += amount;
        emit PaxgDeposited(amount);
    }
}
