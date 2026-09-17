> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Robinhood Trade Stats

> Get a server-side trade aggregate for a Bags V2 token on Robinhood Chain over a rolling window (volume, transaction counts, last price).

The aggregate streams the full window from the subgraph; `truncated` is `true` only in the pathological case where the window exceeds the ~500k-trade safety bound, in which case `volumeEthWei` and counts are a lower bound.



## OpenAPI

````yaml GET /evm/rh/trade-stats
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
  /evm/rh/trade-stats:
    get:
      tags:
        - Robinhood Chain
      summary: Get trade stats
      description: >-
        Get a server-side trade aggregate for a Bags V2 token on Robinhood Chain
        over a rolling window (volume, transaction counts, last price).


        The aggregate streams the full window from the subgraph; `truncated` is
        `true` only in the pathological case where the window exceeds the
        ~500k-trade safety bound, in which case `volumeEthWei` and counts are a
        lower bound.
      parameters:
        - name: tokenAddress
          in: query
          required: true
          schema:
            type: string
          description: >-
            Token address. Accepts any casing; normalized to EIP-55 checksum
            form.
        - name: windowSecs
          in: query
          required: false
          schema:
            type: number
            minimum: 300
            maximum: 604800
            default: 86400
          description: >-
            Rolling aggregation window in seconds (5 minutes to 7 days, default
            24 hours).
      responses:
        '200':
          description: Successfully retrieved trade stats
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/RhTradeStats'
        '400':
          description: Bad request - Invalid token address or window
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
    RhTradeStats:
      type: object
      properties:
        windowSecs:
          type: number
          description: Aggregation window in seconds.
        volumeEthWei:
          type: string
          description: >-
            Total ETH volume within the window (wei), as string to support
            bigint.
        txCount:
          type: number
          description: Total number of trades within the window.
        buyCount:
          type: number
          description: Number of buys within the window.
        sellCount:
          type: number
          description: Number of sells within the window.
        truncated:
          type: boolean
          description: >-
            True only in the pathological case where the window exceeded the
            ~500k-trade safety bound before being fully scanned; volume and
            counts are then a lower bound. False on the normal path.
        lastPriceEthPerToken:
          type: string
          nullable: true
          description: >-
            Spot price after the most recent trade, as an 1e18 fixed-point
            decimal string (ETH per whole token). Null when the token has no
            trades.
        lastTradeTimestamp:
          type: number
          nullable: true
          description: >-
            Unix-seconds timestamp of the most recent trade. Null when the token
            has no trades.
      required:
        - windowSecs
        - volumeEthWei
        - txCount
        - buyCount
        - sellCount
        - truncated
        - lastPriceEthPerToken
        - lastTradeTimestamp
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