// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract StonkBrokersMarketplace is Ownable, ReentrancyGuard, IERC721Receiver {
    enum ListingKind {
        None,
        Eth,
        ERC20
    }

    struct Listing {
        uint256 id;
        address seller;
        address nft;
        uint256 tokenId;
        ListingKind kind;
        address paymentToken;
        uint256 price;
        bool active;
    }

    struct SwapOffer {
        uint256 id;
        address maker;
        address offeredNft;
        uint256 offeredTokenId;
        address requestedNft;
        uint256 requestedTokenId;
        bool active;
    }

    address public immutable originalCollection;
    address public immutable legacyExpandedCollection;
    address public immutable expandedCollection;
    uint256 public nextListingId = 1;
    uint256 public nextSwapId = 1;

    mapping(uint256 => Listing) public listings;
    mapping(uint256 => SwapOffer) public swaps;

    event ListingCreated(
        uint256 indexed listingId,
        address indexed seller,
        address indexed nft,
        uint256 tokenId,
        ListingKind kind,
        address paymentToken,
        uint256 price
    );
    event ListingCancelled(uint256 indexed listingId);
    event ListingFilled(uint256 indexed listingId, address indexed buyer);
    event SwapCreated(
        uint256 indexed swapId,
        address indexed maker,
        address indexed offeredNft,
        uint256 offeredTokenId,
        address requestedNft,
        uint256 requestedTokenId
    );
    event SwapCancelled(uint256 indexed swapId);
    event SwapFilled(uint256 indexed swapId, address indexed taker);

    constructor(
        address _originalCollection,
        address _legacyExpandedCollection,
        address _expandedCollection,
        address initialOwner
    ) Ownable(initialOwner) {
        require(_originalCollection != address(0), "original=0");
        require(_expandedCollection != address(0), "expanded=0");
        originalCollection = _originalCollection;
        legacyExpandedCollection = _legacyExpandedCollection;
        expandedCollection = _expandedCollection;
    }

    modifier onlySupportedCollection(address nft) {
        require(
            nft == originalCollection || nft == expandedCollection || (legacyExpandedCollection != address(0) && nft == legacyExpandedCollection),
            "unsupported nft"
        );
        _;
    }

    function createEthListing(address nft, uint256 tokenId, uint256 price)
        external
        nonReentrant
        onlySupportedCollection(nft)
        returns (uint256 listingId)
    {
        require(price > 0, "price=0");
        IERC721(nft).safeTransferFrom(msg.sender, address(this), tokenId);

        listingId = nextListingId++;
        listings[listingId] = Listing({
            id: listingId,
            seller: msg.sender,
            nft: nft,
            tokenId: tokenId,
            kind: ListingKind.Eth,
            paymentToken: address(0),
            price: price,
            active: true
        });
        emit ListingCreated(listingId, msg.sender, nft, tokenId, ListingKind.Eth, address(0), price);
    }

    function createTokenListing(address nft, uint256 tokenId, address paymentToken, uint256 price)
        external
        nonReentrant
        onlySupportedCollection(nft)
        returns (uint256 listingId)
    {
        require(paymentToken != address(0), "token=0");
        require(price > 0, "price=0");
        IERC721(nft).safeTransferFrom(msg.sender, address(this), tokenId);

        listingId = nextListingId++;
        listings[listingId] = Listing({
            id: listingId,
            seller: msg.sender,
            nft: nft,
            tokenId: tokenId,
            kind: ListingKind.ERC20,
            paymentToken: paymentToken,
            price: price,
            active: true
        });
        emit ListingCreated(listingId, msg.sender, nft, tokenId, ListingKind.ERC20, paymentToken, price);
    }

    function cancelListing(uint256 listingId) external nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.active, "inactive");
        require(listing.seller == msg.sender, "not seller");

        listing.active = false;
        IERC721(listing.nft).safeTransferFrom(address(this), msg.sender, listing.tokenId);
        emit ListingCancelled(listingId);
    }

    function buyWithEth(uint256 listingId) external payable nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.active, "inactive");
        require(listing.kind == ListingKind.Eth, "not eth listing");
        require(msg.value == listing.price, "wrong value");

        listing.active = false;
        (bool ok, ) = payable(listing.seller).call{value: msg.value}("");
        require(ok, "eth transfer failed");
        IERC721(listing.nft).safeTransferFrom(address(this), msg.sender, listing.tokenId);
        emit ListingFilled(listingId, msg.sender);
    }

    function buyWithToken(uint256 listingId) external nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.active, "inactive");
        require(listing.kind == ListingKind.ERC20, "not token listing");

        listing.active = false;
        require(IERC20(listing.paymentToken).transferFrom(msg.sender, listing.seller, listing.price), "erc20 transfer failed");
        IERC721(listing.nft).safeTransferFrom(address(this), msg.sender, listing.tokenId);
        emit ListingFilled(listingId, msg.sender);
    }

    function createSwapOffer(address offeredNft, uint256 offeredTokenId, address requestedNft, uint256 requestedTokenId)
        external
        nonReentrant
        onlySupportedCollection(offeredNft)
        onlySupportedCollection(requestedNft)
        returns (uint256 swapId)
    {
        IERC721(offeredNft).safeTransferFrom(msg.sender, address(this), offeredTokenId);

        swapId = nextSwapId++;
        swaps[swapId] = SwapOffer({
            id: swapId,
            maker: msg.sender,
            offeredNft: offeredNft,
            offeredTokenId: offeredTokenId,
            requestedNft: requestedNft,
            requestedTokenId: requestedTokenId,
            active: true
        });
        emit SwapCreated(swapId, msg.sender, offeredNft, offeredTokenId, requestedNft, requestedTokenId);
    }

    function cancelSwapOffer(uint256 swapId) external nonReentrant {
        SwapOffer storage offer = swaps[swapId];
        require(offer.active, "inactive");
        require(offer.maker == msg.sender, "not maker");

        offer.active = false;
        IERC721(offer.offeredNft).safeTransferFrom(address(this), msg.sender, offer.offeredTokenId);
        emit SwapCancelled(swapId);
    }

    function acceptSwapOffer(uint256 swapId) external nonReentrant {
        SwapOffer storage offer = swaps[swapId];
        require(offer.active, "inactive");

        offer.active = false;
        IERC721(offer.requestedNft).safeTransferFrom(msg.sender, offer.maker, offer.requestedTokenId);
        IERC721(offer.offeredNft).safeTransferFrom(address(this), msg.sender, offer.offeredTokenId);
        emit SwapFilled(swapId, msg.sender);
    }

    function withdrawStuckEth(address payable to) external onlyOwner {
        require(to != address(0), "to=0");
        (bool ok, ) = to.call{value: address(this).balance}("");
        require(ok, "withdraw failed");
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
