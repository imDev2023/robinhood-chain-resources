> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get DAMM v2 Supported Quote Tokens

> Every quote mint currently usable for DAMM v2 direct launches: all mints holding a cp-amm TokenBadge, enriched with decimals, owning token program, Token 2022 metadata, and an image.



## OpenAPI

````yaml GET /token-launch/damm-v2/supported-quote-tokens
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
  /token-launch/damm-v2/supported-quote-tokens:
    get:
      tags:
        - Token Launch
      summary: Get DAMM v2 supported quote tokens
      description: >-
        Every quote mint currently usable for DAMM v2 direct launches: all mints
        holding a cp-amm TokenBadge, enriched with decimals, owning token
        program, Token 2022 metadata, and an image.
      responses:
        '200':
          description: Successfully retrieved supported quote tokens
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: >-
                          #/components/schemas/GetDammV2SupportedQuoteTokensResponsePayload
        '400':
          description: Bad request - Query parameters are not accepted
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
    GetDammV2SupportedQuoteTokensResponsePayload:
      type: object
      properties:
        tokens:
          type: array
          items:
            $ref: '#/components/schemas/DammV2SupportedQuoteToken'
          description: >-
            Quote mints usable for DAMM v2 direct launches, sorted by symbol
            ascending (null symbols first)
      required:
        - tokens
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
    DammV2SupportedQuoteToken:
      type: object
      properties:
        mint:
          type: string
          description: Quote mint public key
        tokenProgram:
          type: string
          description: Token program that owns the mint (Tokenkeg... or TokenzQd...)
        decimals:
          type: number
          description: Mint decimals
        name:
          type: string
          description: >-
            Token 2022 on-chain name; `null` when the mint has no TokenMetadata
            extension
          nullable: true
        symbol:
          type: string
          description: >-
            Token 2022 on-chain symbol; `null` when the mint has no
            TokenMetadata extension
          nullable: true
        uri:
          type: string
          description: >-
            Token 2022 metadata JSON URI; `null` when the mint has no
            TokenMetadata extension
          nullable: true
        image:
          type: string
          description: Token image URL; `null` when no image is set
          nullable: true
      required:
        - mint
        - tokenProgram
        - decimals
        - name
        - symbol
        - uri
        - image
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````