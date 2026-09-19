// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./StonkTwapOracle.sol";
import "./StonkOptionPositionNFT.sol";
import "./IUniswapV3PoolMinimal.sol";

/// @notice Covered-call market for an (underlying, quote, pool) tuple.
/// Writers escrow underlying; buyers pay premium to writer and receive a tradable option NFT.
contract StonkCoveredCallVault is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    uint32 public constant MIN_TWAP_SECONDS = 15 minutes;

    struct Offer {
        uint256 id;
        address writer;
        address underlying;
        address quote;
        address pool;
        uint32 twapSeconds;
        int24 strikeTick;
        uint256 underlyingAmount;
        uint256 strikeQuoteAmount;
        uint256 premiumQuoteAmount;
        uint256 expiry;
        bool active;
    }

    uint256 public nextOfferId = 1;
    mapping(uint256 => Offer) public offers;
    mapping(uint256 => bool) public underlyingReclaimed; // optionTokenId => reclaimed

    StonkTwapOracle public immutable oracle;
    StonkOptionPositionNFT public immutable optionNft;

    event OfferCreated(uint256 indexed offerId, address indexed writer, address indexed underlying, uint256 underlyingAmount);
    event OfferCancelled(uint256 indexed offerId);
    event OfferFilled(uint256 indexed offerId, uint256 indexed optionTokenId, address indexed buyer);
    event Exercised(uint256 indexed optionTokenId, address indexed buyer);
    event ExpiredReclaimed(uint256 indexed optionTokenId, address indexed writer);

    constructor(address _oracle, address _optionNft, address initialOwner) Ownable(initialOwner) {
        require(_oracle != address(0), "oracle=0");
        require(_optionNft != address(0), "nft=0");
        oracle = StonkTwapOracle(_oracle);
        optionNft = StonkOptionPositionNFT(_optionNft);
    }

    function createOffer(
        address underlying,
        address quote,
        address pool,
        uint32 twapSeconds,
        int24 strikeTick,
        uint256 underlyingAmount,
        uint256 strikeQuoteAmount,
        uint256 premiumQuoteAmount,
        uint256 expiry
    ) external nonReentrant returns (uint256 offerId) {
        require(underlying != address(0), "underlying=0");
        require(quote != address(0), "quote=0");
        require(expiry > block.timestamp + 5 minutes, "expiry soon");
        require(underlyingAmount > 0, "amount=0");
        require(strikeQuoteAmount > 0, "strike=0");
        require(premiumQuoteAmount > 0, "premium=0");
        require(pool != address(0), "pool=0");
        require(twapSeconds >= MIN_TWAP_SECONDS, "twap too small");

        // Basic sanity: pool must include underlying+quote.
        address t0 = IUniswapV3PoolMinimal(pool).token0();
        address t1 = IUniswapV3PoolMinimal(pool).token1();
        require((t0 == underlying && t1 == quote) || (t0 == quote && t1 == underlying), "pool mismatch");

        IERC20(underlying).safeTransferFrom(msg.sender, address(this), underlyingAmount);

        offerId = nextOfferId++;
        offers[offerId] = Offer({
            id: offerId,
            writer: msg.sender,
            underlying: underlying,
            quote: quote,
            pool: pool,
            twapSeconds: twapSeconds,
            strikeTick: strikeTick,
            underlyingAmount: underlyingAmount,
            strikeQuoteAmount: strikeQuoteAmount,
            premiumQuoteAmount: premiumQuoteAmount,
            expiry: expiry,
            active: true
        });
        emit OfferCreated(offerId, msg.sender, underlying, underlyingAmount);
    }

    function cancelOffer(uint256 offerId) external nonReentrant {
        Offer storage o = offers[offerId];
        require(o.active, "inactive");
        require(o.writer == msg.sender, "not writer");
        o.active = false;
        IERC20(o.underlying).safeTransfer(o.writer, o.underlyingAmount);
        emit OfferCancelled(offerId);
    }

    function buyOption(uint256 offerId) external nonReentrant returns (uint256 optionTokenId) {
        Offer storage o = offers[offerId];
        require(o.active, "inactive");
        require(block.timestamp < o.expiry, "expired");
        o.active = false;

        // Premium goes straight to the writer.
        IERC20(o.quote).safeTransferFrom(msg.sender, o.writer, o.premiumQuoteAmount);

        StonkOptionPositionNFT.Position memory p = StonkOptionPositionNFT.Position({
            vault: address(this),
            writer: o.writer,
            underlying: o.underlying,
            quote: o.quote,
            pool: o.pool,
            twapSeconds: o.twapSeconds,
            strikeTick: o.strikeTick,
            underlyingAmount: o.underlyingAmount,
            strikeQuoteAmount: o.strikeQuoteAmount,
            premiumQuoteAmount: o.premiumQuoteAmount,
            expiry: o.expiry,
            exercised: false
        });

        optionTokenId = optionNft.mint(msg.sender, p);
        emit OfferFilled(offerId, optionTokenId, msg.sender);
    }

    function exercise(uint256 optionTokenId) external nonReentrant {
        require(optionNft.ownerOf(optionTokenId) == msg.sender, "not owner");
        (
            address vault,
            address writer,
            address underlying,
            address quote,
            address pool,
            uint32 twapSeconds,
            int24 strikeTick,
            uint256 underlyingAmount,
            uint256 strikeQuoteAmount,
            ,
            uint256 expiry,
            bool exercised
        ) = optionNft.positions(optionTokenId);
        require(vault == address(this), "wrong vault");
        require(!underlyingReclaimed[optionTokenId], "settled");
        require(!exercised, "exercised");
        require(block.timestamp < expiry, "expired");

        int24 twapTick = oracle.getTwapTick(pool, twapSeconds);

        // Canonical strike space:
        // - Uniswap pool tick is always price(token1/token0) in raw units.
        // - We define strikeTick to ALWAYS be in this same canonical space (token1/token0 for the pool).
        //
        // ITM condition for a call option (pay quote, receive underlying):
        // - If underlying == token0 (and quote == token1), pool tick is quote/underlying.
        //   ITM when quote/underlying >= strike => twapTick >= strikeTick.
        // - If underlying == token1 (and quote == token0), pool tick is underlying/quote.
        //   ITM when quote/underlying >= strike <=> underlying/quote <= 1/strike,
        //   and since strikeTick is in underlying/quote space, ITM when twapTick <= strikeTick.
        address t0 = IUniswapV3PoolMinimal(pool).token0();
        address t1 = IUniswapV3PoolMinimal(pool).token1();
        require((t0 == underlying && t1 == quote) || (t0 == quote && t1 == underlying), "pool mismatch");
        if (underlying == t0) {
            require(twapTick >= strikeTick, "not ITM");
        } else {
            require(twapTick <= strikeTick, "not ITM");
        }

        // Pay strike to writer, receive underlying.
        IERC20(quote).safeTransferFrom(msg.sender, writer, strikeQuoteAmount);
        IERC20(underlying).safeTransfer(msg.sender, underlyingAmount);

        optionNft.markExercised(optionTokenId);
        emit Exercised(optionTokenId, msg.sender);
    }

    /// @notice If the option expires unexercised, the original writer can reclaim the escrowed underlying.
    function reclaimExpired(uint256 optionTokenId) external nonReentrant {
        (
            address vault,
            address writer,
            address underlying,
            ,
            ,
            ,
            ,
            uint256 underlyingAmount,
            ,
            ,
            uint256 expiry,
            bool exercised
        ) = optionNft.positions(optionTokenId);
        require(vault == address(this), "wrong vault");
        require(msg.sender == writer, "not writer");
        require(!exercised, "exercised");
        require(block.timestamp >= expiry, "not expired");
        require(!underlyingReclaimed[optionTokenId], "already reclaimed");
        underlyingReclaimed[optionTokenId] = true;

        IERC20(underlying).safeTransfer(writer, underlyingAmount);
        emit ExpiredReclaimed(optionTokenId, writer);
    }
}

