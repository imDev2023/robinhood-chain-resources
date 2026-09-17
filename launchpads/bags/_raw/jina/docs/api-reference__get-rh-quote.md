> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Robinhood Swap Quote

> Get a display-only swap quote for a Bags V2 token on Robinhood Chain. Pre-migration quotes come from the bonding curve; post-migration quotes come from the Uniswap V4 Quoter. **Exact-in only** — exact-out is not supported.

Quotes are display-only and uncached: every request quotes against the current block, and clients must re-quote client-side at sign time. Returns `404` for non-V2 tokens.

<Warning>
  Quotes are **display-only** — always re-quote client-side at sign time. Every request quotes against the current block (responses are never cached).
</Warning>

<Note>
  Quotes are **exact-in only**: `amountWei` is always the input amount (ETH wei for buys, token base units for sells). Exact-out is not supported.
</Note>


## OpenAPI

````yaml GET /evm/rh/quote
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
  /evm/rh/quote:
    get:
      tags:
        - Robinhood Chain
      summary: Get swap quote
      description: >-
        Get a display-only swap quote for a Bags V2 token on Robinhood Chain.
        Pre-migration quotes come from the bonding curve; post-migration quotes
        come from the Uniswap V4 Quoter. **Exact-in only** — exact-out is not
        supported.


        Quotes are display-only and uncached: every request quotes against the
        current block, and clients must re-quote client-side at sign time.
        Returns `404` for non-V2 tokens.
      parameters:
        - name: tokenAddress
          in: query
          required: true
          schema:
            type: string
          description: >-
            Token address. Accepts any casing; normalized to EIP-55 checksum
            form.
        - name: side
          in: query
          required: true
          schema:
            type: string
            enum:
              - buy
              - sell
          description: >-
            Quote direction. `buy`: ETH in, tokens out. `sell`: tokens in, ETH
            out.
        - name: amountWei
          in: query
          required: true
          schema:
            type: string
          description: >-
            Input amount as a positive decimal integer string (wei for buys,
            token base units for sells).
      responses:
        '200':
          description: Successfully retrieved swap quote
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/RhQuote'
        '400':
          description: Bad request - Invalid token address, side, or amount
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
    RhQuote:
      type: object
      properties:
        side:
          type: string
          enum:
            - buy
            - sell
          description: 'Quote direction. Buy: ETH in, tokens out. Sell: tokens in, ETH out.'
        venue:
          type: string
          enum:
            - curve
            - pool
          description: >-
            Where the quote was computed: the bonding curve (pre-migration) or
            the Uniswap V4 Quoter (post-migration).
        amountInWei:
          type: string
          description: Input amount in wei / token base units, as string to support bigint.
        amountOutWei:
          type: string
          description: >-
            Expected output amount in wei / token base units, as string to
            support bigint.
        feeWei:
          type: string
          nullable: true
          description: >-
            Total fee taken by the venue for this quote (wei), as string to
            support bigint. Null when the venue does not report it (pool venue).
        asOfBlock:
          type: number
          description: Block number the quote was computed against.
      required:
        - side
        - venue
        - amountInWei
        - amountOutWei
        - feeWei
        - asOfBlock
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