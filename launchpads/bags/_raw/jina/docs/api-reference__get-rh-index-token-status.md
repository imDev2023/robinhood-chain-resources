> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Index Token Statuses

> Batch-check whether tokens on Robinhood Chain are index tokens. Returns one entry per unique input address with the index-token flag and, when applicable, the basket token addresses the index token buys and distributes.



## OpenAPI

````yaml POST /evm/rh/index-token/status
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
  /evm/rh/index-token/status:
    post:
      tags:
        - Robinhood Chain
      summary: Get index token statuses
      description: >-
        Batch-check whether tokens on Robinhood Chain are index tokens. Returns
        one entry per unique input address with the index-token flag and, when
        applicable, the basket token addresses the index token buys and
        distributes.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                tokenAddresses:
                  type: array
                  items:
                    type: string
                  minItems: 1
                  maxItems: 100
                  description: >-
                    Token addresses to check (1-100). Accepts any casing;
                    normalized to EIP-55 checksum form. Duplicates are deduped.
              required:
                - tokenAddresses
      responses:
        '200':
          description: Successfully retrieved index token statuses
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
                          $ref: '#/components/schemas/RhIndexTokenStatus'
        '400':
          description: Bad request - Invalid token addresses
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/RhErrorResponse'
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
                $ref: '#/components/schemas/RhErrorResponse'
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
    RhIndexTokenStatus:
      type: object
      properties:
        tokenAddress:
          type: string
          description: Token address in EIP-55 checksum form.
        isIndexToken:
          type: boolean
          description: True when the token has been initialized as an index token.
        tokens:
          type: array
          items:
            type: string
          description: >-
            Basket token addresses the index token buys and distributes. Empty
            when `isIndexToken` is false.
      required:
        - tokenAddress
        - isIndexToken
        - tokens
    RhErrorResponse:
      type: object
      properties:
        success:
          type: boolean
          example: false
        response:
          type: string
          description: Error message describing why the request failed.
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
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````