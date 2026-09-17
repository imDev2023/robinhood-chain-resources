> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Robinhood Trade History

> Get trade history for a Bags V2 token on Robinhood Chain, newest first, using a compound keyset cursor. Every page respects `limit` (never over-returns), and ties within a busy second are never skipped.

For the next page pass **both** `nextBeforeTs` back as `beforeTs` and `nextBeforeId` back as `beforeId`. Both are `null` when the history is exhausted.

<Note>
  Pagination uses a compound keyset cursor. For the next (older) page, pass **both** `nextBeforeTs` back as `beforeTs` and `nextBeforeId` back as `beforeId`. Both cursors are `null` when the history is exhausted.
</Note>

```typescript theme={null}
const firstPage = await getTrades({ tokenAddress, limit: 100 });

const nextPage = await getTrades({
  tokenAddress,
  limit: 100,
  beforeTs: firstPage.nextBeforeTs,
  beforeId: firstPage.nextBeforeId,
});
```


## OpenAPI

````yaml GET /evm/rh/trades
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
  /evm/rh/trades:
    get:
      tags:
        - Robinhood Chain
      summary: Get trade history
      description: >-
        Get trade history for a Bags V2 token on Robinhood Chain, newest first,
        using a compound keyset cursor. Every page respects `limit` (never
        over-returns), and ties within a busy second are never skipped.


        For the next page pass **both** `nextBeforeTs` back as `beforeTs` and
        `nextBeforeId` back as `beforeId`. Both are `null` when the history is
        exhausted.
      parameters:
        - name: tokenAddress
          in: query
          required: true
          schema:
            type: string
          description: >-
            Token address. Accepts any casing; normalized to EIP-55 checksum
            form.
        - name: limit
          in: query
          required: false
          schema:
            type: number
            minimum: 1
            maximum: 200
            default: 50
          description: Number of trades to return per page.
        - name: beforeTs
          in: query
          required: false
          schema:
            type: number
          description: >-
            Cursor timestamp (unix seconds) from a previous page's
            `nextBeforeTs`. Sending only `beforeTs` without `beforeId` starts
            from strictly-older timestamps.
        - name: beforeId
          in: query
          required: false
          schema:
            type: string
          description: >-
            Cursor trade ID from a previous page's `nextBeforeId`. Must
            accompany `beforeTs`.
      responses:
        '200':
          description: Successfully retrieved trades
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/RhTradesResponse'
        '400':
          description: Bad request - Invalid token address or cursor parameters
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
    RhTradesResponse:
      type: object
      properties:
        trades:
          type: array
          items:
            $ref: '#/components/schemas/RhTrade'
          description: Trades, newest first.
        nextBeforeTs:
          type: number
          nullable: true
          description: >-
            Cursor timestamp for the next (older) page — pass back as `beforeTs`
            together with `nextBeforeId`. Null when the history is exhausted.
        nextBeforeId:
          type: string
          nullable: true
          description: >-
            Cursor trade ID for the next (older) page — pass back as `beforeId`
            together with `nextBeforeTs`. Null when the history is exhausted.
      required:
        - trades
        - nextBeforeTs
        - nextBeforeId
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
    RhTrade:
      type: object
      properties:
        id:
          type: string
          description: >-
            Unique trade ID (subgraph entity ID). Used as the `beforeId` cursor
            value.
        kind:
          type: string
          enum:
            - buy
            - sell
          description: Trade direction.
        venue:
          type: string
          enum:
            - curve
            - pool
          description: >-
            Where the trade executed: the bonding curve (pre-migration) or the
            Uniswap V4 pool (post-migration).
        account:
          type: string
          description: EIP-55 checksummed address of the trader.
        ethWei:
          type: string
          description: ETH leg of the trade in wei, as string to support bigint.
        tokenWei:
          type: string
          description: >-
            Token leg of the trade in token base units, as string to support
            bigint.
        priceEthPerToken:
          type: string
          description: >-
            Post-trade spot price as an 1e18 fixed-point decimal string (ETH per
            whole token) — not VWAP. For the execution price use `ethWei /
            tokenWei`.
        blockNumber:
          type: number
          description: Block number of the trade.
        timestamp:
          type: number
          description: Trade time as unix seconds.
        txHash:
          type: string
          description: Transaction hash of the trade.
        logIndex:
          type: number
          description: Log index of the trade event within the transaction.
      required:
        - id
        - kind
        - venue
        - account
        - ethWei
        - tokenWei
        - priceEthPerToken
        - blockNumber
        - timestamp
        - txHash
        - logIndex
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````