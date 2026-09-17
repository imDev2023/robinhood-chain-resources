> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Fee Share Wallet V2 (Bulk)

> Bulk lookup of wallet addresses associated with social providers and usernames for fee sharing. Each item accepts an optional `chain` (`SOL` default, or `EVM`); the resolved `chain` is echoed back on every result. Deduplication is performed on `username + provider + chain`, so the same handle may appear once per chain. Items are never individually failed: when a wallet or platform data can't be resolved, that item returns `platformData: null` and `wallet: null` while still echoing `chain`.

## Choosing a chain per item

Each item accepts an optional `chain` field:

* **`SOL`** (default when omitted) — returns the user's Solana embedded wallet as a base58 address.
* **`EVM`** — resolves the user's Ethereum embedded wallet from Privy, creating one if the user has none, and returns a `0x…` address.

The resolved `chain` is always echoed back on every result item.

## Deduplication

Deduplication is performed on the `username + provider + chain` triple. The same `username + provider` may appear twice in one request as long as the `chain` differs (once for `SOL`, once for `EVM`). Two items with an identical `username + provider + chain` triple are rejected with a `400` error.

<Note>
  Bulk lookups never fail an individual item: when a wallet or platform data can't be resolved, that item comes back with `platformData: null` and `wallet: null`, but `chain` is always echoed back. The `solana` provider only supports `SOL`; combining it with `chain=EVM` returns a `400` error.
</Note>


## OpenAPI

````yaml POST /token-launch/fee-share/wallet/v2/bulk
openapi: 3.1.0
info:
  title: Bags Public API v2
  description: API endpoints for Bags platform
  version: 2.0.0
  contact:
    name: Bags Support
    url: https://support.bags.fm
servers:
  - url: https://public-api-v2.bags.fm/api/v1
    description: Production server
security:
  - ApiKeyAuth: []
tags:
  - name: Token Launch
    description: Endpoints for creating and managing token launches
  - name: Fee Share
    description: Endpoints for managing fee sharing configs
  - name: Fee Share Admin
    description: >-
      Endpoints for fee share admin operations including listing, transferring
      admin authority, and updating configs
  - name: Analytics
    description: Endpoints for retrieving token analytics and metadata
  - name: Fee Claiming
    description: Endpoints for claiming fees from various sources
  - name: State
    description: Endpoints for retrieving on-chain state and derived state
  - name: Trade
    description: Endpoints for getting trade quotes and executing token swaps
  - name: Partner
    description: Endpoints for managing partner configurations and claiming partner fees
  - name: Solana
    description: Endpoints for direct Solana blockchain interactions
  - name: EVM
    description: Endpoints for reading Bags EVM token data
  - name: Robinhood Chain
    description: Read endpoints for Bags V2 tokens on Robinhood Chain (chain id 4663)
  - name: Dexscreener
    description: >-
      Endpoints for managing Dexscreener token info orders, payments, and image
      uploads
  - name: Auth
    description: Endpoints for retrieving authenticated user information
  - name: Agent
    description: Endpoints for AI agent wallet-signature authentication (V2)
paths:
  /token-launch/fee-share/wallet/v2/bulk:
    post:
      tags:
        - Fee Share
      summary: Get fee share wallets (bulk, v2)
      description: >-
        Bulk lookup of wallet addresses associated with social providers and
        usernames for fee sharing. Each item accepts an optional `chain` (`SOL`
        default, or `EVM`); the resolved `chain` is echoed back on every result.
        Deduplication is performed on `username + provider + chain`, so the same
        handle may appear once per chain. Items are never individually failed:
        when a wallet or platform data can't be resolved, that item returns
        `platformData: null` and `wallet: null` while still echoing `chain`.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/GetFeeShareWalletV2BulkRequest'
      responses:
        '200':
          description: Successfully retrieved wallet addresses for all requested items
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/GetFeeShareWalletV2BulkSuccessResponse'
        '400':
          description: >-
            Bad request - Invalid parameters, duplicate username + provider +
            chain combinations, or the solana provider combined with the EVM
            chain
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/GetFeeShareWalletV2ErrorResponse'
        '401':
          description: Unauthorized - Invalid or missing API key
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
        '500':
          description: Internal server error
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/GetFeeShareWalletV2ErrorResponse'
      security:
        - ApiKeyAuth: []
components:
  schemas:
    GetFeeShareWalletV2BulkRequest:
      type: object
      properties:
        items:
          type: array
          minItems: 1
          maxItems: 100
          items:
            type: object
            properties:
              username:
                type: string
                minLength: 1
                maxLength: 100
                description: >-
                  Username/handle on the provider platform. Input is normalized
                  to lowercase; leading @ is removed if present.
              provider:
                $ref: '#/components/schemas/SocialProvider'
              chain:
                $ref: '#/components/schemas/FeeShareWalletChain'
            required:
              - username
              - provider
            additionalProperties: false
          description: >-
            Array of lookups (1-100). Duplicate username+provider+chain
            combinations are not allowed. The same username+provider may appear
            once per chain (once for SOL, once for EVM).
      required:
        - items
      additionalProperties: false
    GetFeeShareWalletV2BulkSuccessResponse:
      type: object
      properties:
        success:
          type: boolean
          enum:
            - true
        response:
          type: array
          items:
            $ref: '#/components/schemas/GetFeeShareWalletV2BulkResultItem'
          description: Per-item results matching the input order
      required:
        - success
        - response
    GetFeeShareWalletV2ErrorResponse:
      type: object
      properties:
        success:
          type: boolean
          example: false
          enum:
            - false
        response:
          type: string
          description: Error message
      required:
        - success
        - response
    ErrorResponse:
      type: object
      properties:
        success:
          type: boolean
          example: false
        error:
          type: string
          description: Error message
      required:
        - success
        - error
    SocialProvider:
      type: string
      enum:
        - apple
        - google
        - email
        - solana
        - twitter
        - tiktok
        - kick
        - instagram
        - onlyfans
        - github
        - moltbook
      example: twitter
      description: Supported social/auth providers
    FeeShareWalletChain:
      type: string
      enum:
        - SOL
        - EVM
      default: SOL
      description: >-
        Blockchain to resolve the wallet on. `SOL` returns the user's Solana
        embedded wallet (base58). `EVM` returns the user's Ethereum embedded
        wallet from Privy (`0x…`). Defaults to `SOL` when omitted. The `solana`
        provider only supports `SOL`.
    GetFeeShareWalletV2BulkResultItem:
      type: object
      properties:
        username:
          type: string
          description: >-
            Username/handle on the provider platform (normalized to lowercase;
            leading @ removed if provided)
        provider:
          $ref: '#/components/schemas/SocialProvider'
        platformData:
          $ref: '#/components/schemas/SocialProviderUserData'
        wallet:
          type: string
          nullable: true
          description: >-
            Address of the resolved wallet, or null if not found. Format depends
            on `chain`: base58 for `SOL`, `0x…` for `EVM`.
        chain:
          $ref: '#/components/schemas/FeeShareWalletChain'
      required:
        - username
        - provider
        - platformData
        - wallet
        - chain
      additionalProperties: false
    SocialProviderUserData:
      type: object
      description: Generic user data structure that works across different OAuth providers
      properties:
        id:
          type: string
          description: Unique identifier of the user on the provider platform
        username:
          type: string
          description: Username/handle on the provider platform
        display_name:
          type: string
          description: Display name of the user on the provider platform
        avatar_url:
          type: string
          description: Profile picture URL of the user on the provider platform
      additionalProperties: true
      required:
        - id
        - username
        - display_name
        - avatar_url
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````