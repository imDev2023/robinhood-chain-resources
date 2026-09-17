// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

/// @dev The fee engine that charges this token's pool. Declared here rather
///      than imported so the token depends on the one function it reads.
interface IPoolFeeSource {
    /// @return the pool's fee, in pips of the quote side (1e6 = 100%)
    function currentFeeRate(bytes32 poolId, address swapper) external view returns (uint256);
}

/// @title CashCatTokenV2
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
contract CashCatTokenV2 is Initializable, ERC20Upgradeable {

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

    /// @notice Which generation of token master this is.
    ///
    /// @dev    So a module set can refuse a V1 master rather than discover the
    ///         mismatch at the last call of somebody's launch. The V1 master
    ///         does not answer this at all, which is the point: the check is a
    ///         positive identification, not a version comparison.
    uint256 public constant GENERATION = 2;

    /// @notice The factory that cloned and initialized this token.
    address public factory;
    /// @notice The creator wallet, in launchpad terms.
    address public deployer;
    /// @notice The pool's trading tax in basis points (100 = 1%).
    ///
    ///         Charged pool-side by the hook, in whatever the pool is quoted in.
    ///         The token itself has no transfer tax and can never grow one.
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
    ///         not standalone contracts). The pair currency is whatever the
    ///         launch config named: native ether, or an approved ERC-20.
    bytes32 public poolId;
    uint256 public launchBlock;
    /// @notice The fee engine charging this token's pool, recorded at launch.
    ///         Held here rather than read from the factory because a pool is
    ///         bound to the engine it launched under: the factory can be
    ///         pointed at a new one for later launches, and this token would
    ///         then be quoting a rate belonging to somebody else's pool.
    address public hook;

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

    /// @notice One-time hook the factory calls right after initializing the pool.
    /// @dev The hook is passed in rather than read off the factory.
    ///
    ///      There is no single hook to read: a config names a module set, and
    ///      each set carries its own. The address is therefore passed in and
    ///      recorded here, so a token always reports the engine it launched
    ///      through vNext: the call reverts on an unrecognised selector.
    ///
    ///      Taken once and kept, for the same reason as before. Asking later
    ///      would follow the factory to whatever it is pointed at next and
    ///      quote a rate belonging to another pool.
    function initializePool(bytes32 poolId_, address hook_) external {
        if (msg.sender != factory) revert NotFactory();
        if (poolId != bytes32(0)) revert AlreadyLaunched();
        if (hook_ == address(0)) revert NotFactory();
        poolId = poolId_;
        hook = hook_;
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

    /// @notice The tax being charged, in basis points — the selectors tax
    ///         scanners probe. Identical both ways: the pool charges the same
    ///         rate on buys and sells, always in the asset it is quoted in.
    ///
    ///         Read live from the pool's fee engine rather than from the figure
    ///         stored at launch, so it reflects the pool rather than the
    ///         config that made it.
    ///
    ///         Rounded up, so the answer is never less than what is charged.
    function buyTaxRate() external view returns (uint256) {
        return (taxRatePips() + PIPS_PER_BP - 1) / PIPS_PER_BP;
    }

    function sellTaxRate() external view returns (uint256) {
        return (taxRatePips() + PIPS_PER_BP - 1) / PIPS_PER_BP;
    }

    /// @notice The tax being charged, in pips of the quote side (1e6 = 100%).
    ///         This is the exact figure the pool works in; `buyTaxRate` is it
    ///         rounded into basis points.
    ///
    ///         Before the pool exists — the moment inside the launch transaction
    ///         before it is wired up — this reports the configured rate, the
    ///         only one defined at that point.
    ///
    ///         Once the pool exists it only ever answers from the engine. If
    ///         that answer cannot be had the call fails rather than falling back
    ///         to the stored figure: a caller learning nothing is safe, a caller
    ///         believing a stale number is not.
    function taxRatePips() public view returns (uint256) {
        address feeSource = hook;
        if (feeSource == address(0)) return uint256(taxBps) * PIPS_PER_BP;
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
