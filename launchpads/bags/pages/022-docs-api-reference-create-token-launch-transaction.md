# Bags - Create Token Launch Transaction

> Source: https://docs.bags.fm/api-reference/create-token-launch-transaction
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/create-token-launch-transaction.md)

---

# Create Token Launch Transaction

> Create a token launch transaction (already signed with token mint)



## OpenAPI

````yaml POST /token-launch/create-launch-transaction
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
  /token-launch/create-launch-transaction:
    post:
      tags:
        - Token Launch
      summary: Create token launch transaction
      description: Create a token launch transaction (already signed with token mint)
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                ipfs:
                  type: string
                  description: IPFS URL of the token metadata
                tokenMint:
                  type: string
                  description: Public key of the token mint
                wallet:
                  type: string
                  description: Public key of the wallet
                initialBuyLamports:
                  type: number
                  description: Initial buy amount in lamports
                configKey:
                  type: string
                  description: Config key from create-config endpoint
                tipWallet:
                  type: string
                  description: Base58 encoded Solana public key of the tip recipient wallet
                tipLamports:
                  type: number
                  description: Tip amount in lamports
              required:
                - ipfs
                - tokenMint
                - wallet
                - initialBuyLamports
                - configKey
      responses:
        '200':
          description: Successfully created token launch transaction
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        type: string
                        description: Base58 encoded serialized transaction
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
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````