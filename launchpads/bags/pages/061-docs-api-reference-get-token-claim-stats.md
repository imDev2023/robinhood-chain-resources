# Bags - Get Token Claim Stats

> Source: https://docs.bags.fm/api-reference/get-token-claim-stats
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/get-token-claim-stats.md)

---

# Get Token Claim Stats

> Retrieve claim statistics for all fee claimers of a specific token, including total claimed amounts per user.



## OpenAPI

````yaml GET /token-launch/claim-stats
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
  /token-launch/claim-stats:
    get:
      tags:
        - Analytics
      summary: Get token claim stats
      description: >-
        Retrieve claim statistics for all fee claimers of a specific token,
        including total claimed amounts per user.
      parameters:
        - name: tokenMint
          in: query
          required: true
          schema:
            type: string
          description: Public key of the token mint
      responses:
        '200':
          description: Successfully retrieved token claim stats
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
                          $ref: >-
                            #/components/schemas/TokenLaunchCreatorV3WithClaimStats
        '400':
          description: Bad request - Invalid token mint
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
    TokenLaunchCreatorV3WithClaimStats:
      type: object
      properties:
        username:
          type: string
          description: >-
            Bags username of the creator (internal; may be a shortened wallet if
            no Bags user is linked)
        pfp:
          type: string
          description: Profile picture URL of the creator
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
          description: Social/auth provider for the associated account
        providerUsername:
          type: string
          nullable: true
          description: Username/handle on the social provider
        twitterUsername:
          type: string
          description: Twitter/X username of the creator, if available (optional)
        bagsUsername:
          type: string
          description: Bags platform username of the creator, if available (optional)
        isAdmin:
          type: boolean
          description: Whether this user is an admin of the token launch (optional)
        totalClaimed:
          type: string
          description: Total fees claimed by this user (as string to support bigint)
      required:
        - username
        - pfp
        - royaltyBps
        - isCreator
        - wallet
        - totalClaimed
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