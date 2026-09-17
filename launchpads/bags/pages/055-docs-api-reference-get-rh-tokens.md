# Bags - Get Robinhood Token List

> Source: https://docs.bags.fm/api-reference/get-rh-tokens
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/get-rh-tokens.md)

---

# Get Robinhood Token List

> Get a paged list of Bags V2 tokens on Robinhood Chain with live enrichment (spot price and bonding progress). Each item carries `priceEthPerToken` (nullable) and `bondingProgressPct`, plus resolved `metadata` (image, description).

`total` is bounded by an internal count-scan cap (10k): when `totalTruncated` is `true` the real total is higher, so treat `total` as a lower bound and keep paging until `items` comes back short instead of using it to conclude pagination is exhausted.

<Note>
  `total` is bounded by an internal count-scan cap (10k). When `totalTruncated` is `true`, the real total is higher — treat `total` as a lower bound and keep paging until `items` comes back short, rather than using `total` to decide pagination is exhausted.
</Note>


## OpenAPI

````yaml GET /evm/rh/tokens
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
  /evm/rh/tokens:
    get:
      tags:
        - Robinhood Chain
      summary: Get token list
      description: >-
        Get a paged list of Bags V2 tokens on Robinhood Chain with live
        enrichment (spot price and bonding progress). Each item carries
        `priceEthPerToken` (nullable) and `bondingProgressPct`, plus resolved
        `metadata` (image, description).


        `total` is bounded by an internal count-scan cap (10k): when
        `totalTruncated` is `true` the real total is higher, so treat `total` as
        a lower bound and keep paging until `items` comes back short instead of
        using it to conclude pagination is exhausted.
      parameters:
        - name: limit
          in: query
          required: false
          schema:
            type: number
            minimum: 1
            maximum: 100
            default: 50
          description: Number of tokens to return per page.
        - name: offset
          in: query
          required: false
          schema:
            type: number
            minimum: 0
            maximum: 10000
            default: 0
          description: Number of tokens to skip.
        - name: migrated
          in: query
          required: false
          schema:
            type: boolean
          description: >-
            Filter by migration status: `true` for graduated tokens, `false` for
            tokens still bonding.
        - name: creator
          in: query
          required: false
          schema:
            type: string
          description: >-
            Filter by creator address. Accepts any casing; normalized to EIP-55
            checksum form.
        - name: orderBy
          in: query
          required: false
          schema:
            type: string
            enum:
              - createdAtTimestamp
              - migratedAtTimestamp
            default: createdAtTimestamp
          description: Field to order the list by.
        - name: orderDirection
          in: query
          required: false
          schema:
            type: string
            enum:
              - asc
              - desc
            default: desc
          description: Sort direction.
      responses:
        '200':
          description: Successfully retrieved token list
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/RhTokensResponse'
        '400':
          description: Bad request - Invalid query parameters
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
    RhTokensResponse:
      type: object
      properties:
        items:
          type: array
          items:
            $ref: '#/components/schemas/RhTokenListItem'
          description: Page of tokens with live price and bonding-progress enrichment.
        total:
          type: number
          description: >-
            Total tokens matching the filter. Bounded by an internal count-scan
            cap (10k): when `totalTruncated` is true this is a lower bound, not
            the exact total.
        totalTruncated:
          type: boolean
          description: >-
            True when the count scan hit its safety bound before exhausting the
            matching set. Treat `total` as a lower bound and keep paging until
            `items` comes back short instead of using `total` to conclude
            pagination is exhausted.
      required:
        - items
        - total
        - totalTruncated
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
    RhTokenListItem:
      allOf:
        - $ref: '#/components/schemas/RhToken'
        - type: object
          properties:
            priceEthPerToken:
              type: string
              nullable: true
              description: >-
                Live spot price as an 1e18 fixed-point decimal string (ETH per
                whole token). For migrated tokens this comes from the pool
                (slot0) only — null when the pool read is unavailable. Render
                null as "unavailable", never 0.
            bondingProgressPct:
              type: number
              description: >-
                Bonding-curve graduation progress, 0-99 while bonding and 100
                once migrated.
          required:
            - priceEthPerToken
            - bondingProgressPct
    RhToken:
      type: object
      properties:
        address:
          type: string
          description: EIP-55 checksummed token address.
        name:
          type: string
          description: Token name.
        symbol:
          type: string
          description: Token symbol.
        metadataURI:
          type: string
          description: Token metadata URI as stored on-chain (typically IPFS).
        metadata:
          allOf:
            - $ref: '#/components/schemas/RhTokenMetadata'
          nullable: true
          description: >-
            Backend-resolved metadata (image, description). Null when resolution
            failed or is still pending.
        curve:
          type: string
          description: Address of the token's bonding curve contract.
        feeShare:
          type: string
          description: Address of the token's fee-share contract.
        poolId:
          type: string
          description: Uniswap V4 pool ID (bytes32 hex string) assigned at launch.
        creator:
          type: string
          description: EIP-55 checksummed address of the token creator.
        partner:
          type: string
          nullable: true
          description: >-
            EIP-55 checksummed partner address. Null when the token was launched
            without a partner.
        partnerFeeBps:
          type: number
          description: >-
            Partner's share of the creator-side fee half in basis points,
            snapshotted at launch.
        createdAtBlock:
          type: number
          description: Block number of the launch transaction.
        createdAtTimestamp:
          type: number
          description: Launch time as unix seconds.
        txHash:
          type: string
          description: Transaction hash of the launch.
        migrated:
          type: boolean
          description: >-
            Whether the token has graduated from the bonding curve to its
            Uniswap V4 pool.
        migratedAtBlock:
          type: number
          nullable: true
          description: >-
            Block number of the migration. Null while the token is still
            bonding.
        migratedAtTimestamp:
          type: number
          nullable: true
          description: >-
            Migration time as unix seconds. Null while the token is still
            bonding.
      required:
        - address
        - name
        - symbol
        - metadataURI
        - metadata
        - curve
        - feeShare
        - poolId
        - creator
        - partner
        - partnerFeeBps
        - createdAtBlock
        - createdAtTimestamp
        - txHash
        - migrated
        - migratedAtBlock
        - migratedAtTimestamp
    RhTokenMetadata:
      type: object
      properties:
        image:
          type: string
          nullable: true
          description: >-
            Resolved token image URL. Null when the metadata URI could not be
            resolved.
        description:
          type: string
          nullable: true
          description: >-
            Resolved token description. Null when the metadata URI could not be
            resolved.
      required:
        - image
        - description
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````