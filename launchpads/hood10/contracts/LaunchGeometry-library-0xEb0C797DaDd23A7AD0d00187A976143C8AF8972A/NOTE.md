## What it is

The external Solidity library `src/LaunchGeometry.sol:LaunchGeometry`, linked into `LaunchFactory` and reached by `delegatecall` during a launch (`_raw/blockscout/tx-flywheel-creation-internal.json`).
Blockscout does not verify a linked library separately, so it shows unverified; `sc-0x7186...json` names it under `external_libraries`, which is the identification.
`sources/src/LaunchGeometry.sol` here is the same file that ships inside the verified `LaunchFactory` sources.
It computes the opening sqrt price and the tick range from `openFdv`, `supply` and `rangeTicks`, handling both currency orderings and the decimal gap between token and quote.
