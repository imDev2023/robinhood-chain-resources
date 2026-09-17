> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Create Dexscreener Order

> Create a Dexscreener token info order. Returns a payment transaction that must be signed and submitted.



## OpenAPI

````yaml POST /solana/dexscreener/create-order
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
  /solana/dexscreener/create-order:
    post:
      tags:
        - Dexscreener
      summary: Create Dexscreener order
      description: >-
        Create a Dexscreener token info order. Returns a payment transaction
        that must be signed and submitted.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateDexscreenerOrderRequest'
      responses:
        '200':
          description: Successfully created Dexscreener order
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/CreateDexscreenerOrderResponse'
        '400':
          description: Bad request - Invalid parameters or validation errors
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
    CreateDexscreenerOrderRequest:
      type: object
      properties:
        tokenAddress:
          type: string
          description: Solana public key of the token
        description:
          type: string
          minLength: 1
          maxLength: 1000
          description: Token description for the Dexscreener listing
        iconImageUrl:
          type: string
          format: uri
          description: URL of the icon image
        headerImageUrl:
          type: string
          format: uri
          description: URL of the header image
        payerWallet:
          type: string
          description: Solana public key of the payer wallet
        links:
          type: array
          items:
            $ref: '#/components/schemas/DexscreenerLink'
          description: Optional array of links to display on the listing
        payWithSol:
          type: boolean
          default: false
          description: Whether to pay with SOL instead of USDC
      required:
        - tokenAddress
        - description
        - iconImageUrl
        - headerImageUrl
        - payerWallet
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
    CreateDexscreenerOrderResponse:
      type: object
      properties:
        orderUUID:
          type: string
          description: Unique identifier for the created order
        recipientWallet:
          type: string
          description: Solana public key of the treasury wallet to send payment to
        priceUSDC:
          type: number
          description: Price of the order in USDC
        transaction:
          type: string
          description: Base58 encoded serialized payment transaction
        lastValidBlockHeight:
          type: number
          description: Last valid block height for the transaction
      required:
        - orderUUID
        - recipientWallet
        - priceUSDC
        - transaction
        - lastValidBlockHeight
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
    DexscreenerLink:
      type: object
      properties:
        url:
          type: string
          format: uri
          description: URL of the link
        label:
          type: string
          maxLength: 100
          description: Optional display label for the link
      required:
        - url
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````