# Bags - Get DAMM v2 Direct Launches

> Source: https://docs.bags.fm/api-reference/get-damm-v2-launches
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/get-damm-v2-launches.md)

---

# Get DAMM v2 Direct Launches

> Newest-first, paginated list of confirmed DAMM v2 direct launches, optionally filtered by quote mint. Only launches whose pool has been confirmed on-chain are returned.



## OpenAPI

````yaml GET /token-launch/damm-v2/launches
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
  /token-launch/damm-v2/launches:
    get:
      tags:
        - Token Launch
      summary: Get DAMM v2 direct launches
      description: >-
        Newest-first, paginated list of confirmed DAMM v2 direct launches,
        optionally filtered by quote mint. Only launches whose pool has been
        confirmed on-chain are returned.
      parameters:
        - name: limit
          in: query
          required: false
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
          description: Page size
        - name: quoteMint
          in: query
          required: false
          schema:
            type: string
          description: Base58 quote mint to filter launches by
        - name: cursor
          in: query
          required: false
          schema:
            type: string
          description: >-
            24-character `_id` cursor from a previous response's `nextCursor`.
            Omit for the first page.
      responses:
        '200':
          description: Successfully retrieved DAMM v2 direct launches
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/GetDammV2LaunchesResponsePayload'
        '400':
          description: Bad request - Invalid limit, quoteMint, or cursor
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
    GetDammV2LaunchesResponsePayload:
      type: object
      properties:
        launches:
          type: array
          items:
            $ref: '#/components/schemas/DammV2DirectLaunch'
          description: Confirmed DAMM v2 direct launches, newest first
        hasMore:
          type: boolean
          description: True when another page of results exists
        nextCursor:
          type: string
          description: Cursor to pass as the `cursor` query param to fetch the next page
          nullable: true
      required:
        - launches
        - hasMore
        - nextCursor
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
    DammV2DirectLaunch:
      type: object
      properties:
        name:
          type: string
          description: Token name
        symbol:
          type: string
          description: Token symbol
        description:
          type: string
          description: Token description
        telegram:
          type: string
          description: Telegram URL
          nullable: true
        twitter:
          type: string
          description: Twitter URL
          nullable: true
        website:
          type: string
          description: Website URL
          nullable: true
        image:
          type: string
          description: Token image URL
        tokenMint:
          type: string
          description: Public key of the token mint
        status:
          $ref: '#/components/schemas/TokenLaunchStatus'
        launchWallet:
          type: string
          description: Public key of the launch wallet
          nullable: true
        launchSignature:
          type: string
          description: Launch transaction signature
          nullable: true
        uri:
          type: string
          description: Token metadata URI
          nullable: true
        bagsConfigType:
          type: string
          description: >-
            DBC launch mode. `null` when the token has no DBC config (pre-launch
            or DAMM v2 direct). Direct launches never have a DBC config, so this
            is always `null` here.
          nullable: true
        createdAt:
          type: string
          format: date-time
          description: Creation timestamp
        updatedAt:
          type: string
          format: date-time
          description: Last update timestamp
      required:
        - name
        - symbol
        - description
        - image
        - tokenMint
        - status
        - bagsConfigType
        - createdAt
        - updatedAt
    TokenLaunchStatus:
      type: string
      enum:
        - PRE_LAUNCH
        - PRE_GRAD
        - MIGRATING
        - MIGRATED
      description: Status of the token launch
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````