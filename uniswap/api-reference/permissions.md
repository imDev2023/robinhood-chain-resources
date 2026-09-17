<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Check token KYC permissions

`POST https://trade-api.gateway.uniswap.org/v1/permissions`  
operationId: `permissions` · tags: utilities

For each token in the request, reports whether the token requires a permissioned adapter and whether the supplied `walletAddress` is allowlisted to trade it. If the token is permissioned but the wallet is not allowlisted, the response includes a `kycUrl` the wallet holder must complete to gain access. The request supports a maximum of 2 tokens.

## Request body (application/json)

- `walletAddress` (required): string. The wallet address which will be used to send the token
- `tokens` (required): array. Tokens to check permissions for. Maximum of 2 per request
  - items:
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)

Example:

```json
{
  "walletAddress": "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421",
  "tokens": [
    "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599"
  ],
  "chainId": 1
}
```

## Responses

### 200: Token permissions lookup successful.

- `requestId` (required): string. A unique ID for the request
- `results` (required): array
  - items:
    - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `isPermissioned` (required): boolean. Whether the token requires a permissioned adapter to trade
    - `isAllowlisted`: boolean. Only provided when isPermissioned is true. Indicates whether the wallet is allowed to swap this token
    - `adapterTokenAddress`: string. Address of the permissioned adapter token to use in place of the underlying token. Always provided when isPermissioned is true
    - `kycUrl`: string. URL the wallet holder must visit to complete KYC and become allowlisted. Always provided when isAllowlisted is false
    - `issuer`: string. KYC provider display name (e.g. "Superstate"). Always provided when isPermissioned is true

Example:

```json
{
  "requestId": "e63f1e1e-b9e9-411a-bcc8-ff18ce4e77cf",
  "results": [
    {
      "token": "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
      "isPermissioned": false
    }
  ]
}
```

### 400: RequestValidationError, Bad Input

- `errorCode`: string
- `detail`: string

### 401: UnauthorizedError eg. Account is blocked.

- `errorCode`: string
- `detail`: string

### 404: ResourceNotFound eg. Failed to fetch token permissions.

- `errorCode`: string = `ResourceNotFound`, `QuoteAmountTooLowError`, `TokenBalanceNotAvailable`, `InsufficientBalance`
- `detail`: string

### 500: Unexpected error

- `errorCode`: string
- `detail`: string

### 504: Request duration limit reached.

- `errorCode`: string
- `detail`: string

