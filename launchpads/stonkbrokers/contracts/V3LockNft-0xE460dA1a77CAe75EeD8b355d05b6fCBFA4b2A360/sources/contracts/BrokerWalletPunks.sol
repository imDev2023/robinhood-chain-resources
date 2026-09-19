// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC6551Registry.sol";

contract BrokerWalletPunks is ERC721Enumerable, Ownable, ReentrancyGuard {
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 444;
    uint256 public constant MINT_PRICE = 0.01 ether;
    uint256 public constant MAX_PER_TX = 10;

    ERC6551Registry public immutable registry;
    address public immutable accountImplementation;
    bytes32 public constant ACCOUNT_SALT = bytes32(0);
    uint256 private nextTokenId = 1;
    address[] private stockTokens;

    // tokenId => wallet contract address.
    mapping(uint256 => address) public tokenWallet;
    // tokenId => stock token used for this wallet's initial funding.
    mapping(uint256 => address) public fundedToken;
    // tokenId => grant transferred to wallet at mint time.
    mapping(uint256 => uint256) public initialWalletGrant;
    // Tracks how often each stock token has been assigned during mint.
    mapping(address => uint256) public fundedTokenMintCount;

    event WalletCreated(uint256 indexed tokenId, address indexed wallet);
    event WalletFunded(uint256 indexed tokenId, address indexed stockToken, uint256 amount);

    constructor(
        address[] memory stockTokenAddresses,
        address registryAddress,
        address accountImplementationAddress,
        address initialOwner
    ) ERC721("Stonk Brokers", "STONK") Ownable(initialOwner) {
        require(stockTokenAddresses.length > 0, "no stock tokens");
        require(registryAddress != address(0), "registry=0");
        require(accountImplementationAddress != address(0), "account impl=0");
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
            nextTokenId += 1;

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

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        string memory image = _renderSvg(tokenId);
        address wallet = tokenWallet[tokenId];
        address tokenAddress = fundedToken[tokenId];
        uint256 currentStock = IERC20(tokenAddress).balanceOf(wallet) / 1e18;
        uint256 initialStock = initialWalletGrant[tokenId] / 1e18;
        string memory attrs = _metadataAttributes(tokenId, wallet, tokenAddress, initialStock, currentStock);

        string memory json = string(
            abi.encodePacked(
                '{"name":"Stonk Broker #',
                tokenId.toString(),
                '","description":"A 444-supply pixel stock-broker NFT with a dedicated onchain wallet funded at mint.","attributes":[',
                attrs,
                '],"image":"data:image/svg+xml;base64,',
                Base64.encode(bytes(image)),
                '"}'
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }

    function _metadataAttributes(
        uint256 tokenId,
        address wallet,
        address tokenAddress,
        uint256 initialStock,
        uint256 currentStock
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"trait_type":"Wallet Address","value":"',
                    _toHexString(wallet),
                    '"},{"trait_type":"Stock Token","value":"',
                    _toHexString(tokenAddress),
                    '"},{"trait_type":"Initial Wallet Stock","value":"',
                    initialStock.toString(),
                    ' units"},{"trait_type":"Current Wallet Stock","value":"',
                    currentStock.toString(),
                    ' units"},{"trait_type":"Collection Size","value":"444"}',
                    _specialMetadataAttribute(tokenId)
                )
            );
    }

    function _specialMetadataAttribute(uint256 tokenId) internal pure returns (string memory) {
        uint8 specialIdx = _oneOfOneIndex(tokenId);
        if (specialIdx == 0) return "";
        return
            string(
                abi.encodePacked(
                    ',{"trait_type":"One of One","value":"Yes"},{"trait_type":"Special Edition","value":"',
                    _oneOfOneName(specialIdx),
                    '"}'
                )
            );
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

    function _stockGrantForToken(uint256 tokenId, address tokenAddress, uint256 tokenBalance) internal view returns (uint256) {
        // Fractional deterministic grant sized to preserve inventory through the collection.
        // We estimate how many mints are still ahead for this token and allocate only a
        // percentage of that per-mint budget.
        uint256 remainingMints = (MAX_SUPPLY - tokenId) + 1;
        uint256 expectedMintsForToken = (remainingMints / stockTokens.length) + 1;
        uint256 perMintBudget = tokenBalance / expectedMintsForToken;
        if (perMintBudget == 0) {
            // If any dust remains, still allow a minimal transfer to avoid stalling mint.
            return tokenBalance > 0 ? 1 : 0;
        }

        uint256 seed = uint256(keccak256(abi.encodePacked("STONK_BROKERS", tokenId, tokenAddress)));
        // 65% - 100% of the budget keeps variation while avoiding aggressive depletion.
        uint256 grantBps = 6500 + (seed % 3501);
        uint256 grant = (perMintBudget * grantBps) / 10_000;
        if (grant == 0) {
            return 1;
        }
        if (grant > tokenBalance) {
            return tokenBalance;
        }
        return grant;
    }

    function _pickStockToken(uint256 tokenId) internal view returns (address) {
        uint256 idx = uint256(keccak256(abi.encodePacked("STONK_STOCK_PICK", tokenId))) % stockTokens.length;
        return stockTokens[idx];
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

        // Random among the least-assigned tokens so distribution stays even.
        uint256 pick = uint256(keccak256(abi.encodePacked("STONK_STOCK_PICK", tokenId, totalSupply()))) % eligibleCount;
        uint256 cursor = 0;
        for (uint256 i = 0; i < stockTokens.length; i++) {
            address candidate = stockTokens[i];
            uint256 balance = IERC20(candidate).balanceOf(address(this));
            if (balance > 0 && _stockGrantForToken(tokenId, candidate, balance) > 0 && fundedTokenMintCount[candidate] == minAssigned) {
                if (cursor == pick) {
                    return (candidate, balance);
                }
                cursor += 1;
            }
        }

        // Safety fallback; should be unreachable with eligibleCount > 0.
        for (uint256 i = 0; i < stockTokens.length; i++) {
            address candidate = stockTokens[i];
            uint256 balance = IERC20(candidate).balanceOf(address(this));
            if (balance > 0 && _stockGrantForToken(tokenId, candidate, balance) > 0) {
                return (candidate, balance);
            }
        }
        revert("insufficient token inventory");
    }

    function _renderSvg(uint256 tokenId) internal pure returns (string memory) {
        uint8 specialIdx = _oneOfOneIndex(tokenId);
        string memory tie = specialIdx == 0 ? _hex(_pickColor(tokenId, 0)) : _hex(_oneOfOneTieColor(specialIdx));
        string memory suit = specialIdx == 0 ? _hex(_pickColor(tokenId, 1)) : _hex(_oneOfOneSuitColor(specialIdx));
        string memory skin = specialIdx == 0 ? _hex(_pickColor(tokenId, 2)) : _hex(_oneOfOneSkinColor(specialIdx));
        string memory hair = _hex(_pickColor(tokenId, 3));
        string memory eye = specialIdx == 0 ? _hex(_pickEyeColor(tokenId)) : "7cf08a";
        string memory bg = specialIdx == 0 ? _hex(_pickBackground(tokenId)) : _hex(_oneOfOneBackground(specialIdx));

        return
            string(
                abi.encodePacked(
                    _svgHead(bg),
                    _svgFace(tokenId, specialIdx, skin, hair, eye),
                    _svgBody(suit, tie),
                    _renderTraits(tokenId, specialIdx),
                    _renderIdSignature(tokenId),
                    "</svg>"
                )
            );
    }

    function _renderTraits(uint256 tokenId, uint8 specialIdx) internal pure returns (string memory) {
        if (specialIdx > 0) return "";
        uint256 traitSeed = uint256(keccak256(abi.encodePacked("STONK_BROKER_TRAITS", tokenId)));
        bytes memory traits;

        // Rimless broker glasses
        if (traitSeed % 3 == 0) {
            traits = abi.encodePacked(
                traits,
                '<rect x="8" y="7" width="3" height="3" fill="none" stroke="#d8e1ea" stroke-width="0.4"/><rect x="13" y="7" width="3" height="3" fill="none" stroke="#d8e1ea" stroke-width="0.4"/><rect x="11" y="8" width="2" height="1" fill="#d8e1ea"/>'
            );
        }

        traits = abi.encodePacked(traits, _renderMouthExpression(uint8((traitSeed / 13) % 5)));

        // Trading desk headset with mic boom
        if ((traitSeed / 7) % 4 == 0) {
            traits = abi.encodePacked(
                traits,
                '<rect x="5" y="8" width="2" height="3" fill="#7f8ea3"/><rect x="5" y="7" width="3" height="1" fill="#cfd8e3"/><rect x="6" y="10" width="1" height="2" fill="#cfd8e3"/><rect x="6" y="11" width="3" height="1" fill="#cfd8e3"/><rect x="9" y="11" width="1" height="1" fill="#7f8ea3"/>'
            );
        }

        // Bluetooth earpiece
        if ((traitSeed / 11) % 4 == 0) {
            traits = abi.encodePacked(traits, '<rect x="17" y="10" width="1" height="1" fill="#8fb8ff"/>');
        }

        // Tie clip
        if ((traitSeed / 19) % 2 == 0) {
            traits = abi.encodePacked(traits, '<rect x="11" y="20" width="2" height="1" fill="#d8d8d8"/>');
        }

        // Bull/bear lapel pin
        if ((traitSeed / 23) % 3 == 0) {
            traits = abi.encodePacked(traits, '<rect x="15" y="20" width="1" height="1" fill="#f2c94c"/>');
        }

        return string(traits);
    }

    function _renderMouthExpression(uint8 style) internal pure returns (string memory) {
        if (style == 0) {
            // Neutral
            return '<rect x="10" y="13" width="4" height="1" fill="#101010"/>';
        }
        if (style == 1) {
            // Smile
            return '<rect x="10" y="13" width="4" height="1" fill="#101010"/><rect x="11" y="14" width="2" height="1" fill="#101010"/>';
        }
        if (style == 2) {
            // Frown
            return '<rect x="10" y="13" width="4" height="1" fill="#101010"/><rect x="11" y="12" width="2" height="1" fill="#101010"/>';
        }
        if (style == 3) {
            // Flat no-expression line
            return '<rect x="10" y="13" width="4" height="1" fill="#101010"/>';
        }
        // Open mouth
        return '<rect x="11" y="13" width="2" height="2" fill="#101010"/>';
    }

    function _pickColor(uint256 tokenId, uint256 layer) internal pure returns (bytes3) {
        uint256 palette = uint256(keccak256(abi.encodePacked(tokenId, layer))) % 6;
        if (layer == 0) {
            if (palette == 0) return 0x4f8cff;
            if (palette == 1) return 0x24a148;
            if (palette == 2) return 0xe53935;
            if (palette == 3) return 0xf4b400;
            if (palette == 4) return 0x6f42c1;
            return 0x00a3a3;
        }
        if (layer == 1) {
            if (palette == 0) return 0x1f2328;
            if (palette == 1) return 0x213547;
            if (palette == 2) return 0x2f3e46;
            if (palette == 3) return 0x3c4454;
            if (palette == 4) return 0x4a235a;
            return 0x263238;
        }
        if (layer == 2) {
            if (palette == 0) return 0xf1c27d;
            if (palette == 1) return 0xe0ac69;
            if (palette == 2) return 0xc68642;
            if (palette == 3) return 0x8d5524;
            if (palette == 4) return 0xffdbac;
            return 0xd9a066;
        }
        if (palette == 0) return 0x111111;
        if (palette == 1) return 0x3e2723;
        if (palette == 2) return 0x5d4037;
        if (palette == 3) return 0x6d4c41;
        if (palette == 4) return 0x212121;
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

    function _toHexString(address account) internal pure returns (string memory) {
        return Strings.toHexString(uint256(uint160(account)), 20);
    }

    function _pickBackground(uint256 tokenId) internal pure returns (bytes3) {
        uint256 idx = uint256(keccak256(abi.encodePacked("STONK_BG", tokenId))) % 5;
        if (idx == 0) return 0x6ca0dc;
        if (idx == 1) return 0x8dbfe8;
        if (idx == 2) return 0xb8d2e8;
        if (idx == 3) return 0xd0b090;
        return 0x9bb0c8;
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

    function _svgFace(
        uint256 tokenId,
        uint8 specialIdx,
        string memory skin,
        string memory hair,
        string memory eye
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<rect x="7" y="4" width="10" height="12" fill="#',
                    skin,
                    '"/><rect x="9" y="16" width="6" height="3" fill="#',
                    skin,
                    '"/>',
                    _svgHair(tokenId, hair),
                    '<rect x="8" y="8" width="3" height="2" fill="#f4f4f4"/><rect x="13" y="8" width="3" height="2" fill="#f4f4f4"/>',
                    '<rect x="9" y="8" width="1" height="1" fill="#',
                    eye,
                    '"/><rect x="14" y="8" width="1" height="1" fill="#',
                    eye,
                    '"/><rect x="11" y="10" width="2" height="2" fill="#ba9a95"/>',
                    specialIdx > 0 ? _oneOfOneFaceOverlay() : ""
                )
            );
    }

    function _svgBody(string memory suit, string memory tie) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<rect x="4" y="18" width="16" height="6" fill="#',
                    suit,
                    '"/><rect x="8" y="18" width="8" height="4" fill="#',
                    suit,
                    '"/><rect x="10" y="18" width="4" height="2" fill="#f0f0f0"/><rect x="11" y="19" width="2" height="5" fill="#',
                    tie,
                    '"/><rect x="11" y="23" width="2" height="1" fill="#',
                    tie,
                    '"/><rect x="3" y="19" width="1" height="5" fill="#000"/><rect x="20" y="19" width="1" height="5" fill="#000"/>'
                )
            );
    }

    function _svgHair(uint256 tokenId, string memory hair) internal pure returns (string memory) {
        uint256 style = uint256(keccak256(abi.encodePacked("STONK_HAIR_STYLE", tokenId))) % 6;
        if (style == 0) {
            return
                string(
                    abi.encodePacked(
                        '<rect x="7" y="3" width="10" height="2" fill="#',
                        hair,
                        '"/><rect x="6" y="4" width="1" height="10" fill="#',
                        hair,
                        '"/><rect x="17" y="4" width="1" height="10" fill="#',
                        hair,
                        '"/><rect x="6" y="10" width="2" height="7" fill="#',
                        hair,
                        '"/>'
                    )
                );
        }
        if (style == 1) {
            return
                string(
                    abi.encodePacked(
                        '<rect x="7" y="3" width="10" height="2" fill="#',
                        hair,
                        '"/><rect x="6" y="4" width="1" height="8" fill="#',
                        hair,
                        '"/><rect x="17" y="4" width="1" height="11" fill="#',
                        hair,
                        '"/><rect x="15" y="3" width="2" height="1" fill="#',
                        hair,
                        '"/>'
                    )
                );
        }
        if (style == 2) {
            return
                string(
                    abi.encodePacked(
                        '<rect x="6" y="3" width="12" height="3" fill="#',
                        hair,
                        '"/><rect x="6" y="4" width="1" height="9" fill="#',
                        hair,
                        '"/><rect x="17" y="4" width="1" height="9" fill="#',
                        hair,
                        '"/>'
                    )
                );
        }
        if (style == 3) {
            return
                string(
                    abi.encodePacked(
                        '<rect x="8" y="3" width="8" height="2" fill="#',
                        hair,
                        '"/><rect x="7" y="4" width="1" height="6" fill="#',
                        hair,
                        '"/><rect x="16" y="4" width="1" height="6" fill="#',
                        hair,
                        '"/>'
                    )
                );
        }
        if (style == 4) {
            return
                string(
                    abi.encodePacked(
                        '<rect x="7" y="3" width="10" height="2" fill="#',
                        hair,
                        '"/><rect x="6" y="4" width="1" height="10" fill="#',
                        hair,
                        '"/><rect x="17" y="4" width="1" height="10" fill="#',
                        hair,
                        '"/><rect x="8" y="5" width="1" height="2" fill="#',
                        hair,
                        '"/><rect x="14" y="5" width="1" height="2" fill="#',
                        hair,
                        '"/>'
                    )
                );
        }
        return
            string(
                abi.encodePacked(
                    '<rect x="7" y="2" width="10" height="3" fill="#',
                    hair,
                    '"/><rect x="6" y="4" width="1" height="11" fill="#',
                    hair,
                    '"/><rect x="17" y="4" width="1" height="11" fill="#',
                    hair,
                    '"/>'
                )
            );
    }

    function _renderIdSignature(uint256 tokenId) internal pure returns (string memory) {
        bytes memory sig;
        for (uint256 i = 0; i < 9; i++) {
            if (((tokenId >> i) & 1) == 1) {
                sig = abi.encodePacked(
                    sig,
                    '<rect x="',
                    Strings.toString(10 + i),
                    '" y="23" width="1" height="1" fill="#171717"/>'
                );
            }
        }
        return string(sig);
    }

    function _pickEyeColor(uint256 tokenId) internal pure returns (bytes3) {
        uint256 palette = uint256(keccak256(abi.encodePacked("STONK_EYE_COLOR", tokenId))) % 8;
        if (palette == 0) return 0x2b3fd1;
        if (palette == 1) return 0x4b8f29;
        if (palette == 2) return 0x7d5534;
        if (palette == 3) return 0x5b6678;
        if (palette == 4) return 0x1f7a8c;
        if (palette == 5) return 0x8a4fff;
        if (palette == 6) return 0xb5651d;
        return 0x1d3557;
    }

    function _oneOfOneIndex(uint256 tokenId) internal pure returns (uint8) {
        if (tokenId == 7) return 1;
        if (tokenId == 19) return 2;
        if (tokenId == 33) return 3;
        if (tokenId == 47) return 4;
        if (tokenId == 58) return 5;
        if (tokenId == 72) return 6;
        if (tokenId == 88) return 7;
        if (tokenId == 101) return 8;
        if (tokenId == 117) return 9;
        if (tokenId == 133) return 10;
        if (tokenId == 149) return 11;
        if (tokenId == 166) return 12;
        if (tokenId == 188) return 13;
        if (tokenId == 207) return 14;
        if (tokenId == 233) return 15;
        if (tokenId == 259) return 16;
        if (tokenId == 301) return 17;
        if (tokenId == 337) return 18;
        if (tokenId == 389) return 19;
        if (tokenId == 444) return 20;
        return 0;
    }

    function _oneOfOneName(uint8 idx) internal pure returns (string memory) {
        if (idx == 1) return "Golden Bell Opening";
        if (idx == 2) return "Platinum Macro Alpha";
        if (idx == 3) return "Diamond Desk Captain";
        if (idx == 4) return "Market Oracle";
        if (idx == 5) return "Quant Sovereign";
        if (idx == 6) return "Gamma General";
        if (idx == 7) return "Volatility Baron";
        if (idx == 8) return "Liquidity Titan";
        if (idx == 9) return "Risk Commander";
        if (idx == 10) return "Yield Architect";
        if (idx == 11) return "Alpha Syndicate";
        if (idx == 12) return "Execution Maestro";
        if (idx == 13) return "Orderflow Sensei";
        if (idx == 14) return "Momentum Marshal";
        if (idx == 15) return "Institutional Ace";
        if (idx == 16) return "Hedge Supreme";
        if (idx == 17) return "Closing Bell Legend";
        if (idx == 18) return "Terminal Emperor";
        if (idx == 19) return "Bull Run Regent";
        if (idx == 20) return "Founders Gold";
        return "";
    }

    function _oneOfOneSuitColor(uint8 idx) internal pure returns (bytes3) {
        if (idx % 4 == 0) return 0x1f1f1f;
        if (idx % 4 == 1) return 0x7a6220;
        if (idx % 4 == 2) return 0x4f3f14;
        return 0x9b7a2e;
    }

    function _oneOfOneTieColor(uint8 idx) internal pure returns (bytes3) {
        if (idx % 3 == 0) return 0xf5d36b;
        if (idx % 3 == 1) return 0xffe08a;
        return 0xe9bf52;
    }

    function _oneOfOneBackground(uint8 idx) internal pure returns (bytes3) {
        if (idx % 5 == 0) return 0x5e7aa8;
        if (idx % 5 == 1) return 0x7b95c0;
        if (idx % 5 == 2) return 0x8aa6cf;
        if (idx % 5 == 3) return 0xa4bde0;
        return 0x738ab1;
    }

    function _oneOfOneSkinColor(uint8 idx) internal pure returns (bytes3) {
        if (idx % 3 == 0) return 0xf6d26a;
        if (idx % 3 == 1) return 0xe8c15a;
        return 0xd9ad47;
    }

    function _oneOfOneFaceOverlay() internal pure returns (string memory) {
        return
            '<rect x="7" y="7" width="10" height="3" fill="#101216"/><rect x="8" y="8" width="3" height="1" fill="#1b1f26"/><rect x="13" y="8" width="3" height="1" fill="#1b1f26"/><rect x="11" y="8" width="2" height="1" fill="#0f1115"/><rect x="9" y="8" width="1" height="2" fill="#59d37b"/><rect x="8" y="9" width="3" height="1" fill="#86efac"/><rect x="14" y="8" width="1" height="2" fill="#59d37b"/><rect x="13" y="9" width="3" height="1" fill="#86efac"/>';
    }

    function _renderOneOfOneOverlay(uint8 idx) internal pure returns (string memory) {
        idx;
        return "";
    }
}
