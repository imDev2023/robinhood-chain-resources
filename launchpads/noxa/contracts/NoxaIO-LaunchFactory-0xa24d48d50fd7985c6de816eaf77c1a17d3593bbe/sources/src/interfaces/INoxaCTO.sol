// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @notice Historical-balance surface required by the Noxa CTO election.
interface INoxaSnapshotToken {
    function balanceOfAt(address account, uint256 snapshotId) external view returns (uint256);
    function totalSupplyAt(uint256 snapshotId) external view returns (uint256);
    function votingExcludedSupplyAt(uint256 snapshotId) external view returns (uint256);
    function finalizedBalanceAt(address account, uint256 snapshotId) external view returns (uint256);
    function finalizedVotingExcludedSupplyAt(uint256 snapshotId) external view returns (uint256);
}

/// @notice Factory adapter used by the standalone CTO election module.
/// @dev The factory remains the only address allowed to ask a LaunchToken for a snapshot.
interface INoxaCTOFactory {
    function isLaunchedToken(address token) external view returns (bool);
    function ctoSnapshot(address token) external returns (uint256 snapshotId);
    function poolOf(address token) external view returns (address);
    function ctoVaultOf(address token) external view returns (address);
}

/// @notice Per-token fee vault surface used by the election module.
interface ICTOFeeVault {
    function initialize(address token, address pairToken, address ctoFund) external;
    function token() external view returns (address);
    function ctoFund() external view returns (address);

    function claimTo(address recipient) external returns (uint256 tokenAmount, uint256 pairAmount, uint256 nativeAmount);
}

/// @notice Factory-facing surface of the CTO election module.
interface INoxaCTOFund {
    function factory() external view returns (address);
    function onCreate(address token, address initialLeader) external;
    function leader(address token) external view returns (address);
}
