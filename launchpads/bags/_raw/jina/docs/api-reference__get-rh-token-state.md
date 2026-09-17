> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Robinhood Token State

> Get live on-chain state for a Bags V2 token on Robinhood Chain (via the V2 lens), with no subgraph dependency. Returns `404` for non-V2 tokens.



## OpenAPI

````yaml GET /evm/rh/token-state
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
  /evm/rh/token-state:
    get:
      tags:
        - Robinhood Chain
      summary: Get token state
      description: >-
        Get live on-chain state for a Bags V2 token on Robinhood Chain (via the
        V2 lens), with no subgraph dependency. Returns `404` for non-V2 tokens.
      parameters:
        - name: tokenAddress
          in: query
          required: true
          schema:
            type: string
          description: >-
            Token address. Accepts any casing; normalized to EIP-55 checksum
            form.
      responses:
        '200':
          description: Successfully retrieved token state
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/RhTokenState'
        '400':
          description: Bad request - Invalid token address
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
        '404':
          description: Not found - The address is not a Bags V2 token
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/RhErrorResponse'
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
    RhTokenState:
      type: object
      properties:
        exists:
          type: boolean
          description: Whether the address is a Bags V2 token.
        migrated:
          type: boolean
          description: >-
            Whether the token has graduated from the bonding curve to its
            Uniswap V4 pool.
        curve:
          type: string
          description: Address of the token's bonding curve contract.
        feeShare:
          type: string
          description: Address of the token's fee-share contract.
        poolId:
          type: string
          description: Uniswap V4 pool ID (bytes32 hex string).
        thresholdQuoteWei:
          type: string
          description: ETH (wei) needed to graduate, as string to support bigint.
        realQuoteReservesWei:
          type: string
          description: >-
            Real ETH reserves currently held by the curve (wei), as string to
            support bigint.
        realTokenReservesWei:
          type: string
          description: Tokens left on the curve (base units), as string to support bigint.
        virtualTokenReservesWei:
          type: string
          description: >-
            Virtual token reserve used by the curve math (base units), as string
            to support bigint.
        virtualQuoteReservesWei:
          type: string
          description: >-
            Virtual ETH reserve used by the curve math (wei), as string to
            support bigint.
        priceEthPerToken:
          type: string
          nullable: true
          description: >-
            Live spot price as an 1e18 fixed-point decimal string (ETH per whole
            token). Null for migrated tokens when the pool read is unavailable —
            render as "unavailable", never 0.
        bondingProgressPct:
          type: number
          description: >-
            Bonding-curve graduation progress, 0-99 while bonding and 100 once
            migrated.
        totalRaisedWei:
          type: string
          description: >-
            Cumulative ETH raised into the curve over its lifetime (wei),
            measured against `thresholdQuoteWei`, as string to support bigint.
      required:
        - exists
        - migrated
        - curve
        - feeShare
        - poolId
        - thresholdQuoteWei
        - realQuoteReservesWei
        - realTokenReservesWei
        - virtualTokenReservesWei
        - virtualQuoteReservesWei
        - priceEthPerToken
        - bondingProgressPct
        - totalRaisedWei
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