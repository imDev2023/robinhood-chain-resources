# Bags - Get Robinhood Balances

> Source: https://docs.bags.fm/api-reference/get-rh-balances
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/get-rh-balances.md)

---

# Get Robinhood Balances

> Get an owner's ETH and WETH balances on Robinhood Chain — plus an optional token balance — in one round-trip.



## OpenAPI

````yaml GET /evm/rh/balances
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
  /evm/rh/balances:
    get:
      tags:
        - Robinhood Chain
      summary: Get balances
      description: >-
        Get an owner's ETH and WETH balances on Robinhood Chain — plus an
        optional token balance — in one round-trip.
      parameters:
        - name: owner
          in: query
          required: true
          schema:
            type: string
          description: >-
            Owner wallet address. Accepts any casing; normalized to EIP-55
            checksum form.
        - name: tokenAddress
          in: query
          required: false
          schema:
            type: string
          description: >-
            Optional token address to also return the owner's token balance for.
            When omitted, `tokenWei` is `null`.
      responses:
        '200':
          description: Successfully retrieved balances
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/RhBalances'
        '400':
          description: Bad request - Invalid owner or token address
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
    RhBalances:
      type: object
      properties:
        ethWei:
          type: string
          description: Native ETH balance of the owner (wei), as string to support bigint.
        wethWei:
          type: string
          description: WETH balance of the owner (wei), as string to support bigint.
        tokenWei:
          type: string
          nullable: true
          description: >-
            Token balance of the owner in token base units, as string to support
            bigint. Null when no `tokenAddress` was requested.
      required:
        - ethWei
        - wethWei
        - tokenWei
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