> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Create Fee Share Config creation transaction

> Create a fee sharing config with multiple fee claimers (up to 100). Token Launches require fee sharing configuration for all token launches. All fees must be explicitly allocated using basis points. When there are more than 15 fee claimers, lookup tables are required.



## OpenAPI

````yaml POST /fee-share/config
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
  /fee-share/config:
    post:
      tags:
        - Fee Share
      summary: Create Fee Share Config creation transaction (v2)
      description: >-
        Create a fee sharing config with multiple fee claimers (up to 100).
        Token Launches require fee sharing configuration for all token launches.
        All fees must be explicitly allocated using basis points. When there are
        more than 15 fee claimers, lookup tables are required.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                payer:
                  type: string
                  description: Public key of the payer wallet
                baseMint:
                  type: string
                  description: Public key of the base mint (the token being launched)
                claimersArray:
                  type: array
                  items:
                    type: string
                    description: Public key of a fee claimer wallet
                  description: >-
                    Array of fee claimer wallet public keys. Must align with
                    basisPointsArray. Maximum 100 fee claimers.
                  minItems: 1
                  maxItems: 100
                basisPointsArray:
                  type: array
                  items:
                    type: number
                    description: Basis points allocated to the corresponding claimer
                  description: >-
                    Array of basis points for each fee claimer. Must align with
                    claimersArray. Total must equal 10,000.
                  minItems: 1
                  maxItems: 100
                partner:
                  type: string
                  description: >-
                    Optional: Public key of the partner wallet for partner fee
                    sharing
                  nullable: true
                partnerConfig:
                  type: string
                  description: >-
                    Optional: Public key of the partner config PDA (required if
                    partner is provided)
                  nullable: true
                additionalLookupTables:
                  type: array
                  items:
                    type: string
                    description: Public key of a lookup table address
                  description: >-
                    Optional: Array of lookup table addresses. Required when
                    there are more than 7 fee claimers.
                  nullable: true
                bagsConfigType:
                  $ref: '#/components/schemas/MeteoraConfigType'
                  nullable: true
                enableFirstSwapWithMinFee:
                  type: boolean
                  default: true
                  nullable: true
                  description: >-
                    Optional (default true). When true, the first swap on the
                    new pool pays the minimum (ending) base fee instead of the
                    starting cliff fee. This only affects config types that use
                    a base-fee scheduler (one whose base fee changes over time).
                    No current config type uses a base-fee scheduler, so this
                    field currently has no effect and is safe to omit; it is
                    retained for forward compatibility.
                tipWallet:
                  type: string
                  description: Base58 encoded Solana public key of the tip recipient wallet
                  nullable: true
                tipLamports:
                  type: number
                  description: Tip amount in lamports
                  nullable: true
              required:
                - payer
                - baseMint
                - claimersArray
                - basisPointsArray
      responses:
        '200':
          description: Successfully created fee share config
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/FeeShareConfigV2Response'
        '400':
          description: >-
            Bad request - Invalid parameters, wallets, BPS values (must sum to
            10,000), or too many fee claimers
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
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
                $ref: '#/components/schemas/ErrorResponse'
      security:
        - ApiKeyAuth: []
components:
  schemas:
    MeteoraConfigType:
      type: string
      enum:
        - fa29606e-5e48-4c37-827f-4b03d58ee23d
        - d16d3585-6488-4a6c-9a6f-e6c39ca0fda3
        - a7c8e1f2-3d4b-5a6c-9e0f-1b2c3d4e5f6a
        - 48e26d2f-0a9d-4625-a3cc-c3987d874b9e
        - 810faadb-030b-47de-a68b-7211c1cbbee3
        - e2963a6c-441a-4862-9d80-b94e3a481cd7
        - ba28db46-ea6f-4452-8218-5587f6aca0a1
      default: fa29606e-5e48-4c37-827f-4b03d58ee23d
      description: >-
        Bags config type that determines the token's fee structure.


        - `fa29606e-5e48-4c37-827f-4b03d58ee23d` (Default): 2% fees both pre and
        post migration, with 25% fee compounding post-migration. Graduates at
        ~85 SOL.

        - `d16d3585-6488-4a6c-9a6f-e6c39ca0fda3`: 0.25% fees pre-migration, 1%
        post-migration, with 50% fee compounding post-migration. Graduates at
        ~85 SOL.

        - `a7c8e1f2-3d4b-5a6c-9e0f-1b2c3d4e5f6a`: 1% fees pre-migration, 0.25%
        post-migration, with 50% fee compounding post-migration. Graduates at
        ~85 SOL.

        - `48e26d2f-0a9d-4625-a3cc-c3987d874b9e`: 10% fees both pre and post
        migration, with 50% fee compounding post-migration. Graduates at ~85
        SOL.

        - `810faadb-030b-47de-a68b-7211c1cbbee3` (2% Flat, 85% Locked): 2% fees
        both pre and post migration, with 25% fee compounding post-migration.
        85% of token supply is locked. Graduates at ~100 SOL.

        - `e2963a6c-441a-4862-9d80-b94e3a481cd7` (Default, 1K Supply): Same as
        Default (2% fees pre and post migration, 25% fee compounding
        post-migration) but with a 1,000 token supply. Graduates at ~85 SOL.

        - `ba28db46-ea6f-4452-8218-5587f6aca0a1` (2% Base, 96% Locked): 2% base
        fee pre-migration, with 25% fee compounding post-migration. 96% of token
        supply is locked. Post-migration the fee is market-cap based, starting
        at 2% and decaying to a 0.5% floor as the token's market cap grows (~25x
        graduation market cap). Graduates at ~55 SOL.
    SuccessResponse:
      type: object
      properties:
        success:
          type: boolean
          example: true
        response:
          description: ''
      required:
        - success
    FeeShareConfigV2Response:
      type: object
      properties:
        needsCreation:
          type: boolean
          description: >-
            Whether the config needs to be created (true) or already exists
            (false)
        feeShareAuthority:
          type: string
          description: Public key of the fee share authority
        meteoraConfigKey:
          type: string
          description: Public key of the Meteora config key
        transactions:
          type: array
          items:
            $ref: '#/components/schemas/TransactionWithBlockhash'
          description: Array of transactions with blockhash to be signed and sent in order
          nullable: true
        bundles:
          type: array
          items:
            type: array
            items:
              $ref: '#/components/schemas/TransactionWithBlockhash'
          description: >-
            Optional array of transaction bundles (arrays of transactions that
            should be sent together)
          nullable: true
      required:
        - needsCreation
        - feeShareAuthority
        - meteoraConfigKey
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
    TransactionWithBlockhash:
      type: object
      properties:
        blockhash:
          $ref: '#/components/schemas/BlockhashWithExpiryBlockHeight'
        transaction:
          type: string
          description: Base58 encoded serialized versioned transaction
      required:
        - blockhash
        - transaction
    BlockhashWithExpiryBlockHeight:
      type: object
      properties:
        blockhash:
          type: string
          description: Recent blockhash for the transaction
        lastValidBlockHeight:
          type: number
          description: The last block height for which the blockhash is valid
      required:
        - blockhash
        - lastValidBlockHeight
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````