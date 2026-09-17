# SafeL2 - 0x29fcB43b46531BcA003ddC8FCB67FFE91900C762

Role: GnosisSafe-MasterCopy.
Address: `0x29fcB43b46531BcA003ddC8FCB67FFE91900C762` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x29fcB43b46531BcA003ddC8FCB67FFE91900C762
Verified: True (fully verified: True, partially: False).
Compiler: v0.7.6+commit.7338295f, EVM default, optimizer False runs None.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `contracts/SafeL2.sol`. Source files written: 46 under `sources/`.
Raw constructor args: `None`.

## Functions

- `VERSION()` -> string [view]
- `addOwnerWithThreshold(address owner, uint256 _threshold)` ->  [nonpayable]
- `approveHash(bytes32 hashToApprove)` ->  [nonpayable]
- `approvedHashes(address, bytes32)` -> uint256 [view]
- `changeThreshold(uint256 _threshold)` ->  [nonpayable]
- `checkNSignatures(bytes32 dataHash, bytes data, bytes signatures, uint256 requiredSignatures)` ->  [view]
- `checkSignatures(bytes32 dataHash, bytes data, bytes signatures)` ->  [view]
- `disableModule(address prevModule, address module)` ->  [nonpayable]
- `domainSeparator()` -> bytes32 [view]
- `enableModule(address module)` ->  [nonpayable]
- `encodeTransactionData(address to, uint256 value, bytes data, uint8 operation, uint256 safeTxGas, uint256 baseGas, uint256 gasPrice, address gasToken, address refundReceiver, uint256 _nonce)` -> bytes [view]
- `execTransaction(address to, uint256 value, bytes data, uint8 operation, uint256 safeTxGas, uint256 baseGas, uint256 gasPrice, address gasToken, address refundReceiver, bytes signatures)` -> bool [payable]
- `execTransactionFromModule(address to, uint256 value, bytes data, uint8 operation)` -> bool [nonpayable]
- `execTransactionFromModuleReturnData(address to, uint256 value, bytes data, uint8 operation)` -> bool, bytes [nonpayable]
- `getChainId()` -> uint256 [view]
- `getModulesPaginated(address start, uint256 pageSize)` -> address[], address [view]
- `getOwners()` -> address[] [view]
- `getStorageAt(uint256 offset, uint256 length)` -> bytes [view]
- `getThreshold()` -> uint256 [view]
- `getTransactionHash(address to, uint256 value, bytes data, uint8 operation, uint256 safeTxGas, uint256 baseGas, uint256 gasPrice, address gasToken, address refundReceiver, uint256 _nonce)` -> bytes32 [view]
- `isModuleEnabled(address module)` -> bool [view]
- `isOwner(address owner)` -> bool [view]
- `nonce()` -> uint256 [view]
- `removeOwner(address prevOwner, address owner, uint256 _threshold)` ->  [nonpayable]
- `setFallbackHandler(address handler)` ->  [nonpayable]
- `setGuard(address guard)` ->  [nonpayable]
- `setup(address[] _owners, uint256 _threshold, address to, bytes data, address fallbackHandler, address paymentToken, uint256 payment, address paymentReceiver)` ->  [nonpayable]
- `signedMessages(bytes32)` -> uint256 [view]
- `simulateAndRevert(address targetContract, bytes calldataPayload)` ->  [nonpayable]
- `swapOwner(address prevOwner, address oldOwner, address newOwner)` ->  [nonpayable]

## Events

- `AddedOwner(address owner)`
- `ApproveHash(bytes32 approvedHash, address owner)`
- `ChangedFallbackHandler(address handler)`
- `ChangedGuard(address guard)`
- `ChangedThreshold(uint256 threshold)`
- `DisabledModule(address module)`
- `EnabledModule(address module)`
- `ExecutionFailure(bytes32 txHash, uint256 payment)`
- `ExecutionFromModuleFailure(address module)`
- `ExecutionFromModuleSuccess(address module)`
- `ExecutionSuccess(bytes32 txHash, uint256 payment)`
- `RemovedOwner(address owner)`
- `SafeModuleTransaction(address module, address to, uint256 value, bytes data, uint8 operation)`
- `SafeMultiSigTransaction(address to, uint256 value, bytes data, uint8 operation, uint256 safeTxGas, uint256 baseGas, uint256 gasPrice, address gasToken, address refundReceiver, bytes signatures, bytes additionalInfo)`
- `SafeReceived(address sender, uint256 value)`
- `SafeSetup(address initiator, address[] owners, uint256 threshold, address initializer, address fallbackHandler)`
- `SignMsg(bytes32 msgHash)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
