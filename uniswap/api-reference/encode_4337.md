<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Encode ERC-4337 UserOperation

`POST https://trade-api.gateway.uniswap.org/v1/wallet/encode_4337`  
operationId: `encode_4337` · tags: utilities

Builds and returns a fully-populated ERC-4337 v0.8 UserOperation for the given batch of calls. When a `paymasterUrl` is provided the endpoint attempts gas sponsorship via the paymaster; the response indicates whether sponsorship was granted and includes sponsor metadata when available.

## Request body (application/json)

- `calls` (required): array. Batch of transactions to encode into the UserOperation
  - items:
    - `to` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `data` (required): string. The calldata for the transaction
    - `value` (required): string. The quantity of ETH tokens approved for spending by the transaction, denominated in wei. Note that by default Uniswap Labs sets this to the maximum approvable spend
    - `gasLimit`: string. The maximum units of gas that will be consumed by this transaction
    - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
    - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
    - `gasPrice`: string. The cost per unit of gas
- `sender` (required): string
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `paymasterUrl`: string. JSON-RPC URL of a paymaster service for gas sponsorship
- `paymasterServiceContext`: object. Opaque context forwarded to the paymaster (e.g. `{ "policyId": "..." }`)
- `eip7702Auth`: object. Signed EIP-7702 authorization tuple
  - `address` (required): string. Contract address to delegate to
  - `chainId` (required): string. Hex-encoded chain ID
  - `nonce` (required): string. Hex-encoded nonce
  - `r` (required): string. ECDSA r value
  - `s` (required): string. ECDSA s value
  - `yParity` (required): string. ECDSA y parity

## Responses

### 200: UserOperation encoded successfully.

- `requestId` (required): string. Unique identifier for this request
- `userOperation` (required): object. ERC-4337 v0.8 UserOperation
  - `sender` (required): string. Smart account address that will execute the operation
  - `nonce` (required): string. Anti-replay nonce from the EntryPoint
  - `callData` (required): string. ABI-encoded call data for the batch execution
  - `callGasLimit` (required): string. Gas limit for the main execution call
  - `verificationGasLimit` (required): string. Gas limit for the verification step
  - `preVerificationGas` (required): string. Gas to cover bundler overhead and L1 data costs
  - `maxFeePerGas` (required): string. EIP-1559 max fee per gas
  - `maxPriorityFeePerGas` (required): string. EIP-1559 max priority fee per gas
  - `factory`: string. Account factory address (present for first-time account deployment)
  - `factoryData`: string. Calldata for the account factory
  - `paymaster`: string. Paymaster contract address (present when gas is sponsored)
  - `paymasterVerificationGasLimit`: string. Gas limit for paymaster verification
  - `paymasterPostOpGasLimit`: string. Gas limit for paymaster post-operation
  - `paymasterData`: string. Paymaster-specific data
  - `signature` (required): string. Dummy signature placeholder; the client signs the UserOperation after receiving this response
  - `eip7702Auth`: object. Signed EIP-7702 authorization tuple
    - `address` (required): string. Contract address to delegate to
    - `chainId` (required): string. Hex-encoded chain ID
    - `nonce` (required): string. Hex-encoded nonce
    - `r` (required): string. ECDSA r value
    - `s` (required): string. ECDSA s value
    - `yParity` (required): string. ECDSA y parity
- `sponsorMetadata`: object. Display information about the sponsor covering gas fees for the swap
  - `name`: string. Display name of the sponsor
  - `icon`: string. URL of the sponsor's icon
- `gasSponsored` (required): boolean. Whether gas for this operation is sponsored by a paymaster
- `gasSponsorshipRejectionReason`: string. Reason gas sponsorship was not granted. Present only when `gasSponsored` is `false`

### 400: RequestValidationError, Bad Input

- `errorCode`: string
- `detail`: string

### 401: UnauthorizedError eg. Account is blocked.

- `errorCode`: string
- `detail`: string

### 429: Ratelimited

- `errorCode`: string
- `detail`: string

### 500: Unexpected error

- `errorCode`: string
- `detail`: string

### 504: Request duration limit reached.

- `errorCode`: string
- `detail`: string

