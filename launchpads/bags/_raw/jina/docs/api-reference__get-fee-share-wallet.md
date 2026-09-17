> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Fee Share Wallet V2

> Get the wallet address associated with a social provider and username for fee sharing. The optional `chain` parameter selects which chain to resolve the wallet on: `SOL` (default) returns the user's Solana embedded wallet, while `EVM` resolves (and creates if needed) the user's Ethereum embedded wallet from Privy. The resolved `chain` is always echoed back in the response.

## Choosing a chain

The optional `chain` parameter selects which embedded wallet to resolve:

* **`SOL`** (default when omitted) — returns the user's Solana embedded wallet as a base58 address.
* **`EVM`** — resolves the user's Ethereum embedded wallet from Privy, creating one if the user has none, and returns a `0x…` address.

The resolved `chain` is always echoed back in the response, defaulting to `SOL` when the parameter was omitted.

<Note>
  The `solana` provider is a raw wallet-address passthrough (the `username` is the Solana public key) and only supports `SOL`. Combining `provider=solana` with `chain=EVM` returns a `400` error.
</Note>


## OpenAPI

````yaml GET /token-launch/fee-share/wallet/v2
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
  /token-launch/fee-share/wallet/v2:
    get:
      tags:
        - Fee Share
      summary: Get fee share wallet (v2)
      description: >-
        Get the wallet address associated with a social provider and username
        for fee sharing. The optional `chain` parameter selects which chain to
        resolve the wallet on: `SOL` (default) returns the user's Solana
        embedded wallet, while `EVM` resolves (and creates if needed) the user's
        Ethereum embedded wallet from Privy. The resolved `chain` is always
        echoed back in the response.
      parameters:
        - name: provider
          in: query
          required: true
          schema:
            $ref: '#/components/schemas/SocialProvider'
          description: Social provider (e.g., twitter, instagram, github)
        - name: username
          in: query
          required: true
          schema:
            type: string
            minLength: 1
            maxLength: 100
          description: Username/handle on the provider platform
        - name: chain
          in: query
          required: false
          schema:
            $ref: '#/components/schemas/FeeShareWalletChain'
          description: >-
            Blockchain to resolve the wallet on (SOL or EVM). Defaults to SOL.
            The `solana` provider only supports SOL.
      responses:
        '200':
          description: Successfully retrieved wallet address
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/GetFeeShareWalletV2SuccessResponse'
        '400':
          description: >-
            Bad request - Invalid parameters (e.g. the solana provider does not
            support the EVM chain)
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
        '404':
          description: Not found - Platform data or wallet not found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/GetFeeShareWalletV2ErrorResponse'
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
    GetFeeShareWalletV2SuccessResponse:
      type: object
      properties:
        success:
          type: boolean
          enum:
            - true
        response:
          type: object
          properties:
            provider:
              $ref: '#/components/schemas/SocialProvider'
            platformData:
              $ref: '#/components/schemas/SocialProviderUserData'
            wallet:
              type: string
              description: >-
                Address of the resolved wallet. Format depends on `chain`:
                base58 for `SOL`, `0x…` for `EVM`.
            chain:
              $ref: '#/components/schemas/FeeShareWalletChain'
          required:
            - provider
            - platformData
            - wallet
            - chain
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