> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Token Launch Feed

> Retrieve the token launch feed containing recent and active token launches with their current status.



## OpenAPI

````yaml GET /token-launch/feed
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
  /token-launch/feed:
    get:
      tags:
        - Token Launch
      summary: Get token launch feed
      description: >-
        Retrieve the token launch feed containing recent and active token
        launches with their current status.
      responses:
        '200':
          description: Successfully retrieved token launch feed
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
                          $ref: '#/components/schemas/TokenLaunchFeedItem'
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
    TokenLaunchFeedItem:
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
        image:
          type: string
          description: Token image URL
        tokenMint:
          type: string
          description: Public key of the token mint
        status:
          $ref: '#/components/schemas/TokenLaunchStatus'
        twitter:
          type: string
          description: Twitter URL
          nullable: true
        website:
          type: string
          description: Website URL
          nullable: true
        launchSignature:
          type: string
          description: Launch transaction signature
          nullable: true
        accountKeys:
          type: array
          items:
            type: string
          description: Public keys of accounts involved in the launch transaction
          nullable: true
        numRequiredSigners:
          type: number
          description: Number of required signers for the launch transaction
          nullable: true
        uri:
          type: string
          description: Token metadata URI
          nullable: true
        dbcPoolKey:
          type: string
          description: Public key of the Meteora DBC pool
          nullable: true
        dbcConfigKey:
          type: string
          description: Public key of the Meteora DBC pool config
          nullable: true
      required:
        - name
        - symbol
        - description
        - image
        - tokenMint
        - status
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