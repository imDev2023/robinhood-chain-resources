> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Create Fee Share Admin Transfer Transaction

> Creates a transaction to transfer fee share admin authority from the current admin to a new admin for a given token.



## OpenAPI

````yaml POST /fee-share/admin/transfer-tx
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
  /fee-share/admin/transfer-tx:
    post:
      tags:
        - Fee Share Admin
      summary: Create fee share admin transfer transaction
      description: >-
        Creates a transaction to transfer fee share admin authority from the
        current admin to a new admin for a given token.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/FeeShareAdminTransferTxRequest'
      responses:
        '200':
          description: Successfully created admin transfer transaction
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/TransactionWithBlockhash'
        '400':
          description: Bad request - Invalid parameters
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
    FeeShareAdminTransferTxRequest:
      type: object
      properties:
        baseMint:
          type: string
          description: Public key of the base mint
        currentAdmin:
          type: string
          description: Public key of the current fee share admin
        newAdmin:
          type: string
          description: Public key of the new fee share admin
        payer:
          type: string
          description: Public key of the payer wallet
      required:
        - baseMint
        - currentAdmin
        - newAdmin
        - payer
      additionalProperties: false
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