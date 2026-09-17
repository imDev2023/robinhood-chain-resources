# NoxaIO-LaunchFactory - 0xa24d48d50fd7985c6de816eaf77c1a17d3593bbe

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xa24d48d50fd7985c6de816eaf77c1a17d3593bbe
Role: NoxaIO-LaunchFactory.
Contract name: LaunchFactory.
Verified: True.
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: LaunchFactory_flat.sol.
Source files written: 24 under `sources/`.
Creator: 0x407Fe47FA03617062E9cD27DCACe8DAB006322d8.
Creation tx: 0xef86f678a24c5424ebfb9d166139bf6ef370e02509c0a25226147a4a6582de81.
Proxy type: None; implementations: [].

The launch factory used by the separate noxa.io interface. Verified, deployed by 0x407Fe47FA03617062E9cD27DCACe8DAB006322d8, `launchEnabled()` true and `launchFee()` 0.0005 ETH on 2026-09-03. Distinct code from both fun.noxa.fi factories: it adds CTO vaults (`ctoVaultOf`, `ctoSnapshot`, `ctoFund`) and routes fees through a FeeRouter rather than paying the creator directly.

## Constructor arguments

- `locker_` (address): `0x90331A631123bD2493Ba962c4304dcb49f3A5d4A`
- `launchFee_` (uint256): `500000000000000`
- `launchEnabled_` (bool): `false`

## Events

- `CTOFeeVaultCreated(address,address,address)`
- `CTOFundConfigured(address)`
- `DexConfigAdded(uint256)`
- `DexStatusUpdated(uint256,bool)`
- `FeeRecipientRestrictionExempted(address,address)`
- `LaunchConfigAdded(uint256)`
- `LaunchConfigUpdated(uint256)`
- `LaunchEnabledUpdated(bool)`
- `LaunchFeeUpdated(uint256)`
- `OwnershipTransferred(address,address)`
- `TokenDeployed(address,address,address,address,uint256,uint256)`
- `TokenLaunched(address,address,address,address,address,uint256,uint256,uint256,uint256,uint256)`
- `TokenMetadata(address,string,string,string,string,string,string,string,string,string,address)`
- `WhitelistedLauncherUpdated(address,bool)`

## State-changing functions

- `addDexConfig(tuple)`
- `addLaunchConfig(tuple)`
- `ctoSnapshot(address)`
- `launchToken(tuple,uint256,uint256,bytes32)`
- `renounceOwnership()`
- `setCTOFund(address)`
- `setDexStatus(uint256,bool)`
- `setLaunchEnabled(bool)`
- `setLaunchFee(uint256)`
- `setWhitelistedLauncher(address,bool)`
- `syncFeeRecipientExemptions(address)`
- `transferOwnership(address)`
- `uniswapV3SwapCallback(int256,int256,bytes)`
- `updateLaunchConfig(uint256,tuple)`

## View functions

- `ctoFund()`
- `ctoVaultImplementation()`
- `ctoVaultOf(address)`
- `dexConfigCount()`
- `getDexConfig(uint256)`
- `getLaunchConfig(uint256)`
- `getLaunchedToken(address)`
- `isLaunchedToken(address)`
- `launchConfigCount()`
- `launchEnabled()`
- `launchFee()`
- `locker()`
- `owner()`
- `poolOf(address)`
- `whitelistedLaunchers(address)`
