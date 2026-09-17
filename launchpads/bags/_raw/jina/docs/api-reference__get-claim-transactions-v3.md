> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Claim Transactions (v3)

> Generate transactions to claim fees for a token. This simplified v3 endpoint automatically handles all fee claiming logic based on the token state.

The simplified v3 claim endpoint automatically handles all fee claiming logic. Just provide the fee claimer wallet and token mint — the API determines the position type and builds the appropriate transactions.

For a complete walkthrough, see the [Claim Fees guide](/how-to-guides/claim-fees).


## OpenAPI

````yaml POST /token-launch/claim-txs/v3
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
  /token-launch/claim-txs/v3:
    post:
      tags:
        - Fee Claiming
      summary: Get claim transactions (v3)
      description: >-
        Generate transactions to claim fees for a token. This simplified v3
        endpoint automatically handles all fee claiming logic based on the token
        state.
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
          description: Bad request - Missing required parameters or invalid wallet/token
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