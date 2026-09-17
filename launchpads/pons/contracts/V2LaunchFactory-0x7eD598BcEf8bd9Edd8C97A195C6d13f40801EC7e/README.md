# V2LaunchFactory

`0x7eD598BcEf8bd9Edd8C97A195C6d13f40801EC7e`

Group: pons v2.
Entry point. launchToken, graduate, createGraduatedPool, launch configs, pair-token approvals, creator-fee-recipient timelock.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `PonsV2LaunchFactory` |
| Compiler | v0.8.35+commit.47b9dedd |
| Optimizer | True, runs 200 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36` |
| Creation tx | `0x3817f297aa7c2ef78789bffac57491ceedc218fef962d47ed36c272699deddeb` |

## Constructor arguments

- `initialOwner` (address) = `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36`
- `poolManager_` (contract IPoolManager) = `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `positionManager_` (contract IPositionManager) = `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `permit2_` (contract IAllowanceTransfer) = `0x000000000022D473030F116dDEE9F6B43aC78BA3`
- `locker_` (contract PonsV2LaunchLocker) = `0x267444D099b10fB5Ed7c3Cc7B7c767AdcA574952`
- `memeHook_` (contract PonsV2MemeHook) = `0xE5e702641Ea86F4ae6cC3cDaeD2B886f976Be044`
- `feeEscrow_` (contract IPonsV2FeeEscrow) = `0xd3AFEB2a57f70eF218Aa82451c51B2fb0416Ac9e`
- `buybackVault_` (contract PonsV2BuybackVault) = `0x42df2a798f82289E177311362e8f5ccC45c1219c`
- `initialLaunchFee` (uint256) = `500000000000000`

## Functions that matter for launching

- `addLaunchConfig(tuple config)`
- `cancelCreatorFeeRecipientChange(address token)`
- `createGraduatedPool(address token)`
- `executeCreatorFeeRecipientChange(address token)`
- `graduate(address token)`
- `launchToken(tuple params, uint256 launchConfigId, address pairToken, address[] snipeTaxExemptions)` payable
- `launchToken(tuple params, uint256 launchConfigId, address pairToken)` payable
- `launchTokenFor(tuple params, uint256 launchConfigId, address pairToken, address originalDeployer, address[] snipeTaxExemptions)` payable
- `rescueCurveFees(address token)`
- `setBuybackEnabled(address token, bool enabled)`
- `setCreatorFeeRecipient(address token, address newRecipient)`
- `setLaunchDeployer(address deployer)`
- `setLaunchEnabled(bool enabled)`
- `setLaunchFee(uint256 newLaunchFee)`
- `setLaunchForwarder(address forwarder)`
- `setMaxCreatorTaxBps(uint256 bps)`
- `setSnipeTaxSeconds(uint256 secondsWindow)`
- `setSnipeTaxStartBps(uint256 bps)`
- `setWhitelistedLauncher(address launcher, bool enabled)`
- `transferCreatorFeeRecipient(address token, address newRecipient)`
- `updateLaunchConfig(uint256 id, tuple config)`

## Reads that matter

- `CREATOR_FEE_RECIPIENT_EXECUTION_WINDOW()`
- `CREATOR_FEE_RECIPIENT_TIMELOCK()`
- `buybackVault()`
- `canLaunch(address launcher)`
- `feeEscrow()`
- `getLaunchConfig(uint256 id)`
- `getLaunchFeePolicy(address token)`
- `getLaunchedToken(address token)`
- `launchConfigCount()`
- `launchDeployer()`
- `launchEnabled()`
- `launchFee()`
- `launchForwarder()`
- `locker()`
- `maxCreatorTaxBps()`
- `pendingCreatorFeeRecipient(address token)`
- `previewLaunchEconomics(uint256 launchConfigId, address pairToken)`
- `snipeTaxSeconds()`
- `snipeTaxStartBps()`
- `whitelistedLaunchers(address launcher)`

## Events

- `BuybackEnabledUpdated(address token, bool enabled, address controller)`
- `CreatorFeeRecipientChangeCancelled(address token, address proposedRecipient)`
- `CreatorFeeRecipientChangeProposed(address token, address currentRecipient, address proposedRecipient, uint256 effectiveAt, uint256 expiresAt)`
- `CreatorFeeRecipientUpdated(address token, address previousRecipient, address newRecipient)`
- `GraduationTokensPermanentlyLocked(address token, uint256 amount)`
- `LaunchConfigAdded(uint256 id)`
- `LaunchConfigUpdated(uint256 id)`
- `LaunchDeployerSet(address deployer)`
- `LaunchEnabledUpdated(bool enabled)`
- `LaunchFeeUpdated(uint256 launchFee)`
- `LaunchForceSwept(address token)`
- `LaunchForwarderSet(address forwarder)`
- `LaunchGraduationRescued(address token, address recipient, uint256 quoteAmount, uint256 tokenAmount)`
- `LaunchSwept(address token, uint256 quoteOut, uint256 tokenOut)`
- `MaxCreatorTaxUpdated(uint256 bps)`
- `PoolGraduated(address token, uint256 positionId, uint256 tokenAmount, uint256 pairTokenAmount)`
- `SnipeTaxSecondsUpdated(uint256 secondsWindow)`
- `SnipeTaxStartBpsUpdated(uint256 bps)`
- `TokenLaunched(address token, address curve, address deployer, address pairToken, uint256 launchConfigId, uint256 graduationThreshold)`
- `WhitelistedLauncherUpdated(address launcher, bool enabled)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 28 state-changing functions, 32 views, 25 events, 52 custom errors.
