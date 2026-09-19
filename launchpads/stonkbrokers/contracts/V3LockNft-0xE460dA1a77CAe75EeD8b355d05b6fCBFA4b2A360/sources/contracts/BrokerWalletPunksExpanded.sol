// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC6551Registry.sol";

contract BrokerWalletPunksExpanded is ERC721Enumerable, Ownable, ReentrancyGuard {
    using Strings for uint256;

    uint256 public immutable START_TOKEN_ID;
    uint256 public immutable END_TOKEN_ID;
    uint256 public immutable MAX_SUPPLY;
    uint256 public constant MINT_PRICE = 0.01 ether;
    uint256 public constant MAX_PER_TX = 10;

    ERC6551Registry public immutable registry;
    address public immutable accountImplementation;
    bytes32 public constant ACCOUNT_SALT = bytes32(0);
    uint256 private nextTokenId;
    address[] private stockTokens;

    mapping(uint256 => address) public tokenWallet;
    mapping(uint256 => address) public fundedToken;
    mapping(uint256 => uint256) public initialWalletGrant;
    mapping(address => uint256) public fundedTokenMintCount;
    mapping(bytes32 => bool) private usedTraitSignatures;
    mapping(uint256 => uint256) private tokenTraitSeed;
    uint256 private constant MAX_TRAIT_SEED_ATTEMPTS = 256;

    event WalletCreated(uint256 indexed tokenId, address indexed wallet);
    event WalletFunded(uint256 indexed tokenId, address indexed stockToken, uint256 amount);

    constructor(
        address[] memory stockTokenAddresses,
        uint256 startTokenId,
        uint256 endTokenId,
        address registryAddress,
        address accountImplementationAddress,
        address initialOwner
    ) ERC721("Stonk Brokers (Expanded)", "STONKX") Ownable(initialOwner) {
        require(stockTokenAddresses.length > 0, "no stock tokens");
        require(startTokenId >= 445, "start < 445");
        require(endTokenId >= startTokenId, "end < start");
        require(registryAddress != address(0), "registry=0");
        require(accountImplementationAddress != address(0), "account impl=0");
        START_TOKEN_ID = startTokenId;
        END_TOKEN_ID = endTokenId;
        MAX_SUPPLY = (endTokenId - startTokenId) + 1;
        nextTokenId = startTokenId;
        registry = ERC6551Registry(registryAddress);
        accountImplementation = accountImplementationAddress;
        for (uint256 i = 0; i < stockTokenAddresses.length; i++) {
            require(stockTokenAddresses[i] != address(0), "stock token=0");
            stockTokens.push(stockTokenAddresses[i]);
        }
    }

    function mint(uint256 quantity) external payable nonReentrant {
        require(quantity > 0, "qty=0");
        require(quantity <= MAX_PER_TX, "qty too high");
        require(totalSupply() + quantity <= MAX_SUPPLY, "sold out");
        require(msg.value == MINT_PRICE * quantity, "wrong value");

        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = nextTokenId;
            require(tokenId <= END_TOKEN_ID, "sold out");
            nextTokenId += 1;

            _assignUniqueTraitSeed(tokenId);

            _safeMint(msg.sender, tokenId);

            address wallet = registry.createAccount(
                accountImplementation,
                ACCOUNT_SALT,
                block.chainid,
                address(this),
                tokenId
            );
            tokenWallet[tokenId] = wallet;
            emit WalletCreated(tokenId, wallet);

            (address tokenAddress, uint256 tokenBalance) = _pickFundableStockToken(tokenId);
            uint256 grant = _stockGrantForToken(tokenId, tokenAddress, tokenBalance);
            require(grant > 0, "grant=0");

            fundedToken[tokenId] = tokenAddress;
            initialWalletGrant[tokenId] = grant;
            require(IERC20(tokenAddress).transfer(wallet, grant), "token transfer failed");
            fundedTokenMintCount[tokenAddress] += 1;

            emit WalletFunded(tokenId, tokenAddress, grant);
        }
    }

    function withdrawMintProceeds(address payable to) external onlyOwner {
        require(to != address(0), "to=0");
        (bool ok, ) = to.call{value: address(this).balance}("");
        require(ok, "withdraw failed");
    }

    function predictWallet(uint256 tokenId) external view returns (address) {
        return registry.account(accountImplementation, ACCOUNT_SALT, block.chainid, address(this), tokenId);
    }

    function stockTokenCount() external view returns (uint256) {
        return stockTokens.length;
    }

    function stockTokenAt(uint256 index) external view returns (address) {
        require(index < stockTokens.length, "index out of bounds");
        return stockTokens[index];
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        string memory image = _renderSvg(tokenId);
        address wallet = tokenWallet[tokenId];
        address tokenAddress = fundedToken[tokenId];
        uint256 currentStock = IERC20(tokenAddress).balanceOf(wallet) / 1e18;
        uint256 initialStock = initialWalletGrant[tokenId] / 1e18;

        string memory json = string(
            abi.encodePacked(
                '{"name":"Stonk Broker #',
                tokenId.toString(),
                '","description":"Expanded Stonk Brokers continuation collection on Robinhood Chain. Each NFT is 100% onchain and includes a token-bound wallet funded at mint.","attributes":[',
                '{"trait_type":"Collection","value":"Expanded"},',
                '{"trait_type":"Global ID Start","value":"',
                START_TOKEN_ID.toString(),
                '"},',
                '{"trait_type":"Wallet Address","value":"',
                Strings.toHexString(uint256(uint160(wallet)), 20),
                '"},{"trait_type":"Stock Token","value":"',
                Strings.toHexString(uint256(uint160(tokenAddress)), 20),
                '"},{"trait_type":"Initial Wallet Stock","value":"',
                initialStock.toString(),
                ' units"},{"trait_type":"Current Wallet Stock","value":"',
                currentStock.toString(),
                ' units"}',
                '],"image":"data:image/svg+xml;base64,',
                Base64.encode(bytes(image)),
                '"}'
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }

    function _stockGrantForToken(uint256 tokenId, address tokenAddress, uint256 tokenBalance) internal view returns (uint256) {
        uint256 remainingMints = (END_TOKEN_ID - tokenId) + 1;
        uint256 expectedMintsForToken = (remainingMints / stockTokens.length) + 1;
        uint256 perMintBudget = tokenBalance / expectedMintsForToken;
        if (perMintBudget == 0) {
            return tokenBalance > 0 ? 1 : 0;
        }

        uint256 seed = uint256(keccak256(abi.encodePacked("STONK_BROKERS_EXPANDED", tokenId, tokenAddress)));
        uint256 grantBps = 6500 + (seed % 3501);
        uint256 grant = (perMintBudget * grantBps) / 10_000;
        if (grant == 0) return 1;
        if (grant > tokenBalance) return tokenBalance;
        return grant;
    }

    function _pickFundableStockToken(uint256 tokenId) internal view returns (address tokenAddress, uint256 tokenBalance) {
        uint256 minAssigned = type(uint256).max;
        uint256 eligibleCount = 0;

        for (uint256 i = 0; i < stockTokens.length; i++) {
            address candidate = stockTokens[i];
            uint256 balance = IERC20(candidate).balanceOf(address(this));
            if (balance == 0) continue;
            if (_stockGrantForToken(tokenId, candidate, balance) == 0) continue;

            uint256 assigned = fundedTokenMintCount[candidate];
            if (assigned < minAssigned) {
                minAssigned = assigned;
                eligibleCount = 1;
            } else if (assigned == minAssigned) {
                eligibleCount += 1;
            }
        }

        if (eligibleCount == 0) {
            revert("insufficient token inventory");
        }

        uint256 pick = uint256(keccak256(abi.encodePacked("STONK_STOCK_PICK_EXPANDED", tokenId, totalSupply()))) % eligibleCount;
        uint256 cursor = 0;
        for (uint256 i = 0; i < stockTokens.length; i++) {
            address candidate = stockTokens[i];
            uint256 balance = IERC20(candidate).balanceOf(address(this));
            if (balance > 0 && _stockGrantForToken(tokenId, candidate, balance) > 0 && fundedTokenMintCount[candidate] == minAssigned) {
                if (cursor == pick) return (candidate, balance);
                cursor += 1;
            }
        }

        revert("insufficient token inventory");
    }

    function _assignUniqueTraitSeed(uint256 tokenId) internal {
        for (uint256 attempt = 0; attempt < MAX_TRAIT_SEED_ATTEMPTS; attempt++) {
            uint256 seed = _candidateTraitSeed(tokenId, attempt);
            bytes32 sig = _traitSignatureFromSeed(seed);
            if (!usedTraitSignatures[sig]) {
                usedTraitSignatures[sig] = true;
                tokenTraitSeed[tokenId] = seed;
                return;
            }
        }
        revert("trait space exhausted");
    }

    function _candidateTraitSeed(uint256 tokenId, uint256 attempt) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked("STONK_TRAIT_SIG_EXPANDED", tokenId, attempt)));
    }

    function _traitSignatureFromSeed(uint256 seed) internal pure returns (bytes32) {
        uint8 skinType = uint8(seed % 5); // normal/devil/zombie/robot/marshmallow
        uint8 hairType = uint8((seed / 11) % 4); // bald/classic/afro/side-part
        uint8 accessory = uint8((seed / 31) % 5); // none/sunglasses/3d/halo/headset
        uint8 tieColor = uint8((seed / 71) % 6);
        uint8 suitColor = uint8((seed / 97) % 6);
        uint8 eyeColor = uint8((seed / 131) % 8);
        uint8 mouthStyle = uint8((seed / 191) % 4); // flat/smile/frown/open
        return keccak256(abi.encodePacked(skinType, hairType, accessory, tieColor, suitColor, eyeColor, mouthStyle));
    }

    function _renderSvg(uint256 tokenId) internal view returns (string memory) {
        uint256 seed = tokenTraitSeed[tokenId];
        if (seed == 0) {
            // Fallback keeps deterministic previews for edge cases.
            seed = uint256(keccak256(abi.encodePacked("STONK_ART_EXPANDED", tokenId)));
        }
        string memory bg = _hex(_pickBackground(seed));
        string memory suit = _hex(_pickSuit(seed));
        string memory tie = _hex(_pickTie(seed));
        string memory skin = _hex(_pickSkin(seed));
        string memory eye = _hex(_pickEye(seed));
        string memory hair = _hex(_pickHair(seed));

        return string(abi.encodePacked(_svgHead(bg), _svgFace(seed, skin, eye, hair), _svgBody(suit, tie), "</svg>"));
    }

    function _svgHead(string memory bg) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<svg xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges" viewBox="0 0 24 24" width="720" height="720"><rect width="24" height="24" fill="#',
                    bg,
                    '"/>'
                )
            );
    }

    function _svgFace(uint256 seed, string memory skin, string memory eye, string memory hair) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<rect x="7" y="4" width="10" height="12" fill="#',
                    skin,
                    '"/><rect x="9" y="16" width="6" height="3" fill="#',
                    skin,
                    '"/><rect x="8" y="8" width="3" height="2" fill="#f4f4f4"/><rect x="13" y="8" width="3" height="2" fill="#f4f4f4"/><rect x="9" y="8" width="1" height="1" fill="#',
                    eye,
                    '"/><rect x="14" y="8" width="1" height="1" fill="#',
                    eye,
                    '"/>',
                    _renderMouth(seed),
                    _renderHair(seed, hair),
                    _renderAccessory(seed)
                )
            );
    }

    function _svgBody(string memory suit, string memory tie) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<rect x="4" y="18" width="16" height="6" fill="#',
                    suit,
                    '"/><rect x="10" y="18" width="4" height="2" fill="#f0f0f0"/><rect x="11" y="19" width="2" height="5" fill="#',
                    tie,
                    '"/><rect x="11" y="23" width="2" height="1" fill="#',
                    tie,
                    '"/><rect x="10" y="23" width="1" height="1" fill="#151515"/><rect x="13" y="23" width="1" height="1" fill="#151515"/>'
                )
            );
    }

    function _renderHair(uint256 seed, string memory hair) internal pure returns (string memory) {
        uint256 style = (seed / 11) % 4;
        if (style == 0) return ""; // bald
        if (style == 1) {
            return string(abi.encodePacked('<rect x="7" y="3" width="10" height="2" fill="#', hair, '"/><rect x="6" y="4" width="1" height="9" fill="#', hair, '"/><rect x="17" y="4" width="1" height="9" fill="#', hair, '"/>'));
        }
        if (style == 2) {
            return string(abi.encodePacked('<rect x="6" y="2" width="12" height="4" fill="#', hair, '"/><rect x="5" y="4" width="1" height="4" fill="#', hair, '"/><rect x="18" y="4" width="1" height="4" fill="#', hair, '"/>'));
        }
        return string(abi.encodePacked('<rect x="7" y="3" width="10" height="2" fill="#', hair, '"/><rect x="6" y="4" width="2" height="8" fill="#', hair, '"/>'));
    }

    function _renderAccessory(uint256 seed) internal pure returns (string memory) {
        uint256 acc = (seed / 31) % 5;
        if (acc == 0) return "";
        if (acc == 1) {
            return '<rect x="8" y="7" width="3" height="2" fill="#101216"/><rect x="13" y="7" width="3" height="2" fill="#101216"/><rect x="11" y="7" width="2" height="1" fill="#3a3f47"/>';
        }
        if (acc == 2) {
            return '<rect x="8" y="7" width="3" height="2" fill="#de2b2b"/><rect x="13" y="7" width="3" height="2" fill="#2b6bff"/><rect x="11" y="7" width="2" height="1" fill="#d3d7de"/>';
        }
        if (acc == 3) {
            return '<rect x="9" y="2" width="6" height="1" fill="#f2e189"/><rect x="8" y="3" width="8" height="1" fill="#f2e189"/>';
        }
        return
            '<rect x="6" y="7" width="1" height="4" fill="#2a2f3a"/><rect x="17" y="7" width="1" height="4" fill="#2a2f3a"/><rect x="7" y="6" width="10" height="1" fill="#2a2f3a"/><rect x="10" y="6" width="4" height="1" fill="#3f495c"/>';
    }

    function _renderMouth(uint256 seed) internal pure returns (string memory) {
        uint256 mouth = (seed / 191) % 4;
        if (mouth == 0) {
            return '<rect x="10" y="13" width="4" height="1" fill="#101010"/>';
        }
        if (mouth == 1) {
            return '<rect x="10" y="13" width="1" height="1" fill="#101010"/><rect x="11" y="14" width="2" height="1" fill="#101010"/><rect x="13" y="13" width="1" height="1" fill="#101010"/>';
        }
        if (mouth == 2) {
            return '<rect x="10" y="14" width="1" height="1" fill="#101010"/><rect x="11" y="13" width="2" height="1" fill="#101010"/><rect x="13" y="14" width="1" height="1" fill="#101010"/>';
        }
        return '<rect x="10" y="13" width="4" height="2" fill="#101010"/><rect x="11" y="14" width="2" height="1" fill="#5a1111"/>';
    }

    function _pickBackground(uint256 seed) internal pure returns (bytes3) {
        uint256 idx = seed % 6;
        if (idx == 0) return 0x6ca0dc;
        if (idx == 1) return 0x8dbfe8;
        if (idx == 2) return 0xb8d2e8;
        if (idx == 3) return 0xd0b090;
        if (idx == 4) return 0x9bb0c8;
        return 0x7f92a8;
    }

    function _pickSuit(uint256 seed) internal pure returns (bytes3) {
        uint256 idx = (seed / 97) % 6;
        if (idx == 0) return 0x1f2328;
        if (idx == 1) return 0x213547;
        if (idx == 2) return 0x2f3e46;
        if (idx == 3) return 0x3c4454;
        if (idx == 4) return 0x4a235a;
        return 0x263238;
    }

    function _pickTie(uint256 seed) internal pure returns (bytes3) {
        uint256 idx = (seed / 71) % 6;
        if (idx == 0) return 0x4f8cff;
        if (idx == 1) return 0x24a148;
        if (idx == 2) return 0xe53935;
        if (idx == 3) return 0xf4b400;
        if (idx == 4) return 0x6f42c1;
        return 0x00a3a3;
    }

    function _pickSkin(uint256 seed) internal pure returns (bytes3) {
        uint256 idx = seed % 5;
        if (idx == 0) return 0xf1c27d; // normal
        if (idx == 1) return 0xd63f36; // devil
        if (idx == 2) return 0x63b35f; // zombie
        if (idx == 3) return 0xa7b0ba; // robot
        return 0xfaf8f4; // marshmallow
    }

    function _pickEye(uint256 seed) internal pure returns (bytes3) {
        uint256 idx = (seed / 131) % 8;
        if (idx == 0) return 0x2b3fd1;
        if (idx == 1) return 0x4b8f29;
        if (idx == 2) return 0x7d5534;
        if (idx == 3) return 0x5b6678;
        if (idx == 4) return 0x1f7a8c;
        if (idx == 5) return 0x8a4fff;
        if (idx == 6) return 0xb5651d;
        return 0x1d3557;
    }

    function _pickHair(uint256 seed) internal pure returns (bytes3) {
        uint256 idx = (seed / 151) % 6;
        if (idx == 0) return 0x111111;
        if (idx == 1) return 0x3e2723;
        if (idx == 2) return 0x5d4037;
        if (idx == 3) return 0x6d4c41;
        if (idx == 4) return 0x212121;
        return 0x7b5e57;
    }

    function _hex(bytes3 data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(6);
        for (uint256 i = 0; i < 3; i++) {
            str[i * 2] = alphabet[uint8(data[i] >> 4)];
            str[i * 2 + 1] = alphabet[uint8(data[i] & 0x0f)];
        }
        return string(str);
    }
}
