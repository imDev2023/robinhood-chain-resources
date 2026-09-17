// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC721Bal {
    function balanceOf(address owner) external view returns (uint256);
}

/// @title QuotronWhitelist — who pays the floor fee during the launch window
/// @notice The floor hook asks exactly one question per swap: "is this
/// address whitelisted?" Everything about HOW an address earns that
/// answer lives here, so the whitelist can grow after the hook is
/// deployed without touching a contract that custodies fees.
///
/// Four independent routes in, checked cheapest-first:
///
///  1. DIRECT      owner sets addresses (founder/ops wallets, partners,
///                 KOLs). Batched.
///  2. COLLECTIONS holders of any registered NFT collection qualify
///                 automatically, checked live via balanceOf. Seeded with
///                 STONK BROKERS; more can be added at any time (their
///                 sister collections, partner projects) with no
///                 redeployment and no snapshot.
///  3. MERKLE      a root covering an arbitrarily large list. Addresses
///                 self-register once with claim(proof), which writes the
///                 cheap direct flag. Multiple roots can be added over
///                 time, e.g. one per partner drop.
///  4. OPEN        after the window closes everyone is "whitelisted",
///                 which is how the hook charges the floor fee to all.
///
/// Registration via claim() rather than proving at swap time is
/// deliberate: swaps arrive through arbitrary routers that cannot carry
/// a proof, so the swap-time check must be a plain storage read.
contract QuotronWhitelist {
    address public owner;

    /// @notice Direct grants, and the destination of every merkle claim.
    mapping(address => bool) public isWhitelisted;
    /// @notice NFT collections whose holders qualify automatically.
    address[] public collections;
    mapping(address => bool) public isCollection;
    /// @notice Merkle roots; any valid proof against any live root works.
    mapping(bytes32 => bool) public roots;
    mapping(bytes32 => mapping(address => bool)) public claimed;

    uint256 public directCount;

    /// @notice Self-serve reduced-fee tier: the first REDUCED_CAP
    /// addresses to claim trade at the reduced fee (not the floor fee)
    /// during the launch window instead of the public rate. One per
    /// address, first come first served, visible on-chain in real time.
    uint256 public constant REDUCED_CAP = 100;
    uint256 public reducedCount;
    mapping(address => bool) public isReduced;

    event WhitelistSet(address indexed who, bool allowed);
    event ReducedSpotClaimed(address indexed who, uint256 count);
    event CollectionSet(address indexed collection, bool allowed);
    event RootSet(bytes32 indexed root, bool live);
    event Claimed(address indexed who, bytes32 indexed root);

    error NotOwner();
    error BadProof();
    error RootNotLive();
    error AlreadyClaimed();
    error SpotsFull();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(address brokers) {
        owner = msg.sender;
        if (brokers != address(0)) {
            collections.push(brokers);
            isCollection[brokers] = true;
            emit CollectionSet(brokers, true);
        }
    }

    function transferOwnership(address n) external onlyOwner {
        owner = n;
    }

    // ── 1. direct grants ────────────────────────────────────────────
    function setWhitelisted(address[] calldata who, bool on) external onlyOwner {
        for (uint256 i; i < who.length; ++i) {
            if (isWhitelisted[who[i]] == on) continue;
            isWhitelisted[who[i]] = on;
            if (on) directCount += 1;
            else directCount -= 1;
            emit WhitelistSet(who[i], on);
        }
    }

    // ── 2. collections ──────────────────────────────────────────────
    function setCollection(address c, bool on) external onlyOwner {
        if (isCollection[c] == on) return;
        isCollection[c] = on;
        if (on) {
            collections.push(c);
        } else {
            uint256 n = collections.length;
            for (uint256 i; i < n; ++i) {
                if (collections[i] == c) {
                    collections[i] = collections[n - 1];
                    collections.pop();
                    break;
                }
            }
        }
        emit CollectionSet(c, on);
    }

    function collectionCount() external view returns (uint256) {
        return collections.length;
    }

    // ── reduced-fee spots (FCFS, self-serve) ────────────────────────
    function claimReducedSpot() external {
        if (isReduced[msg.sender]) revert AlreadyClaimed();
        if (reducedCount >= REDUCED_CAP) revert SpotsFull();
        isReduced[msg.sender] = true;
        unchecked {
            reducedCount += 1;
        }
        emit ReducedSpotClaimed(msg.sender, reducedCount);
    }

    /// @notice True if `who` holds a reduced-fee spot.
    function reduced(address who) external view returns (bool) {
        return isReduced[who];
    }

    // ── 3. merkle roots ─────────────────────────────────────────────
    function setRoot(bytes32 root, bool live) external onlyOwner {
        roots[root] = live;
        emit RootSet(root, live);
    }

    /// @notice Self-register from a merkle list. One call, then every
    /// swap afterwards is a single cheap storage read.
    function claim(bytes32 root, bytes32[] calldata proof) external {
        if (!roots[root]) revert RootNotLive();
        if (claimed[root][msg.sender]) revert AlreadyClaimed();
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        if (!_verify(proof, root, leaf)) revert BadProof();
        claimed[root][msg.sender] = true;
        if (!isWhitelisted[msg.sender]) {
            isWhitelisted[msg.sender] = true;
            directCount += 1;
            emit WhitelistSet(msg.sender, true);
        }
        emit Claimed(msg.sender, root);
    }

    function _verify(bytes32[] calldata proof, bytes32 root, bytes32 leaf)
        internal
        pure
        returns (bool)
    {
        bytes32 h = leaf;
        for (uint256 i; i < proof.length; ++i) {
            bytes32 p = proof[i];
            h = h <= p ? keccak256(abi.encodePacked(h, p)) : keccak256(abi.encodePacked(p, h));
        }
        return h == root;
    }

    // ── the question the hook actually asks ─────────────────────────
    /// @notice True if `who` pays the floor fee during the launch window.
    function allowed(address who) external view returns (bool) {
        if (isWhitelisted[who]) return true;
        uint256 n = collections.length;
        for (uint256 i; i < n; ++i) {
            // A collection that reverts or is not a 721 must never brick
            // swapping for everyone else.
            (bool ok, bytes memory ret) = collections[i].staticcall(
                abi.encodeWithSelector(IERC721Bal.balanceOf.selector, who)
            );
            if (ok && ret.length >= 32 && abi.decode(ret, (uint256)) > 0) return true;
        }
        return false;
    }

    /// @notice Why an address qualifies, for the UI.
    function reason(address who) external view returns (string memory) {
        if (isWhitelisted[who]) return "direct";
        uint256 n = collections.length;
        for (uint256 i; i < n; ++i) {
            (bool ok, bytes memory ret) = collections[i].staticcall(
                abi.encodeWithSelector(IERC721Bal.balanceOf.selector, who)
            );
            if (ok && ret.length >= 32 && abi.decode(ret, (uint256)) > 0) return "collection";
        }
        return "";
    }
}
