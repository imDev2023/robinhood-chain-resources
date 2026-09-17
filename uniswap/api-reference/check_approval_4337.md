<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Create approval ERC-4337 UserOperation

`POST https://trade-api.gateway.uniswap.org/v1/check_approval_4337`  
operationId: `check_approval_4337` · tags: swapping

Builds and returns an ERC-4337 v0.8 UserOperation that performs the ERC-20 approval (and any required allowance reset) needed before a swap. Paymaster fields and `signature` are left for the client to populate. When `sponsorshipInfo.sponsored` is `true`, the approval is tagged for sponsorship and a `paymasterServiceContext` envelope is returned for the client to forward to the paymaster.

## Request body (application/json)

- `sender` (required): string
- `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `urgency`: object. The urgency impacts the estimated gas price of the transaction. The higher the urgency, the higher the gas price, and the faster the transaction is likely to be selected from the mempool. Send the bare string form (e.g. `"normal"`) for the common case, or the object form `{ level, overrides }` to supply caller caps for `maxPriorityFeePerGas`, `maxFeePerGas`, and `gasLimit`
  - oneOf: `` string
    - enum: `normal`, `fast`, `urgent`
  - oneOf: `` object
    - `level` (required): string = `normal`, `fast`, `urgent`
    - `overrides`: object. Caller-supplied caps applied on top of the gas service's computed quote. All fields are absolute wei (decimal string). `maxPriorityFeePerGas` and `maxFeePerGas` are treated as caps - they lower the quote, never raise it. `gasLimit`, if set, replaces the limit calculation entirely
      - `maxPriorityFeePerGas`: string. Maximum priority fee in wei (decimal string)
      - `maxFeePerGas`: string. Maximum total fee per gas in wei (decimal string)
      - `gasLimit`: string. Gas limit cap (in gas units, decimal string)
- `tokenOut`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenOutChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `walletExecutionContext`: object. Wallet execution context based on CAIP-25 Standard. Provides information about wallet capabilities and scopes
  - `scopes` (required): object. Map of scope identifiers to their scope data
  - `properties`: object. Properties describing the wallet
    - `walletInfo`: object. Information about the wallet
      - `uuid`: string. Unique identifier for the wallet
      - `name`: string. Name of the wallet
      - `rdns`: string. Reverse domain name identifier for the wallet
- `eip7702Auth`: object. Signed EIP-7702 authorization tuple
  - `address` (required): string. Contract address to delegate to
  - `chainId` (required): string. Hex-encoded chain ID
  - `nonce` (required): string. Hex-encoded nonce
  - `r` (required): string. ECDSA r value
  - `s` (required): string. ECDSA s value
  - `yParity` (required): string. ECDSA y parity
- `sponsorshipInfo`: object. Gas sponsorship information for the quoted swap. When `sponsored` is `true`, gas fees for executing this swap will be covered by the sponsor described in `sponsorMetadata`, under the campaign described in `campaign`. When `sponsored` is `false`, `rejectionReason` describes why sponsorship was not granted
  - `sponsored`: boolean. Whether gas for this swap is sponsored
  - `rejectionReason`: string. Reason gas sponsorship was not granted. Present only when `sponsored` is `false`
  - `campaign`: object. Display information about the sponsorship campaign covering gas fees for the swap
    - `name`: string. Machine-readable campaign identifier
    - `description`: string. Subheader text for the campaign
    - `headline`: string. Human-readable headline for the campaign
    - `thumbnailUrl`: string. URL of the campaign's thumbnail image
    - `allowances`: array. Per-wallet caps and utilization, one entry per dimension (free-swap count and/or cost)
      - items:
        - `unit`: string = `FREE_SWAPS`, `USD_CENT`. Unit the allowance is denominated in
        - `total`: string. Total per-wallet allowance
        - `remaining`: string. Allowance still available to this wallet
    - `eligibleChains`: array. Chain IDs the campaign covers, for the eligible-chains modal
      - items:
  - `sponsorMetadata`: object. Display information about the sponsor covering gas fees for the swap
    - `name`: string. Display name of the sponsor
    - `icon`: string. URL of the sponsor's icon

## Responses

### 200: UserOperation encoded successfully.

- `requestId` (required): string. A unique ID for the request
- `userOperation`: object. ERC-4337 v0.8 UserOperation
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
- `gasSponsored` (required): boolean. Whether gas for this approval will be sponsored
- `gasSponsorshipRejectionReason`: string. Reason gas sponsorship was not granted. Present only when `gasSponsored` is `false`
- `paymasterServiceContext`: object. EIP-7677 paymasterService.context bundle. The wallet forwards this verbatim to the paymaster RPC (or — for ERC-4337 — to /wallet/encode_4337). `sponsorship` is opaque AES-256-GCM ciphertext whose integrity is enforced cryptographically on the uniRPC side
  - `sponsorship` (required): string

### 400: RequestValidationError, Bad Input

- `errorCode`: string
- `detail`: string

### 401: UnauthorizedError eg. Account is blocked or  Fee is not enabled.

- `errorCode`: string
- `detail`: string

### 404: ResourceNotFound eg. No quotes available or Gas fee/price not available

- `errorCode`: string = `ResourceNotFound`, `QuoteAmountTooLowError`, `TokenBalanceNotAvailable`, `InsufficientBalance`
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

