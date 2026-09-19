// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

error ZeroAddress();
error Unauthorized();
error InvalidConfig();

error InvalidTokensPerNFT();
error InvalidRandomFee();
error InvalidSpecificFee();
error InvalidBorrowAPY();
error MarketExists();
error NotERC721();

error BucketCapExceeded();
error ReturnExceedsReleased();
error InvariantViolation();

error EmptyInventory();
error NotInInventory();
error SlippageExceeded();
error InsufficientEthFee();
error EthTransferFailed();

error DurationTooShort();
error DurationTooLong();
error MaxLoansExceeded();
error LoanNotActive();
error GraceNotExpired();
error NotBorrower();
error NFTIsCollateralized();

// Activation
error NotTokenOwner();
error InvalidTier();
error TierNotUpgrade();
error NotActivated();
error InvalidFeeSplit();

// Stock booster
error RouterNotAllowlisted();
error StockListNotSet();
error NoActiveWeight();
error DropBelowThreshold();
error DropRoundInProgress();
error NoDropRoundInProgress();
error PublicStartNotConfigured();
