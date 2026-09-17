# Bags - Get Bags Pools

> Source: https://docs.bags.fm/api-reference/get-bags-pools
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/get-bags-pools.md)

---

# Get Bags Pools

> Retrieve a list of all Bags pools with their associated Meteora DBC and DAMM v2 pool keys



## OpenAPI

````yaml GET /solana/bags/pools
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
  /solana/bags/pools:
    get:
      tags:
        - State
      summary: Get Bags pools
      description: >-
        Retrieve a list of all Bags pools with their associated Meteora DBC and
        DAMM v2 pool keys
      parameters:
        - name: onlyMigrated
          in: query
          required: false
          schema:
            type: boolean
            default: false
          description: When true, only returns pools that have migrated to DAMM v2
      responses:
        '200':
          description: Successfully retrieved pools
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
                          $ref: '#/components/schemas/BagsPoolInfo'
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
    BagsPoolInfo:
      type: object
      properties:
        tokenMint:
          type: string
          description: Public key of the token mint
        dbcConfigKey:
          type: string
          nullable: true
          description: >-
            Public key of the Meteora DBC config (absent for DAMM v2 direct
            launches, which have no DBC config)
        dbcPoolKey:
          type: string
          nullable: true
          description: >-
            Public key of the Meteora DBC pool (absent for DAMM v2 direct
            launches, which have no DBC pool)
        dammV2PoolKey:
          type: string
          nullable: true
          description: >-
            Public key of the DAMM v2 pool (present for migrated DBC pools and
            for DAMM v2 direct launches)
      required:
        - tokenMint
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