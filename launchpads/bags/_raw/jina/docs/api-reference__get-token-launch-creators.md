> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Token Launch Creators

> Retrieve the creators/deployers of a specific token launch. Use the 'provider' field to show a platform logo in your UI, and prefer 'providerUsername' for display when present since 'username' is a Bags internal username and optional.



## OpenAPI

````yaml GET /token-launch/creator/v3
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
  /token-launch/creator/v3:
    get:
      tags:
        - Analytics
      summary: Get token launch creators (v3)
      description: >-
        Retrieve the creators/deployers of a specific token launch. Use the
        'provider' field to show a platform logo in your UI, and prefer
        'providerUsername' for display when present since 'username' is a Bags
        internal username and optional.
      parameters:
        - name: tokenMint
          in: query
          required: true
          schema:
            type: string
          description: Public key of the token mint
      responses:
        '200':
          description: Successfully retrieved token creators
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
                          $ref: '#/components/schemas/TokenLaunchCreatorV3'
        '500':
          description: Internal server error
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
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