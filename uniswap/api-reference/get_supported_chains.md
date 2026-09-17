<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Get supported chains

`GET https://trade-api.gateway.uniswap.org/v1/supported_chains`  
operationId: `get_supported_chains` · tags: utilities

Returns the list of chains supported by the Trading API, including protocol contract addresses and the protocols and actions available on each chain.

## Responses

### 200: Get supported chains successful.

- `requestId` (required): string. A unique ID for the request
- `chains` (required): array
  - items:
    - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `chainName` (required): string
    - `contractAddresses` (required): array
      - items:
        - `name` (required): string
        - `version`: string. Only present where it distinguishes deployments: contract release lines (e.g. UniversalRouter 2.0/2.1.1/2.2.0, CaliburEntry tags) and same-named contracts (Quoter V3 vs V4)
        - `address` (required): string
    - `protocols` (required): array
      - items:
        - enum: `V2`, `V3`, `V4`, `UniswapX`
    - `actions` (required): array
      - items:
        - enum: `SWAP`, `LP`

Example:

```json
{
  "requestId": "cL_1ih66iYcEJ2g=",
  "chains": [
    {
      "chainId": 1,
      "chainName": "Ethereum",
      "contractAddresses": [
        {
          "name": "UniswapV2Factory",
          "address": "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f"
        },
        {
          "name": "UniswapV3Factory",
          "address": "0x1F98431c8aD98523631AE4a59f267346ea31F984"
        },
        {
          "name": "Quoter",
          "version": "V3",
          "address": "0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6"
        },
        {
          "name": "PoolManager",
          "address": "0x000000000004444c5dc75cB358380D2e3dE08A90"
        },
        {
          "name": "UniversalRouter",
          "version": "2.0",
          "address": "0x66a9893cc07d91d95644aedd05d03f95e1dba8af"
        }
      ],
      "protocols": [
        "V2",
        "V3",
        "V4",
        "UniswapX"
      ],
      "actions": [
        "SWAP",
        "LP"
      ]
    }
  ]
}
```

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

