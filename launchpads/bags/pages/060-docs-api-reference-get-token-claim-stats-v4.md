# Bags - Get Token Claim Stats v4

> Source: https://docs.bags.fm/api-reference/get-token-claim-stats-v4
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/get-token-claim-stats-v4.md)

---

# Get Token Claim Stats v4

> Retrieve claim totals per wallet, broken down by the mint each amount was claimed in and converted to USD at read time.

Unlike `/token-launch/claim-stats`, which reports a single lamport total, v4 covers all three claim sources — bonding-curve claims, fee-share v2 claims, and DAMM v2 direct custody claims — so claims denominated in a pool's quote mint rather than SOL are included and never summed into a SOL-denominated field.

Query by either `tokenMint` (all wallets that claimed on one token) or `wallet` (all tokens one wallet claimed on), but not both.



## OpenAPI

````yaml GET /token-launch/claim-stats/v4
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
  /token-launch/claim-stats/v4:
    get:
      tags:
        - Analytics
      summary: Get token claim stats v4
      description: >-
        Retrieve claim totals per wallet, broken down by the mint each amount
        was claimed in and converted to USD at read time.


        Unlike `/token-launch/claim-stats`, which reports a single lamport
        total, v4 covers all three claim sources — bonding-curve claims,
        fee-share v2 claims, and DAMM v2 direct custody claims — so claims
        denominated in a pool's quote mint rather than SOL are included and
        never summed into a SOL-denominated field.


        Query by either `tokenMint` (all wallets that claimed on one token) or
        `wallet` (all tokens one wallet claimed on), but not both.
      parameters:
        - name: tokenMint
          in: query
          required: false
          schema:
            type: string
          description: >-
            Public key of the token mint to aggregate claims for. Exactly one of
            tokenMint or wallet is required
        - name: wallet
          in: query
          required: false
          schema:
            type: string
          description: >-
            Public key of the wallet to aggregate claims for, across every token
            it has claimed on. Exactly one of tokenMint or wallet is required
        - name: includeForceClaim
          in: query
          required: false
          schema:
            type: string
            enum:
              - 'true'
              - 'false'
            default: 'false'
          description: Include forced claims in the totals. Excluded by default
        - name: includeUser
          in: query
          required: false
          schema:
            type: string
            enum:
              - 'true'
              - 'false'
            default: 'false'
          description: >-
            Populate the `user` field on each row with the claimer's profile.
            Omitted by default
      responses:
        '200':
          description: >-
            Successfully retrieved token claim stats. Rows are sorted by
            totalClaimedUsd descending, with unpriced rows last
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
                          $ref: '#/components/schemas/TokenClaimStatsV4'
        '400':
          description: >-
            Bad request - Invalid token mint or wallet, both or neither
            provided, or an unrecognized query parameter
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
    TokenClaimStatsV4:
      type: object
      properties:
        wallet:
          type: string
          description: Public key of the wallet that claimed
        tokenMint:
          type: string
          description: Public key of the token mint the claims belong to
        claims:
          type: array
          items:
            $ref: '#/components/schemas/TokenClaimAmount'
          description: >-
            One entry per claimed mint, sorted by amountUsd descending with
            unpriced entries last
        totalClaimedUsd:
          type: number
          nullable: true
          description: >-
            Sum of the USD values in claims, or null when any claimed mint has
            no price available
        user:
          $ref: '#/components/schemas/TokenClaimStatsV4User'
          description: >-
            Claimer profile, present only when includeUser is true and the
            wallet resolves to a user (optional)
      required:
        - wallet
        - tokenMint
        - claims
        - totalClaimedUsd
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
    TokenClaimAmount:
      type: object
      properties:
        mint:
          type: string
          description: >-
            Mint the amount is denominated in. Wrapped SOL for bonding-curve and
            fee-share v2 claims, the pool's quote mint for DAMM v2 direct
            custody claims
        decimals:
          type: number
          description: Decimals of the claimed mint (wrapped SOL is 9)
        amount:
          type: string
          description: >-
            Amount claimed in the mint's base units (as string to support
            bigint)
        amountUsd:
          type: number
          nullable: true
          description: >-
            USD value of the amount at read time, or null when no price is
            available for the mint
      required:
        - mint
        - decimals
        - amount
        - amountUsd
    TokenClaimStatsV4User:
      type: object
      properties:
        username:
          type: string
          description: >-
            Bags username of the claimer (may be a shortened wallet if no Bags
            user is linked)
        pfp:
          type: string
          description: Profile picture URL of the claimer
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
          description: Social/auth provider for the associated account
        providerUsername:
          type: string
          nullable: true
          description: Username/handle on the social provider
        twitterUsername:
          type: string
          description: Twitter/X username of the claimer, if available (optional)
        bagsUsername:
          type: string
          description: Bags platform username of the claimer, if available (optional)
        isAdmin:
          type: boolean
          description: Whether this user is an admin of the token launch (optional)
      required:
        - username
        - pfp
        - wallet
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