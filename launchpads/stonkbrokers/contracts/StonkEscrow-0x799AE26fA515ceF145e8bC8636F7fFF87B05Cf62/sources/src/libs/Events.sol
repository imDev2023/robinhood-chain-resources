// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Events {
    event EscrowReleased(address indexed to, uint256 amount, uint8 bucketType);
    event EscrowReturned(address indexed from, uint256 amount, uint8 bucketType);
    event BucketRebalanced(uint8 fromBucket, uint8 toBucket, uint256 amount);

    event NFTSold(
        address indexed seller,
        uint256 indexed tokenId,
        uint256 tokensOut,
        uint256 ethFeePaid,
        uint256 boosterShare,
        uint256 protocolShare
    );

    event NFTBought(
        address indexed buyer,
        uint256 indexed tokenId,
        uint256 tokensIn,
        uint256 ethFeePaid,
        uint256 boosterShare,
        uint256 protocolShare,
        bool isSpecific
    );

    event MarketCreated(
        address indexed collection,
        address indexed token,
        address escrow,
        address ammVault,
        address loanVault,
        address activationManager,
        address stockBooster
    );

    event FeesUpdated(address indexed vault, uint16 randomFeeBps, uint16 specificFeeBps);
    event EthNotionalUpdated(address indexed vault, uint256 oldNotionalWei, uint256 newNotionalWei);
    event TwapOracleUpdated(
        address indexed vault, address pool, address quoteToken, address midPool, address midToken, uint32 window
    );
    event NotionalBoundsUpdated(address indexed vault, uint256 minWei, uint256 maxWei);
    event TwapFastWindowUpdated(address indexed vault, uint32 fastWindow, uint16 capBps);
    event FeeExemptUpdated(address indexed vault, address indexed account, bool exempt);

    event LoanCreated(
        address indexed borrower,
        uint256 indexed loanId,
        uint256 indexed tokenId,
        uint256 principal,
        uint256 duration,
        uint256 ethFeePaid,
        uint256 boosterShare,
        uint256 protocolShare
    );
    event LoanRepaid(address indexed borrower, uint256 indexed loanId, uint256 principalRepaid, uint256 lateFeeEth);
    event LoanLiquidated(address indexed liquidator, uint256 indexed loanId, uint256 incentive);

    // Activation
    event Activated(uint256 indexed tokenId, address indexed owner, uint8 tier, uint256 feePaid);
    event ActivationUpgraded(uint256 indexed tokenId, address indexed owner, uint8 fromTier, uint8 toTier, uint256 feePaid);
    event ActivationCleared(uint256 indexed tokenId);
    event ActivationFeeSplitUpdated(uint16 burnBps, uint16 protocolBps, uint16 redirectBps, address redirectReceiver);

    // Stock booster
    event StockTokensUpdated(address indexed a, address indexed b, address indexed c);
    event RouterUpdated(address indexed router, bool allowed);
    event MinStockPerEthUpdated(address indexed stock, uint256 ratePerEth);
    event DropStarted(uint256 indexed round, uint256 ethSpent, uint256 totalWeightSnapshot);
    event DropPaid(uint256 indexed round, uint256 indexed tokenId, address indexed wallet);
    event DropFinished(uint256 indexed round, uint256 recipients);
    event DropTransferSkipped(uint256 indexed round, uint256 indexed tokenId, address indexed stock, uint256 amount);
    event DropCancelled(uint256 indexed round, uint256 cursorAtCancel);
    event BoosterEthRescued(address indexed to, uint256 amount);
    event BoosterTokenRescued(address indexed token, address indexed to, uint256 amount);
}
