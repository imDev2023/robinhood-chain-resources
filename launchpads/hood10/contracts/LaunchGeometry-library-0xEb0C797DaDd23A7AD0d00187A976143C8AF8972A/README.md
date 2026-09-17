# LaunchGeometry-library - 0xEb0C797DaDd23A7AD0d00187A976143C8AF8972A

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xEb0C797DaDd23A7AD0d00187A976143C8AF8972A
Role: LaunchGeometry-library.
Contract name: unknown (unverified).
Verified: None (verified at None).
Compiler: None, EVM None, optimizer None runs None.
Main file: None.
Source files on disk: 1 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0xc0b90d428591d15a371116e940d7331907b1d510fb7971acc97b98679db93191.
Proxy type: None; implementations: [].
External libraries: none.

## What it is

The external Solidity library `src/LaunchGeometry.sol:LaunchGeometry`, linked into `LaunchFactory` and reached by `delegatecall` during a launch (`_raw/blockscout/tx-flywheel-creation-internal.json`).
Blockscout does not verify a linked library separately, so it shows unverified; `sc-0x7186...json` names it under `external_libraries`, which is the identification.
`sources/src/LaunchGeometry.sol` here is the same file that ships inside the verified `LaunchFactory` sources.
It computes the opening sqrt price and the tick range from `openFdv`, `supply` and `rangeTicks`, handling both currency orderings and the decimal gap between token and quote.

## Constructor arguments

None decoded.

## Events

None.

## State-changing functions

None.

## View functions

None.
