> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Index Token History

> Get completed distribution cycles for an index token on Robinhood Chain, newest first. Each cycle covers the fee claim, the basket token buys it funded, the holder distribution (with snapshot stats), and the top 10 recipients.

For the next page pass `nextCursor` back as `cursor`. `nextCursor` is `null` when the history is exhausted.



## OpenAPI

````yaml GET /evm/rh/index-token/history
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
  /evm/rh/index-token/history:
    get:
      tags:
        - Robinhood Chain
      summary: Get index token history
      description: >-
        Get completed distribution cycles for an index token on Robinhood Chain,
        newest first. Each cycle covers the fee claim, the basket token buys it
        funded, the holder distribution (with snapshot stats), and the top 10
        recipients.


        For the next page pass `nextCursor` back as `cursor`. `nextCursor` is
        `null` when the history is exhausted.
      parameters:
        - name: tokenAddress
          in: query
          required: true
          schema:
            type: string
          description: >-
            Index token address. Accepts any casing; normalized to EIP-55
            checksum form.
        - name: limit
          in: query
          required: false
          schema:
            type: number
            minimum: 1
            maximum: 50
            default: 20
          description: Number of distribution cycles to return per page.
        - name: cursor
          in: query
          required: false
          schema:
            type: string
          description: >-
            Cursor from a previous page's `nextCursor`. Must be a 24-character
            hex ID.
      responses:
        '200':
          description: Successfully retrieved index token history
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/RhIndexTokenHistoryResponse'
        '400':
          description: Bad request - Invalid token address, limit, or cursor
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
    RhIndexTokenHistoryResponse:
      type: object
      properties:
        items:
          type: array
          items:
            $ref: '#/components/schemas/RhIndexTokenHistoryItem'
          description: >-
            Completed distribution cycles, newest first. Only completed
            distributions with confirmed claims are included.
        hasMore:
          type: boolean
          description: True when more cycles exist beyond this page.
        nextCursor:
          type: string
          nullable: true
          description: >-
            Cursor for the next page. Pass back as `cursor`. Null when the
            history is exhausted.
      required:
        - items
        - hasMore
        - nextCursor
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
    RhIndexTokenHistoryItem:
      type: object
      properties:
        id:
          type: string
          description: Distribution cycle ID. Pass as `cursor` to fetch the next page.
        timestamp:
          type: string
          description: ISO 8601 timestamp of the distribution cycle.
        claim:
          $ref: '#/components/schemas/RhIndexTokenHistoryClaim'
        buys:
          type: array
          items:
            $ref: '#/components/schemas/RhIndexTokenHistoryBuy'
          description: Basket token buys funded by the claimed fees.
        distribution:
          $ref: '#/components/schemas/RhIndexTokenHistoryDistribution'
        topRecipients:
          type: array
          items:
            $ref: '#/components/schemas/RhIndexTokenHistoryRecipient'
          description: Top 10 recipients of the distribution by snapshot balance.
      required:
        - id
        - timestamp
        - claim
        - buys
        - distribution
        - topRecipients
    RhIndexTokenHistoryClaim:
      type: object
      properties:
        txHash:
          type: string
          nullable: true
          description: Transaction hash of the fee claim, or null when not available.
        claimedWei:
          type: string
          description: Amount of ETH claimed, in wei as a decimal string.
        minedAt:
          type: string
          nullable: true
          description: ISO 8601 timestamp when the claim transaction was mined, or null.
        finalizedAt:
          type: string
          nullable: true
          description: >-
            ISO 8601 timestamp when the claim transaction was finalized, or
            null.
      required:
        - txHash
        - claimedWei
        - minedAt
        - finalizedAt
    RhIndexTokenHistoryBuy:
      type: object
      properties:
        token:
          type: string
          description: Basket token address that was bought.
        ethInWei:
          type: string
          description: ETH spent on the buy, in wei as a decimal string.
        boughtAmountRaw:
          type: string
          nullable: true
          description: >-
            Raw token amount bought (base units as a decimal string), or null
            when not available.
        txHash:
          type: string
          nullable: true
          description: Transaction hash of the buy, or null when not available.
        finalizedAt:
          type: string
          nullable: true
          description: ISO 8601 timestamp when the buy transaction was finalized, or null.
      required:
        - token
        - ethInWei
        - boughtAmountRaw
        - txHash
        - finalizedAt
    RhIndexTokenHistoryDistribution:
      type: object
      properties:
        totalWei:
          type: string
          description: Total ETH value of the distribution, in wei as a decimal string.
        distributableWei:
          type: string
          description: >-
            ETH value actually distributable to holders, in wei as a decimal
            string.
        snapshot:
          $ref: '#/components/schemas/RhIndexTokenHistorySnapshot'
        payoutTxHashes:
          type: array
          items:
            type: string
          description: Transaction hashes of the payout batches.
        completedAt:
          type: string
          description: ISO 8601 timestamp when the distribution completed.
      required:
        - totalWei
        - distributableWei
        - snapshot
        - payoutTxHashes
        - completedAt
    RhIndexTokenHistoryRecipient:
      type: object
      properties:
        wallet:
          type: string
          description: Recipient wallet address.
        snapshotBalanceRaw:
          type: string
          description: >-
            Recipient's index-token balance at the snapshot (base units as a
            decimal string).
        amounts:
          type: array
          items:
            $ref: '#/components/schemas/RhIndexTokenHistoryRecipientAmount'
          description: Per-basket-token amounts the recipient received.
      required:
        - wallet
        - snapshotBalanceRaw
        - amounts
    RhIndexTokenHistorySnapshot:
      type: object
      properties:
        holderCount:
          type: number
          nullable: true
          description: Total holder count at the snapshot, or null when not recorded.
        recipientCount:
          type: number
          description: Number of holders included in the distribution.
        excludedHolderCount:
          type: number
          description: Number of holders excluded from the distribution.
        includedSupply:
          type: string
          description: >-
            Token supply included in the distribution, in base units as a
            decimal string.
        blockNumber:
          type: string
          nullable: true
          description: Block number the snapshot was taken at, or null when not recorded.
        exportedAt:
          type: string
          nullable: true
          description: ISO 8601 timestamp when the snapshot was exported, or null.
      required:
        - holderCount
        - recipientCount
        - excludedHolderCount
        - includedSupply
        - blockNumber
        - exportedAt
    RhIndexTokenHistoryRecipientAmount:
      type: object
      properties:
        token:
          type: string
          description: Basket token address.
        amountRaw:
          type: string
          description: Raw token amount received (base units as a decimal string).
      required:
        - token
        - amountRaw
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````