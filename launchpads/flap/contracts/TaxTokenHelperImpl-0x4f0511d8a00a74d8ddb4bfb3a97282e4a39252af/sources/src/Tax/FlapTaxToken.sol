// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {ERC20Upgradeable} from "@openzeppelin-contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {Initializable} from "@openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import {IFlapTaxToken} from "src/interfaces/Tax/IFlapTaxToken.sol";
import {PoolAddress} from "src/libraries/PoolAddress.sol";
import {
    ERC20PermitUpgradeable
} from "@openzeppelin-contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";

// revision:
//   v0.0.3: Add setMainPool method
//   v0.0.2: Make TAX_DURATION Confiurable
//   v0.0.1: initial version
//

/// @notice FlapTaxToken is an ERC20 token with tax functionality
/// Features:
///    - Anti-farmer tax: Tax is applied to all pools (including v3 pools). Doing
///                       so could restrict the farmers from draining trading fees by providing concentrated liquidity on Uni V3.
//     - Time-dependent tax: the tax is only applied for a certain period of time then it will be automatically removed.
//     - Dynamic Tax Liquidation Threshold: The tax liquidation threshold is dynamically adjusted.
contract FlapTaxToken is Initializable, ERC20PermitUpgradeable, OwnableUpgradeable, IFlapTaxToken {
    /// @notice Constructor parameters for initializing immutable variables
    struct ConstructorParams {
        /// @param PCS_V2_FACTORY The address of the PancakeSwap V2 factory contract
        address PCS_V2_FACTORY;
        /// @param PCS_V2_CODE_HASH The hash of the PancakeSwap V2 code
        bytes32 PCS_V2_CODE_HASH;
        /// @param PCS_V2_ROUTER The address of the PancakeSwap V2 router contract
        /// @dev obsolete
        address PCS_V2_ROUTER;
        /// @param PCS_SMART_ROUTER The address of the PancakeSwap V2 smart router
        /// @dev obsolete
        address PCS_SMART_ROUTER;
        /// @param WETH The address of the WETH contract
        address WETH;
        /// @param PCS_V3_FACTORY The address of the PancakeSwap V3 factory contract
        address PCS_V3_FACTORY;
        /// @param PCS_V3_CODE_HASH The hash of the PancakeSwap V3 code
        bytes32 PCS_V3_CODE_HASH;
        /// @param UNI_V2_FACTORY The address of the Uniswap V2 factory contract
        address UNI_V2_FACTORY;
        /// @param UNI_V2_CODE_HASH The hash of the Uniswap V2 code
        bytes32 UNI_V2_CODE_HASH;
        /// @param UNI_V3_FACTORY The address of the Uniswap V3 factory contract
        address UNI_V3_FACTORY;
        /// @param UNI_V3_CODE_HASH The hash of the Uniswap V3 code
        bytes32 UNI_V3_CODE_HASH;
        /// @param PCS_V4_VAULT The address of the PancakeSwap V4 vault
        address PCS_V4_VAULT;
        /// @param UNI_V4_POOL The address of the Uniswap V4 pool
        address UNI_V4_POOL;
        /// @param MIN_LIQ_THRESHOLD The minimum liquidation threshold
        uint256 MIN_LIQ_THRESHOLD;
        /// @param START_LIQ_THRESHOLD The starting liquidation threshold
        uint256 START_LIQ_THRESHOLD;
        /// @param ANTI_FARMER_DURATION The duration of the anti-farmer tax in seconds
        uint256 ANTI_FARMER_DURATION;
    }

    // Immutable variables
    /// @notice The address of the PancakeSwap V2 factory contract
    address private immutable PCS_V2_FACTORY;
    /// @notice The hash of the PancakeSwap V2 code
    bytes32 private immutable PCS_V2_CODE_HASH;
    /// @notice The address of the PancakeSwap V3 factory contract
    address private immutable PCS_V3_FACTORY;
    /// @notice The hash of the PancakeSwap V3 code
    bytes32 private immutable PCS_V3_CODE_HASH;
    /// @notice The address of the Uniswap V2 factory contract
    address private immutable UNI_V2_FACTORY;
    /// @notice The hash of the Uniswap V2 code
    bytes32 private immutable UNI_V2_CODE_HASH;
    /// @notice The address of the Uniswap V3 factory contract
    address private immutable UNI_V3_FACTORY;
    /// @notice The hash of the Uniswap V3 code
    bytes32 private immutable UNI_V3_CODE_HASH;
    /// @notice the address of the PancakeSwap V4 vault
    address private immutable PCS_V4_VAULT;
    /// @notice the address of the Uniswap V4 pool
    address private immutable UNI_V4_POOL;

    /// @notice The address of the WETH contract
    address private immutable WETH;

    /// @notice The address of the PancakeSwap V2 router (repurposed for default router)
    address private immutable PCS_V2_ROUTER;

    /// @notice The quote token used for pools (can be WETH or any ERC20)
    address public QUOTE_TOKEN;

    /// @notice The minimum liquidation threshold
    uint256 public immutable MIN_LIQ_THRESHOLD;
    /// @notice The starting liquidation threshold
    uint256 public immutable START_LIQ_THRESHOLD;
    /// @notice The expected output amount in each liquidation
    /// @dev i.e, the expected output QUOTE_TOKEN amount in each liquidation
    uint256 public liqExpectedOutputAmount;

    /// @notice The duration of the anti-farmer tax in seconds
    uint256 public immutable ANTI_FARMER_DURATION;

    // State variables
    /// @notice The metadata URI of the token
    string public override metaURI;
    /// @notice The tax rate for the token in basis points
    uint16 public taxRate;
    /// @notice The address of the tax splitter contract
    address public taxSplitter;
    /// @notice The threshold of tokens for liquidity
    uint256 public liquidationThreshold;
    /// @notice The address of the V2 pool
    address public mainPool;
    /// @notice the main pool router
    address public mainPoolRouter;
    /// @notice The maximum supply of the token
    uint256 public constant maxSupply = 1e9 ether; // 1 billion tokens
    /// @notice The duration of the tax in seconds
    uint256 public TAX_DURATION;

    /// @notice Indicates whether the contract is not in the middle of a tax liquidation
    /// @dev gas saving to use a default value of true.
    bool private notLiquidating;

    /// @notice Include all the pools related to this token
    /// Of course, this does not include all the pools, we only put some most
    /// used pools here.
    mapping(address => bool) public pools;

    /// @notice Enum to represent the state of the pool
    enum PoolState {
        BondingCurve, // state0: Token is trading on the bonding curve, no tax, no transfers to pools
        Migrating, // state1: Token is in the process of migration
        TaxEnforcedAntiFarmer, // state2: Token listed on DEX, tax applied for transfers involving any pool
        TaxEnforced, // state3: Token listed on DEX, tax applied for transfers involving mainPool
        TaxFree // state4: Token is free of tax
    }

    /// @notice Current state of the pool
    PoolState public state;

    /// @notice Timestamp when the tax expires
    uint256 public taxExpirationTime;

    /// @notice Timestamp when the anti-farmer tax expires
    uint256 public antiFarmerExpirationTime;

    /// @notice Constructor to initialize immutable variables
    /// @param params The constructor parameters
    constructor(ConstructorParams memory params) {
        PCS_V2_FACTORY = params.PCS_V2_FACTORY;
        PCS_V2_CODE_HASH = params.PCS_V2_CODE_HASH;
        PCS_V2_ROUTER = params.PCS_V2_ROUTER;
        WETH = params.WETH;
        PCS_V3_FACTORY = params.PCS_V3_FACTORY;
        PCS_V3_CODE_HASH = params.PCS_V3_CODE_HASH;
        UNI_V2_FACTORY = params.UNI_V2_FACTORY;
        UNI_V2_CODE_HASH = params.UNI_V2_CODE_HASH;
        UNI_V3_FACTORY = params.UNI_V3_FACTORY;
        UNI_V3_CODE_HASH = params.UNI_V3_CODE_HASH;
        MIN_LIQ_THRESHOLD = params.MIN_LIQ_THRESHOLD;
        START_LIQ_THRESHOLD = params.START_LIQ_THRESHOLD;

        // Initialize new immutable variables
        ANTI_FARMER_DURATION = params.ANTI_FARMER_DURATION;
        PCS_V4_VAULT = params.PCS_V4_VAULT;
        UNI_V4_POOL = params.UNI_V4_POOL;

        _disableInitializers();
    }

    /// @notice Starts the migration process by transitioning the state of the pool
    function startMigration() external override onlyOwner {
        if (state == PoolState.BondingCurve) {
            state = PoolState.Migrating;
            emit PoolStateChanged(uint8(PoolState.BondingCurve), uint8(state));
        }
    }

    /// @notice Finalizes the migration by transitioning the state of the pool
    function finalizeMigration() external override onlyOwner {
        if (state == PoolState.Migrating) {
            state = PoolState.TaxEnforcedAntiFarmer;
            taxExpirationTime = block.timestamp + TAX_DURATION;
            antiFarmerExpirationTime = block.timestamp + ANTI_FARMER_DURATION;
            emit PoolStateChanged(uint8(PoolState.Migrating), uint8(state));
        }
    }

    /// @notice Change the main pool address
    /// @dev Can only be called by owner
    /// @dev Can only be called in the state of BondingCurve
    /// @param newMainPool The new main pool address
    /// @param router The address of the router for the main pool
    function setMainPool(address newMainPool, address router) external override onlyOwner {
        require(state == PoolState.BondingCurve, "Can only set main pool in BondingCurve state");
        require(newMainPool != address(0), "Invalid pool address");
        require(router != address(0), "Invalid router address");

        // Remove old main pool from the pools mapping
        pools[mainPool] = false;

        // Update main pool
        mainPool = newMainPool;
        mainPoolRouter = router;

        // Add new main pool to the pools mapping
        pools[newMainPool] = true;
    }

    /// @notice Initializes the token with the given parameters
    /// @param params The initialization parameters
    function initialize(InitParams memory params) external initializer {
        // Validate that tax duration is at least as long as anti-farmer duration
        require(params.taxDuration >= ANTI_FARMER_DURATION, "Tax duration must be >= anti-farmer duration");

        __ERC20_init(params.name, params.symbol);
        __ERC20Permit_init(params.name);
        __Ownable_init();

        metaURI = params.meta;
        taxRate = params.tax;
        taxSplitter = params.taxSplitter;
        liquidationThreshold = START_LIQ_THRESHOLD;
        notLiquidating = true;
        TAX_DURATION = params.taxDuration;

        // mint 1B to the msg.sender
        _mint(msg.sender, maxSupply);

        // Set QUOTE_TOKEN
        QUOTE_TOKEN = params.quoteToken;

        // Set liqExpectedOutputAmount from params
        liqExpectedOutputAmount = params.liqExpectedOutputAmount;

        //
        // pre-compute all pool addresses related to this token
        //

        // This is our main pool, we are using the PancakeSwap V2 pool as the main pool
        mainPool = PoolAddress.computeV2Address(PCS_V2_FACTORY, PCS_V2_CODE_HASH, address(this), QUOTE_TOKEN);

        // Initialize mainPoolRouter with PCS_V2_ROUTER
        mainPoolRouter = PCS_V2_ROUTER;

        // v2 pools

        // add the main pool to the mapping
        pools[mainPool] = true;
        // add uniswap v2 pool to the mapping
        pools[PoolAddress.computeV2Address(UNI_V2_FACTORY, UNI_V2_CODE_HASH, address(this), QUOTE_TOKEN)] = true;

        // v3 pools

        uint24[5] memory fees = [uint24(100), 500, 2500, 3000, 10000];
        uint256 feesLength = fees.length; // gas saving, reading the slot only once

        for (uint256 i = 0; i < feesLength; i++) {
            uint24 fee = fees[i];
            // Add PancakeSwap V3 pools to the mapping
            pools[PoolAddress.computeV3Address(PCS_V3_FACTORY, PCS_V3_CODE_HASH, address(this), QUOTE_TOKEN, fee)] =
            true;
            // Add Uniswap V3 pools to the mapping
            pools[PoolAddress.computeV3Address(UNI_V3_FACTORY, UNI_V3_CODE_HASH, address(this), QUOTE_TOKEN, fee)] =
            true;
        }

        // Add PCS_V4_VAULT and UNI_V4_POOL to the mapping
        pools[PCS_V4_VAULT] = true;
        pools[UNI_V4_POOL] = true;
    }

    /// @notice Internal function to perform a plain (no tax) transfer
    /// @param from The address sending the tokens
    /// @param to The address receiving the tokens
    /// @param amount The amount of tokens to transfer
    function _plainTransfer(address from, address to, uint256 amount) internal {
        super._transfer(from, to, amount);
    }

    /// @notice Internal function to calculate the tax amount
    /// @param from The address sending the tokens
    /// @param to The address receiving the tokens
    /// @param amount The amount of tokens to transfer
    /// @return The tax amount
    function _getTax(address from, address to, uint256 amount) internal view returns (uint256) {
        if (notLiquidating) {
            if (state == PoolState.TaxEnforcedAntiFarmer) {
                // Apply tax if transfer involves any pool
                if (pools[from] || pools[to]) {
                    return (amount * taxRate) / 10000;
                }
            } else if (state == PoolState.TaxEnforced) {
                // Apply tax only if transfer involves v2Pool
                if (from == mainPool || to == mainPool) {
                    return (amount * taxRate) / 10000;
                }
            }
        }
        return 0;
    }

    /// @notice Internal function to perform a taxed transfer
    /// @param from The address sending the tokens
    /// @param to The address receiving the tokens
    /// @param amount The amount of tokens to transfer
    /// @param tax The tax amount for the transfer
    function _taxedTransfer(address from, address to, uint256 amount, uint256 tax) internal {
        uint256 remainingAmount = amount - tax;

        _plainTransfer(from, address(this), tax);
        _plainTransfer(from, to, remainingAmount);
    }

    /// @notice Overrides the _transfer function to handle tax and liquidation
    /// @param from The address sending the tokens
    /// @param to The address receiving the tokens
    /// @param amount The amount of tokens to transfer
    function _transfer(address from, address to, uint256 amount) internal override {
        _liquidateTax(to);

        if (state == PoolState.BondingCurve) {
            require(!pools[from] && !pools[to], "Transfers to/from pools are restricted in BondingCurve state");
            _plainTransfer(from, to, amount);
        } else if (state == PoolState.Migrating) {
            _plainTransfer(from, to, amount);
        } else if (state == PoolState.TaxEnforcedAntiFarmer || state == PoolState.TaxEnforced) {
            uint256 tax = _getTax(from, to, amount);
            if (tax > 0) {
                _taxedTransfer(from, to, amount, tax);
            } else {
                _plainTransfer(from, to, amount);
            }
        } else {
            // TaxFree state
            _plainTransfer(from, to, amount);
        }
    }

    /// @notice Internal function to liquidate the accrued tax amount
    /// @param to the recipient of the current transfer call
    function _liquidateTax(address to) internal {
        // Note: from == mainPool does not work and leads to a DOS vector.
        // Uniswap v2 pair has a lock, if the user swaps WETH for the token, the pair first locks the pair and then
        // transfers the token to the user (i.e from == mainPool).  We could not liquidate in that "transfer" as the pair is already locked.
        // Besides, the flash swap does not work even when swapping the token for WETH due to the same reason.
        // For the tax token, you should follow the normal flow:
        //  (1) transfer token/WETH to the pair
        //  (2) call the pair's swap function.

        if (
            (state == PoolState.TaxEnforced || state == PoolState.TaxEnforcedAntiFarmer) // only when tax is enforced
                && notLiquidating // not in the middle of liquidation
                && (to == mainPool) // possibly selling to the main v2 pool
        ) {
            // State transition
            if (block.timestamp > taxExpirationTime) {
                PoolState oldState = state;
                state = PoolState.TaxFree;
                taxRate = 0; // reset tax rate
                emit PoolStateChanged(uint8(oldState), uint8(state));
            } else if (block.timestamp > antiFarmerExpirationTime && state != PoolState.TaxEnforced) {
                PoolState oldState = state;
                state = PoolState.TaxEnforced;
                emit PoolStateChanged(uint8(oldState), uint8(state));
            }

            uint256 taxAmount = balanceOf(address(this));

            if (
                taxAmount > 0 // Tax to liquidate
                    && (state == PoolState.TaxFree || taxAmount >= liquidationThreshold) // Enough tax to liquidate or last liquidation
            ) {
                notLiquidating = false; // start liquidation

                // Approve the router to spend tax tokens if needed
                if (allowance(address(this), mainPoolRouter) < taxAmount) {
                    _approve(address(this), mainPoolRouter, type(uint256).max);
                }

                // Always swap to quote token (ERC20)
                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = QUOTE_TOKEN;

                // Get expected output amount using getAmountsOut
                uint256[] memory amounts = IUniswapRouter02(mainPoolRouter).getAmountsOut(taxAmount, path);
                uint256 outputAmount = amounts[1];

                try IUniswapRouter02(mainPoolRouter)
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        taxAmount, outputAmount, path, taxSplitter, block.timestamp
                    ) {
                    _adjustLiquidationThreshold(taxAmount, outputAmount);
                    // emit an event for successful liquidation
                    // We intentionally make the event's name long to ease our indexer
                    emit FlapTaxLiquidationSuccess(QUOTE_TOKEN, taxAmount, outputAmount);
                } catch (bytes memory reason) {
                    emit TaxLiquidationError(reason);
                    _plainTransfer(address(this), taxSplitter, taxAmount);
                }

                notLiquidating = true; // end of liquidation
            }
        }
    }

    /// @notice Adjusts the liquidation threshold based on the tax amount and output amount
    /// @param taxAmount The amount of tax being liquidated
    /// @param outputAmount The output amount from the liquidation
    function _adjustLiquidationThreshold(uint256 taxAmount, uint256 outputAmount) internal {
        // We only monotonically reduce the liquidation threshold until it reaches the minimum threshold
        uint256 expectedOutputAmount = (outputAmount * liquidationThreshold) / taxAmount;
        if (expectedOutputAmount > liqExpectedOutputAmount) {
            liquidationThreshold = (liquidationThreshold * 99) / 100; // Reduce by 1%
            if (liquidationThreshold < MIN_LIQ_THRESHOLD) {
                liquidationThreshold = MIN_LIQ_THRESHOLD;
            }
        }
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal override {
        emit TransferFlapToken(from, to, amount);
    }
}

    /// @dev This is a stripped version of the Uniswap SwapRouter02 interface
    /// https://github.com/Uniswap/swap-router-contracts/blob/v1.3.0/contracts/SwapRouter02.sol
    /// In the context of PancakeSwap, it is named as SmartRouter:
    /// https://bscscan.com/address/0x13f4EA83D0bd40E75C8222255bc855a974568Dd4#code
    interface ISmartRouter {
        /// @notice Call multiple functions in the current contract and return the data from all of them if they all succeed
        /// @dev The `msg.value` should not be trusted for any method callable from multicall.
        /// @param data The encoded function data for each of the calls to make to this contract
        /// @return results The results from each of the calls passed in via data
        function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);

        /// @notice Unwraps the contract's WETH9 balance and sends it to recipient as ETH.
        /// @dev The amountMinimum parameter prevents malicious contracts from stealing WETH9 from users.
        /// @param amountMinimum The minimum amount of WETH9 to unwrap
        /// @param recipient The address receiving ETH
        function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;

        /// @notice Swaps `amountIn` of one token for as much as possible of another token
        /// @dev Setting `amountIn` to 0 will cause the contract to look up its own balance,
        /// and swap the entire amount, enabling contracts to send tokens before calling this function.
        /// @param amountIn The amount of token to swap
        /// @param amountOutMin The minimum amount of output that must be received
        /// @param path The ordered list of tokens to swap through
        /// @param to The recipient address
        /// @return amountOut The amount of the received token
        function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to)
            external
            payable
            returns (uint256 amountOut);

        /// @notice Transfers the full amount of a token held by this contract to recipient
        /// @dev The amountMinimum parameter prevents malicious contracts from stealing the token from users
        /// @param token The contract address of the token which will be transferred to `recipient`
        /// @param amountMinimum The minimum amount of token required for a transfer
        /// @param recipient The destination address of the token
        function sweepToken(address token, uint256 amountMinimum, address recipient) external payable;
    }

    interface IUniswapRouter02 {
        // @notice Swaps an exact amount of input tokens for as many output tokens as possible, with support for fee-on-transfer tokens
        function swapExactTokensForETHSupportingFeeOnTransferTokens(
            uint256 amountIn,
            uint256 amountOutMin,
            address[] calldata path,
            address to,
            uint256 deadline
        ) external;

        // @notice Swaps an exact amount of input tokens for as many output tokens as possible, with support for fee-on-transfer tokens
        function swapExactTokensForTokensSupportingFeeOnTransferTokens(
            uint256 amountIn,
            uint256 amountOutMin,
            address[] calldata path,
            address to,
            uint256 deadline
        ) external;

        // @notice Given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
        function getAmountsOut(uint256 amountIn, address[] calldata path)
            external
            view
            returns (uint256[] memory amounts);
    }

