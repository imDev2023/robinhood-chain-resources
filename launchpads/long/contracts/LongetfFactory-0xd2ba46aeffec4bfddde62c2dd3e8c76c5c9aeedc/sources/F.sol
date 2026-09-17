// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title LongetfFactory
 * @notice Deploys one vault per token and binds it to a long.xyz pool only
 *         after verifying, on-chain, that the vault really is that pool's fee
 *         beneficiary.
 *
 * WHY A FACTORY AT ALL
 *   long.xyz records fee beneficiaries at launch and they are effectively
 *   permanent afterwards. So the vault must EXIST BEFORE the token does — its
 *   address goes into the launch parameters. That ordering drives everything
 *   below.
 *
 * THE FLOW
 *   1. deployVault(salt, creator)  — vault exists, address is known
 *   2. the dev launches on long.xyz with that vault as the 95% beneficiary
 *   3. register(token, vault)      — this contract READS the pool's beneficiary
 *                                    list and refuses unless the vault is
 *                                    genuinely on it
 *
 *   Step 3 is a check, not a promise. Nobody has to be trusted for the
 *   registry to be accurate: a token whose fees do not actually flow to its
 *   vault cannot be registered at all.
 *
 * ADDRESS ORDERING — the non-obvious constraint
 *   Doppler requires the beneficiary array to be sorted ascending by address
 *   (`UnorderedBeneficiaries`). The protocol's own beneficiary sits at
 *   0x21e2ce70..., so a vault that sorts BELOW it can never be launched with —
 *   and the failure surfaces as an opaque revert during launch, long after the
 *   dev has committed. deployVault therefore refuses such a salt up front,
 *   where the error is cheap and legible.
 *
 * WHAT THIS CONTRACT DELIBERATELY CANNOT DO
 *   It never forwards arbitrary calldata. The only external calls it makes are
 *   to a hard-coded pool initializer with a hard-coded selector. A factory that
 *   could be asked to call anything would be a way to reach
 *   updateBeneficiary() and move a vault's fee stream — the single thing the
 *   whole design exists to prevent.
 */

interface IPoolInitializer {
    struct BeneficiaryData {
        address beneficiary;
        uint96 shares;
    }
    function getBeneficiaries(address asset) external view returns (BeneficiaryData[] memory);
}

interface IVault {
    function initialize(
        address meme,
        address stock,
        address feeWallet,
        address operator,
        address owner
    ) external;
}

contract LongetfFactory {
    /// @dev long.xyz pool initializer. Hard-coded: the registry's guarantee is
    ///      only as good as the contract it reads beneficiaries from, so that
    ///      contract must not be swappable by anyone, including the owner.
    address public constant POOL_INITIALIZER = 0x4e3468951D49f2EEa976eD0D6e75fFCb44a9a544;

    /// @dev Doppler's own beneficiary. Every vault address must sort ABOVE this
    ///      or the launch reverts on ordering. Verified on-chain 2026-09-01.
    address public constant PROTOCOL_BENEFICIARY = 0x21E2ce70511e4FE542a97708e89520471DAa7A66;

    /// @dev The ONLY vault bytecode this factory will deploy.
    ///
    ///      Without this pin, deployVault would accept any init code and every
    ///      vault would have to be audited separately — a dev could never be
    ///      sure their vault is the reviewed contract rather than one with an
    ///      extra function that reaches updateBeneficiary(). Pinning the hash
    ///      collapses that to a single check anyone can repeat: hash the
    ///      published source, compare it to this constant, and every vault this
    ///      factory has ever produced is covered by that one comparison.
    ///
    ///      Set at construction and never writable afterwards, so the guarantee
    ///      cannot be relaxed later by whoever holds the owner key.
    bytes32 public immutable VAULT_INIT_CODE_HASH;

    /// @dev Shares are WAD-denominated; the creator leg is ~95%. A vault holding
    ///      less than this is not the real fee recipient and must not register.
    uint96 public constant MIN_VAULT_SHARES = 0.90e18;

    /// @dev getState(address) on the pool initializer. Its FIRST return word is
    ///      the numeraire — the asset the pool is anchored to, and therefore the
    ///      asset holders are owed. Read from the chain rather than accepted as
    ///      a parameter: a vault pointed at the wrong asset would quietly pay
    ///      holders in something other than what they were promised.
    bytes4 private constant SEL_GET_STATE = 0x1bab58f5;

    address public owner;
    address public pendingOwner;

    /// @dev Applied to every vault at registration. Owner-set so operations can
    ///      move to a new signer without redeploying the factory.
    address public vaultOperator;
    address public vaultOwner;

    mapping(address => address) public vaultOf;      // token  => vault
    mapping(address => address) public tokenOf;      // vault  => token
    mapping(address => address) public creatorOf;    // vault  => creator
    address[] public vaults;

    event VaultDeployed(address indexed vault, address indexed creator, bytes32 salt);
    event Registered(address indexed token, address indexed vault, address indexed creator, uint96 shares);
    event OwnerChanged(address indexed from, address indexed to);

    error NotOwner();
    error ZeroAddress();
    error VaultSortsTooLow(address vault, address mustExceed);
    error AlreadyDeployed();
    error AlreadyRegistered();
    error UnknownVault();
    error VaultNotBeneficiary(address vault);
    error SharesTooLow(uint96 got, uint96 required);
    error DeployFailed();
    error WrongVaultCode(bytes32 got, bytes32 expected);
    error NumeraireUnreadable(address token);

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(address owner_, bytes32 vaultInitCodeHash_) {
        if (owner_ == address(0)) revert ZeroAddress();
        if (vaultInitCodeHash_ == bytes32(0)) revert ZeroAddress();
        owner = owner_;
        VAULT_INIT_CODE_HASH = vaultInitCodeHash_;
    }

    /* ---------------------------- deployment ---------------------------- */

    /// @notice Address a given salt would produce. Callers mine salts against
    ///         this off-chain until the result sorts above PROTOCOL_BENEFICIARY.
    /// @dev The effective salt is bound to the creator, and that binding is a
    ///      front-running defence rather than a convenience.
    ///
    ///      Deployment is permissionless so a dev can set their own vault up
    ///      without waiting on us. With a raw salt, anyone watching the mempool
    ///      could take a pending deployment, resubmit the same salt naming
    ///      THEMSELVES as creator, and win the race — the dev would then launch
    ///      against a vault whose meme surplus pays a stranger. Mixing the
    ///      creator into the salt makes the attacker's vault land at a
    ///      different address entirely, so the dev's intended address is simply
    ///      not reachable by anyone else.
    function effectiveSalt(bytes32 salt, address creator) public pure returns (bytes32) {
        return keccak256(abi.encode(creator, salt));
    }

    function predictVault(bytes32 salt, address creator, bytes memory creationCode)
        public view returns (address)
    {
        return address(uint160(uint256(keccak256(
            abi.encodePacked(bytes1(0xff), address(this), effectiveSalt(salt, creator), keccak256(creationCode))
        ))));
    }

    /// @notice True when a salt yields a usable vault address. Cheap pre-flight
    ///         so a dev never discovers the ordering rule mid-launch.
    function isSaltUsable(bytes32 salt, address creator, bytes memory creationCode)
        external view returns (bool)
    {
        return uint160(predictVault(salt, creator, creationCode)) > uint160(PROTOCOL_BENEFICIARY);
    }

    /// @notice Deploy a vault at a deterministic address.
    /// @param salt CREATE2 salt, mined so the address sorts above the protocol
    ///        beneficiary. Rejected here rather than failing opaquely at launch.
    /// @param creator the dev this vault pays the meme surplus to
    /// @param creationCode the vault's init code, supplied by the caller so this
    ///        factory stays agnostic to the vault implementation it deploys
    /// @notice Permissionless: a dev deploys their own vault and pays for it.
    ///         Nothing here can be abused by a stranger — the bytecode is
    ///         pinned, the address is bound to the creator, and a vault means
    ///         nothing until register() proves the chain agrees.
    function deployVault(bytes32 salt, address creator, bytes memory creationCode)
        external
        returns (address vault)
    {
        if (creator == address(0)) revert ZeroAddress();

        if (keccak256(creationCode) != VAULT_INIT_CODE_HASH) {
            revert WrongVaultCode(keccak256(creationCode), VAULT_INIT_CODE_HASH);
        }

        address predicted = predictVault(salt, creator, creationCode);
        if (uint160(predicted) <= uint160(PROTOCOL_BENEFICIARY)) {
            revert VaultSortsTooLow(predicted, PROTOCOL_BENEFICIARY);
        }
        if (predicted.code.length != 0) revert AlreadyDeployed();

        bytes32 eSalt = effectiveSalt(salt, creator);
        assembly {
            vault := create2(0, add(creationCode, 0x20), mload(creationCode), eSalt)
        }
        if (vault == address(0)) revert DeployFailed();

        creatorOf[vault] = creator;
        // Deliberately NOT added to `vaults` here. Deployment is open, so that
        // list would otherwise fill with vaults nobody ever launched a token
        // against. The public list is built in register(), where the chain has
        // already proved the pairing is real.
        emit VaultDeployed(vault, creator, salt);
    }

    /* ---------------------------- registration --------------------------- */

    /// @notice Bind a launched token to its vault.
    ///
    ///         The pool's beneficiary list is read from POOL_INITIALIZER and
    ///         must actually contain this vault with a majority share. There is
    ///         no operator assertion to trust and no way to register a token
    ///         whose fees flow somewhere else — the chain is the only witness.
    ///
    ///         Permissionless on purpose: anyone may finalise a registration
    ///         that the chain already proves is true.
    function register(address token, address vault) external returns (uint96 shares) {
        if (token == address(0) || vault == address(0)) revert ZeroAddress();
        if (creatorOf[vault] == address(0)) revert UnknownVault();
        if (vaultOf[token] != address(0)) revert AlreadyRegistered();
        if (tokenOf[vault] != address(0)) revert AlreadyRegistered();

        IPoolInitializer.BeneficiaryData[] memory list =
            IPoolInitializer(POOL_INITIALIZER).getBeneficiaries(token);

        bool found;
        for (uint256 i = 0; i < list.length; i++) {
            if (list[i].beneficiary == vault) {
                shares = list[i].shares;
                found = true;
                break;
            }
        }
        if (!found) revert VaultNotBeneficiary(vault);
        if (shares < MIN_VAULT_SHARES) revert SharesTooLow(shares, MIN_VAULT_SHARES);

        // The anchored asset comes from the chain, never from the caller.
        (bool okState, bytes memory raw) =
            POOL_INITIALIZER.staticcall(abi.encodeWithSelector(SEL_GET_STATE, token));
        if (!okState || raw.length < 32) revert NumeraireUnreadable(token);
        address numeraire;
        assembly { numeraire := mload(add(raw, 0x20)) }
        if (numeraire == address(0) || numeraire == token) revert NumeraireUnreadable(token);

        vaultOf[token] = vault;
        tokenOf[vault] = token;
        vaults.push(vault);

        // Bind the vault. feeWallet is the vault itself: fees land where they
        // are spent, so there is no separate key holding holder funds.
        IVault(vault).initialize(
            token,
            numeraire,
            vault,
            vaultOperator == address(0) ? owner : vaultOperator,
            vaultOwner == address(0) ? owner : vaultOwner
        );

        emit Registered(token, vault, creatorOf[vault], shares);
    }

    /* ------------------------------- views ------------------------------- */

    function vaultCount() external view returns (uint256) {
        return vaults.length;
    }

    /// @notice Registered vaults, newest last. For the site's token grid.
    function page(uint256 start, uint256 count)
        external
        view
        returns (address[] memory vaultList, address[] memory tokenList)
    {
        uint256 n = vaults.length;
        if (start >= n) return (new address[](0), new address[](0));
        uint256 end = start + count;
        if (end > n) end = n;
        uint256 len = end - start;
        vaultList = new address[](len);
        tokenList = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            vaultList[i] = vaults[start + i];
            tokenList[i] = tokenOf[vaults[start + i]];
        }
    }

    /// @notice Operator and owner applied to vaults registered from now on.
    ///         Existing vaults are untouched — their settings are theirs.
    function setVaultRoles(address operator_, address owner_) external onlyOwner {
        vaultOperator = operator_;
        vaultOwner = owner_;
    }

    /* ------------------------------ ownership ---------------------------- */

    /// @dev Two-step, so a mistyped address cannot orphan the factory.
    function transferOwnership(address to) external onlyOwner {
        if (to == address(0)) revert ZeroAddress();
        pendingOwner = to;
    }

    function acceptOwnership() external {
        if (msg.sender != pendingOwner) revert NotOwner();
        emit OwnerChanged(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}
