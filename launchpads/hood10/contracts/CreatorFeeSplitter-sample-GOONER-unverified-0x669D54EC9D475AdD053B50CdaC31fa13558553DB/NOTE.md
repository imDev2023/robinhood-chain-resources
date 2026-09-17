## Identified by selector matching

Unverified for the same reason as the treasury: deployed with `new` by `DividendDeployer`.
`PairDeployed` names it as the splitter for GOONER's pool.

Selectors resolved from bytecode match `CreatorFeeSplitter.sol`: `acceptCreator()`, `acceptCreator(bytes32)`, `push(uint256)`, `pushAll()`, `claim(bytes32,address)`, `isWired()`, `metadataAdmin()`, `setMetadataURI(string)`, `feeRecipient()`, `treasury()`, `payoutToken()`, `MAX_CUT()`, `CutTooLarge(uint256,uint256)`.
Readable source is in `../DividendDeployer-0x3087cFD761D679Ded5d0a2baf4d3577aE447d5E3/sources/src/CreatorFeeSplitter.sol`.
