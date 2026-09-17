# Bags - Create Swap Transaction

> Source: https://docs.bags.fm/api-reference/create-swap-transaction
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/create-swap-transaction.md)

---

# Create Swap Transaction

> Create a swap transaction from a trade quote. The transaction is ready to be signed and sent.



## OpenAPI

````yaml POST /trade/swap
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
  /trade/swap:
    post:
      tags:
        - Trade
      summary: Create swap transaction
      description: >-
        Create a swap transaction from a trade quote. The transaction is ready
        to be signed and sent.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/SwapTransactionRequest'
      responses:
        '200':
          description: Successfully created swap transaction
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/SwapTransactionResponse'
        '400':
          description: Bad request - Invalid quote or parameters
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
    SwapTransactionRequest:
      type: object
      properties:
        quoteResponse:
          $ref: '#/components/schemas/TradeQuoteResponse'
          description: The quote response from the getQuote endpoint
        userPublicKey:
          type: string
          description: Public key of the user's wallet
      required:
        - quoteResponse
        - userPublicKey
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
    SwapTransactionResponse:
      type: object
      properties:
        swapTransaction:
          type: string
          description: Base58 encoded serialized VersionedTransaction
        computeUnitLimit:
          type: number
          description: Compute unit limit for the transaction
        lastValidBlockHeight:
          type: number
          description: Last valid block height for the transaction
        prioritizationFeeLamports:
          type: number
          description: Prioritization fee in lamports
      required:
        - swapTransaction
        - computeUnitLimit
        - lastValidBlockHeight
        - prioritizationFeeLamports
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
    TradeQuoteResponse:
      type: object
      properties:
        requestId:
          type: string
          description: Unique identifier for the quote request
        contextSlot:
          type: number
          description: The slot at which the quote was generated
        inAmount:
          type: string
          description: Input amount
        inputMint:
          type: string
          description: Input token mint public key
        outAmount:
          type: string
          description: Expected output amount
        outputMint:
          type: string
          description: Output token mint public key
        minOutAmount:
          type: string
          description: Minimum output amount considering slippage
        otherAmountThreshold:
          type: string
          description: Other amount threshold for the swap
        priceImpactPct:
          type: string
          description: Price impact percentage
        slippageBps:
          type: number
          description: Slippage tolerance in basis points
        routePlan:
          type: array
          items:
            $ref: '#/components/schemas/RoutePlanLeg'
          description: Array of route legs showing the swap path
        platformFee:
          $ref: '#/components/schemas/PlatformFee'
          nullable: true
          description: Optional platform fee information
        outTransferFee:
          type: string
          nullable: true
          description: Output transfer fee if applicable
        simulatedComputeUnits:
          type: number
          nullable: true
          description: Simulated compute units for the swap transaction
      required:
        - requestId
        - contextSlot
        - inAmount
        - inputMint
        - outAmount
        - outputMint
        - minOutAmount
        - otherAmountThreshold
        - priceImpactPct
        - slippageBps
        - routePlan
    RoutePlanLeg:
      type: object
      properties:
        venue:
          type: string
          description: Name of the DEX or venue
        inAmount:
          type: string
          description: Input amount for this leg
        outAmount:
          type: string
          description: Output amount for this leg
        inputMint:
          type: string
          description: Input token mint for this leg
        outputMint:
          type: string
          description: Output token mint for this leg
        inputMintDecimals:
          type: number
          description: Decimals of the input token mint
        outputMintDecimals:
          type: number
          description: Decimals of the output token mint
        marketKey:
          type: string
          description: Market key for this leg
        data:
          type: string
          description: Additional data for this leg
      required:
        - venue
        - inAmount
        - outAmount
        - inputMint
        - outputMint
        - inputMintDecimals
        - outputMintDecimals
        - marketKey
        - data
    PlatformFee:
      type: object
      properties:
        amount:
          type: string
          description: Platform fee amount
        feeBps:
          type: number
          description: Platform fee in basis points
        feeAccount:
          type: string
          description: Public key of the fee account
        segmenterFeeAmount:
          type: string
          description: Segmenter fee amount
        segmenterFeePct:
          type: number
          description: Segmenter fee percentage
      required:
        - amount
        - feeBps
        - feeAccount
        - segmenterFeeAmount
        - segmenterFeePct
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````