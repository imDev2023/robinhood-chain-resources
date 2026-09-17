> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Global Claim Feed v2

> Retrieve the feed of fee-claim events across all tokens, newest first.

Each event carries the mint the amount was claimed in, that mint's decimals, and a read-time USD value. v2 covers all three claim sources — bonding-curve claims, fee-share v2 claims, and DAMM v2 direct custody claims — so events denominated in a pool's quote mint rather than SOL are included.

Page backwards by passing the last event's `timestamp` as `before`; `hasMore` reports whether older events exist. Forced claims are excluded from this feed.



## OpenAPI

````yaml GET /feed/global-claim/v2
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
  /feed/global-claim/v2:
    get:
      tags:
        - Analytics
      summary: Get global claim feed v2
      description: >-
        Retrieve the feed of fee-claim events across all tokens, newest first.


        Each event carries the mint the amount was claimed in, that mint's
        decimals, and a read-time USD value. v2 covers all three claim sources —
        bonding-curve claims, fee-share v2 claims, and DAMM v2 direct custody
        claims — so events denominated in a pool's quote mint rather than SOL
        are included.


        Page backwards by passing the last event's `timestamp` as `before`;
        `hasMore` reports whether older events exist. Forced claims are excluded
        from this feed.
      parameters:
        - name: limit
          in: query
          required: false
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 100
          description: 'Maximum number of events to return (1-100, default: 100)'
        - name: before
          in: query
          required: false
          schema:
            type: integer
            minimum: 1
          description: >-
            Unix timestamp in seconds. Returns only events older than this, for
            pagination
        - name: minAmount
          in: query
          required: false
          schema:
            type: integer
            minimum: 1
          description: >-
            Lower bound on the raw claimed amount, in the base units of the
            event's own mint
        - name: maxAmount
          in: query
          required: false
          schema:
            type: integer
            minimum: 1
          description: >-
            Upper bound on the raw claimed amount, in the base units of the
            event's own mint
        - name: onlyFirstClaims
          in: query
          required: false
          schema:
            type: string
            enum:
              - 'true'
              - 'false'
          description: Return only each wallet's first claim per token
      responses:
        '200':
          description: Successfully retrieved the global claim feed
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/GlobalClaimFeedV2Response'
        '400':
          description: Bad request - Invalid query parameters
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
    GlobalClaimFeedV2Response:
      type: object
      properties:
        events:
          type: array
          items:
            $ref: '#/components/schemas/GlobalClaimEventV2'
          description: Claim events ordered by timestamp descending
        hasMore:
          type: boolean
          description: Whether more events exist before the last returned event
      required:
        - events
        - hasMore
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
    GlobalClaimEventV2:
      type: object
      properties:
        tokenMint:
          type: string
          description: Public key of the token the fees were claimed on
        user:
          oneOf:
            - $ref: '#/components/schemas/TokenLaunchCreatorV3'
          nullable: true
          description: >-
            Profile of the claiming wallet, or null when the wallet is not a
            known creator or claimer for the token
        wallet:
          type: string
          description: Public key of the wallet that claimed
        isCreator:
          type: boolean
          description: Whether this wallet is the token creator
        amount:
          type: string
          description: >-
            Amount claimed in the base units of `mint` (as string to support
            bigint)
        mint:
          type: string
          description: >-
            Mint the amount is denominated in. Wrapped SOL for bonding-curve and
            fee-share v2 claims, the pool's quote mint for DAMM v2 direct
            custody claims
        decimals:
          type: number
          description: Decimals of the claimed mint (wrapped SOL is 9)
        amountUsd:
          type: number
          nullable: true
          description: >-
            USD value of the amount at read time, or null when no price is
            available for the mint
        signature:
          type: string
          description: Transaction signature of the claim
        timestamp:
          type: number
          description: >-
            Unix timestamp of the claim, in seconds. Pass the last event's value
            as `before` to page backwards
        isFirstClaim:
          type: boolean
          description: >-
            Whether this is the wallet's first claim on this token, across all
            three claim sources
        preMigrationPool:
          type: string
          nullable: true
          description: Bonding curve pool the token traded on before migration, when known
        postMigrationPool:
          type: string
          nullable: true
          description: Pool the token trades on after migration, when known
        isForceClaim:
          type: boolean
          description: >-
            Whether the claim was forced rather than initiated by the wallet.
            Always false on this feed, which excludes forced claims
        forceClaimType:
          type: string
          enum:
            - Unknown
            - Admin
            - Manager
          nullable: true
          description: >-
            Who executed a forced claim, or null when the claim was not forced.
            Forced custody claims have no on-chain executor type and resolve to
            'Unknown'
      required:
        - tokenMint
        - user
        - wallet
        - isCreator
        - amount
        - mint
        - decimals
        - amountUsd
        - signature
        - timestamp
        - isFirstClaim
        - preMigrationPool
        - postMigrationPool
        - isForceClaim
        - forceClaimType
    TokenLaunchCreatorV3:
      type: object
      properties:
        username:
          type: string
          description: >-
            Bags username of the creator (internal; may be a shortened wallet if
            no Bags user is linked). Prefer using providerUsername for display
            when provider exists.
        pfp:
          type: string
          description: >-
            Profile picture URL of the creator (may be a default image if no
            Bags user is linked)
        royaltyBps:
          type: number
          description: Royalty in basis points
        isCreator:
          type: boolean
          description: Whether this user is the token creator
        wallet:
          type: string
          description: Public key of the wallet
        provider:
          oneOf:
            - $ref: '#/components/schemas/SocialProvider'
            - type: string
              enum:
                - unknown
          nullable: true
          description: >-
            Social/auth provider for the associated account. Use this to render
            a platform logo. May be 'unknown' or null when not available.
        providerUsername:
          type: string
          nullable: true
          description: >-
            Username/handle on the social provider. Prefer this for display when
            present; 'username' is Bags internal.
        twitterUsername:
          type: string
          description: Twitter/X username of the creator, if available
        bagsUsername:
          type: string
          description: Bags platform username of the creator, if available
        isAdmin:
          type: boolean
          description: Whether this user is an admin of the token launch
    SocialProvider:
      type: string
      enum:
        - apple
        - google
        - email
        - solana
        - twitter
        - tiktok
        - kick
        - instagram
        - onlyfans
        - github
        - moltbook
      example: twitter
      description: Supported social/auth providers
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````