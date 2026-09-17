> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Claim Transactions

> Generate transactions to claim fees from virtual pools and/or DAMM v2 positions or custom fee vaults. Supports both v1 and v2 fee share programs.



## OpenAPI

````yaml POST /token-launch/claim-txs/v2
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
  /token-launch/claim-txs/v2:
    post:
      tags:
        - Fee Claiming
      summary: Get claim transactions (v2)
      description: >-
        Generate transactions to claim fees from virtual pools and/or DAMM v2
        positions or custom fee vaults. Supports both v1 and v2 fee share
        programs.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                feeClaimer:
                  type: string
                  description: Public key of the fee claimer wallet
                tokenMint:
                  type: string
                  description: Token mint public key
                virtualPoolAddress:
                  type: string
                  description: >-
                    Virtual pool address (required if claimVirtualPoolFees is
                    true)
                  nullable: true
                dammV2Position:
                  type: string
                  description: DAMM v2 position public key
                  nullable: true
                dammV2Pool:
                  type: string
                  description: DAMM v2 pool public key
                  nullable: true
                dammV2PositionNftAccount:
                  type: string
                  description: DAMM v2 position NFT account public key
                  nullable: true
                tokenAMint:
                  type: string
                  description: Token A mint public key
                  nullable: true
                tokenBMint:
                  type: string
                  description: Token B mint public key
                  nullable: true
                tokenAVault:
                  type: string
                  description: Token A vault public key
                  nullable: true
                tokenBVault:
                  type: string
                  description: Token B vault public key
                  nullable: true
                claimVirtualPoolFees:
                  type: boolean
                  description: Whether to claim virtual pool fees
                  nullable: true
                claimDammV2Fees:
                  type: boolean
                  description: Whether to claim DAMM v2 fees
                  nullable: true
                isCustomFeeVault:
                  type: boolean
                  description: >-
                    Whether using a custom fee vault (true for fee share v1 or
                    v2 programs)
                  nullable: true
                feeShareProgramId:
                  type: string
                  description: >-
                    Program ID of the fee share program being used. Required
                    when isCustomFeeVault is true.
                  nullable: true
                customFeeVaultClaimerA:
                  type: string
                  description: Custom fee vault claimer A public key (for v1 fee share)
                  nullable: true
                customFeeVaultClaimerB:
                  type: string
                  description: Custom fee vault claimer B public key (for v1 fee share)
                  nullable: true
                customFeeVaultClaimerSide:
                  type: string
                  enum:
                    - A
                    - B
                  description: >-
                    Which side of the custom fee vault to claim for (for v1 fee
                    share)
                  nullable: true
              required:
                - feeClaimer
                - tokenMint
      responses:
        '200':
          description: Successfully generated claim transactions
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        type: array
                        items:
                          $ref: '#/components/schemas/ClaimTransactionResult'
        '400':
          description: Bad request - Missing required parameters or invalid claimer side
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
    ClaimTransactionResult:
      type: object
      properties:
        tx:
          type: string
          description: Base58 encoded serialized transaction
        blockhash:
          $ref: '#/components/schemas/BlockhashWithExpiryBlockHeight'
      required:
        - tx
        - blockhash
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