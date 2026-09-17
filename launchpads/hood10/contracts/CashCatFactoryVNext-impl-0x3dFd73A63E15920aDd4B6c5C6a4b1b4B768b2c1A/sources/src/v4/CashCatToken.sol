// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

/// @dev The fee engine that charges this token's pool. Declared here rather
///      than imported so the token depends on the one function it reads.
interface IPoolFeeSource {
    /// @return the pool's fee right now, in pips of the ETH side (1e6 = 100%)
    function currentFeeRate(bytes32 poolId, address swapper) external view returns (uint256);
}

/// @dev The launchpad that created this token, asked once at launch which fee
///      engine the pool is being created under.
interface ILaunchFactory {
    function hook() external view returns (address);
}

/// @title CashCatToken
/// @notice Memecoin deployed by the CashCat factory. Immutable and ownerless:
///         fixed supply minted once to the factory (which pairs it all into a
///         permanently locked Uniswap v4 position), metadata stored on-chain.
///         After launch nobody — including the platform — has any special
///         power over it.
///
///         Deployed as an EIP-1167 minimal proxy of one master implementation:
///         every token shares the master's verified source on the explorer,
///         and the proxy's target is hard-wired into its bytecode, so a token
///         can never be upgraded or repointed. The factory clones and
///         initializes in the same transaction; the master itself is locked
///         against initialization in its constructor.
contract CashCatToken is Initializable, ERC20Upgradeable {
    struct BalanceCheckpoint {
        uint64 id;
        uint192 balance;
    }

    struct Socials {
        string telegram;
        string twitter;
        string discord;
        string website;
        string extra;
    }

    struct TokenConfig {
        string name;
        string symbol;
        string logo; // e.g. ipfs://<CID> of the token image
        string description;
        string metadataURI; // ipfs://<CID> of the metadata JSON (see tokenURI)
        Socials socials;
        address creator;
        uint256 supply;
        uint24 taxBps; // the pool's trading tax, basis points (100 = 1%)
    }

    error NotFactory();
    error AlreadyLaunched();
    error SupplyTooLarge();

    /// @notice The fee engine works in pips (1e6 = 100%) and this token reports
    ///         its tax in basis points (1e4 = 100%), so a rate divides by this
    ///         to cross between them. The same conversion the factory applies to
    ///         the figure it stamps into `taxBps`, and the two are required to
    ///         agree: `buyTaxRate` is that figure rounded the same way.
    uint256 public constant PIPS_PER_BP = 100;

    /// @notice The factory that cloned and initialized this token.
    address public factory;
    /// @notice The creator wallet, in launchpad terms.
    address public deployer;
    /// @notice The pool's **steady-state** trading tax in basis points
    ///         (100 = 1%). A launch window can start above this and decay down
    ///         to it, so this is the floor rather than what is being charged at
    ///         any given moment — read `buyTaxRate` for that.
    ///
    ///         The tax itself is charged pool-side by the hook, in ETH — the
    ///         token has no transfer tax and can never grow one.
    uint24 public taxBps;

    string public logo;
    string public description;
    /// @dev ipfs://<CID> of a metadata JSON — the interface aggregators and
    ///      trading terminals actually read (name, symbol, description,
    ///      image, socials). Served under every selector in the wild:
    ///      tokenURI() / metaURI() / contractURI().
    string private _metadataURI;
    Socials private _socials;

    /// @notice Uniswap v4 pool id (v4 pools are ids inside the PoolManager,
    ///         not standalone contracts). The pair currency is native ETH.
    bytes32 public poolId;
    uint256 public launchBlock;
    /// @notice The fee engine charging this token's pool, recorded at launch.
    ///         Held here rather than read from the factory because a pool is
    ///         bound to the engine it launched under: the factory can be
    ///         pointed at a new one for later launches, and this token would
    ///         then be quoting a rate belonging to somebody else's pool.
    address public hook;

    /// @dev Balance history keyed by block number. Every mint/transfer/burn
    ///      records the account's resulting balance against the current block,
    ///      overwriting any earlier entry for that same block, so each block
    ///      keeps exactly one entry: the balance that block ended on.
    ///
    ///      Dividend rounds read this at a block that has already closed, which
    ///      is what makes a snapshot something a position has to survive rather
    ///      than an instant a caller can pick. A balance opened and closed
    ///      inside one block leaves nothing behind to be weighted.
    mapping(address => BalanceCheckpoint[]) private _balanceCheckpoints;

    /// @dev Supply history, in the same shape and read the same way. Written
    ///      only when supply actually moves — a mint or a burn — so an ordinary
    ///      transfer adds nothing to it.
    ///
    ///      A holder's weight in a dividend round is their balance measured
    ///      against everything in circulation. Both halves of that have to come
    ///      from the same closed block or the comparison is between two
    ///      different moments: a burn landing between them would shrink the
    ///      whole while leaving the parts as they were, and inflate whatever
    ///      share was measured against it.
    BalanceCheckpoint[] private _supplyCheckpoints;

    /// @dev The master implementation locks itself; only clones initialize.
    constructor() {
        _disableInitializers();
    }

    /// @notice One-time setup, called by the factory in the same transaction
    ///         that creates the clone — a token can never be observed
    ///         uninitialized. The full supply mints to the factory, which
    ///         locks it into the pool before the transaction ends.
    function initialize(TokenConfig memory config) external initializer {
        if (config.supply > type(uint192).max) revert SupplyTooLarge();
        __ERC20_init(config.name, config.symbol);
        factory = msg.sender;
        deployer = config.creator;
        taxBps = config.taxBps;
        logo = config.logo;
        description = config.description;
        _metadataURI = config.metadataURI;
        _socials = config.socials;
        _mint(msg.sender, config.supply);
    }

    /// @notice Marker for balance history keyed by block number, where an entry
    ///         holds the balance its block ended on. The factory and the
    ///         distributor both require it, so an implementation whose history
    ///         means something else can never be read as though it were this.
    ///
    ///         This is the only checkpoint marker this token answers to. Earlier
    ///         consumers read history through a per-transfer clock that no
    ///         longer exists here, and they identify a token by the marker that
    ///         went with it; leaving that marker in place would let one of them
    ///         accept this token and then revert on every round forever.
    function supportsBlockBalanceCheckpoints() external pure returns (bool) {
        return true;
    }

    /// @notice An account's balance at the end of `blockNumber`. Reading a
    ///         block that has not closed yet gives that account's balance so
    ///         far in it, which is why consumers read closed blocks only.
    function balanceOfAt(address account, uint64 blockNumber) external view returns (uint256) {
        return _valueAt(_balanceCheckpoints[account], blockNumber);
    }

    /// @notice Marker for the whole of what a dividend round reads: balance
    ///         history and supply history, both keyed by block and both holding
    ///         the figure their block closed on.
    ///
    ///         One marker rather than two, because the halves are only useful
    ///         together. A consumer weighing a balance against the supply needs
    ///         both from the same closed block, and a token answering for one
    ///         of them says nothing about the other — a pairing that satisfied
    ///         each check separately could still be unable to run a round.
    function supportsBlockCheckpoints() external pure returns (bool) {
        return true;
    }

    /// @notice The total supply at the end of `blockNumber` — the companion to
    ///         `balanceOfAt`, so a share of supply can be taken at one instant
    ///         rather than assembled from two.
    function totalSupplyAt(uint64 blockNumber) external view returns (uint256) {
        return _valueAt(_supplyCheckpoints, blockNumber);
    }

    /// @dev The last entry at or before `blockNumber`, or zero if the history
    ///      starts after it. Shared by both histories: they are the same shape
    ///      and are read the same way.
    function _valueAt(BalanceCheckpoint[] storage checkpoints, uint64 blockNumber)
        private
        view
        returns (uint256)
    {
        uint256 low;
        uint256 high = checkpoints.length;
        while (low < high) {
            uint256 mid = (low + high) >> 1;
            if (checkpoints[mid].id <= blockNumber) low = mid + 1;
            else high = mid;
        }
        return high == 0 ? 0 : checkpoints[high - 1].balance;
    }

    function _update(address from, address to, uint256 value) internal override {
        super._update(from, to, value);
        if (from != address(0)) _writeCheckpoint(_balanceCheckpoints[from], balanceOf(from));
        if (to != address(0) && to != from) _writeCheckpoint(_balanceCheckpoints[to], balanceOf(to));
        // supply only moves on a mint or a burn, so an ordinary transfer
        // between two holders leaves this history untouched
        if (from == address(0) || to == address(0)) _writeCheckpoint(_supplyCheckpoints, totalSupply());
    }

    function _writeCheckpoint(BalanceCheckpoint[] storage checkpoints, uint256 value) private {
        uint64 blockNumber = uint64(block.number);
        uint256 length = checkpoints.length;
        // One entry per block: a later move in the same block replaces the
        // earlier one, leaving the figure this block finished on.
        if (length != 0 && checkpoints[length - 1].id == blockNumber) {
            checkpoints[length - 1].balance = uint192(value);
        } else {
            checkpoints.push(BalanceCheckpoint({id: blockNumber, balance: uint192(value)}));
        }
    }

    /// @notice One-time hook the factory calls right after initializing the pool.
    function initializePool(bytes32 poolId_) external {
        if (msg.sender != factory) revert NotFactory();
        if (poolId != bytes32(0)) revert AlreadyLaunched();
        poolId = poolId_;
        // The engine this pool is being created under, taken once and kept.
        // Asking the factory later would follow it to whatever engine it is
        // pointed at next, and quote a rate belonging to another pool.
        hook = ILaunchFactory(factory).hook();
        launchBlock = block.number;
    }

    /// @notice Destroys `amount` of the caller's own tokens. Real burn: total
    ///         supply drops on-chain, so explorers and aggregators show the
    ///         supply shrinking rather than a growing dead-address holder.
    ///         Powers self-burn launches; open to any holder.
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function socials() external view returns (Socials memory) {
        return _socials;
    }

    // ————————————— the metadata interface terminals read —————————————
    // The same URI answers every selector in circulation: tokenURI()
    // (Doppler/Bankr tokens), metaURI() (flap tokens), and contractURI()
    // (ERC-7572). It points at a JSON of the shape indexers expect:
    // { name, symbol, description, image, website, twitter, telegram, … }.

    function tokenURI() external view returns (string memory) {
        return _metadataURI;
    }

    function metaURI() external view returns (string memory) {
        return _metadataURI;
    }

    function contractURI() external view returns (string memory) {
        return _metadataURI;
    }

    /// @notice The tax being charged **right now**, in basis points — the
    ///         selectors tax scanners probe. Identical both ways: the pool
    ///         charges the same rate on buys and sells, always in ETH.
    ///
    ///         A launch window can open above the steady-state rate and decay
    ///         down to it, so this is read live from the pool's fee engine
    ///         rather than from a figure stored at launch. Quoting the stored
    ///         figure during such a window would understate what a trade
    ///         actually costs, by as much as ninety times at the extreme.
    ///
    ///         Rounded up, so the answer is never less than what is charged.
    function buyTaxRate() external view returns (uint256) {
        return (taxRatePips() + PIPS_PER_BP - 1) / PIPS_PER_BP;
    }

    function sellTaxRate() external view returns (uint256) {
        return (taxRatePips() + PIPS_PER_BP - 1) / PIPS_PER_BP;
    }

    /// @notice The tax being charged right now, in pips of the ETH side
    ///         (1e6 = 100%). This is the exact figure the pool works in;
    ///         `buyTaxRate` is this rounded into basis points.
    ///
    ///         Before the pool exists — the moment inside the launch
    ///         transaction before it is wired up — this reports the
    ///         steady-state rate, the only rate defined at that point.
    ///
    ///         Once the pool exists this only ever answers from the engine. If
    ///         that answer cannot be had, the call fails rather than falling
    ///         back to the steady-state rate: during a launch window that rate
    ///         is the floor, and quoting it would understate what a trade costs
    ///         by as much as ninety times. A caller learning nothing is safe; a
    ///         caller believing a wrong low number is not.
    function taxRatePips() public view returns (uint256) {
        address feeSource = hook;
        if (feeSource == address(0)) return uint256(taxBps) * PIPS_PER_BP;
        // address(0) is never the launcher, so this reads the rate an ordinary
        // trader pays rather than any one-off launch exemption
        return IPoolFeeSource(feeSource).currentFeeRate(poolId, address(0));
    }

    function getTokenInfo()
        external
        view
        returns (address creator, string memory logo_, string memory description_, Socials memory socials_)
    {
        return (deployer, logo, description, _socials);
    }
}
