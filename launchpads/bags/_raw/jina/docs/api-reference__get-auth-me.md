> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Current User Info

> Returns information about the user that owns the provided public API key.



## OpenAPI

````yaml GET /auth/me
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
  /auth/me:
    get:
      tags:
        - Auth
      summary: Get current user info
      description: >-
        Returns information about the user that owns the provided public API
        key.
      parameters: []
      responses:
        '200':
          description: Successfully retrieved user information
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/AuthMeResponse'
        '401':
          description: Unauthorized - Invalid or missing API key
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
        '404':
          description: Not found - User linked to the API key cannot be found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
        '429':
          description: Too many requests - Rate limit exceeded
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
    AuthMeResponse:
      type: object
      properties:
        user:
          $ref: '#/components/schemas/AuthMeUser'
          description: User information associated with the API key
      required:
        - user
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
    AuthMeUser:
      type: object
      properties:
        uuid:
          type: string
          description: Unique identifier for the user
        type:
          type: string
          description: Account type
        membership:
          type: object
          description: Membership details for the user
        ticker:
          type: string
          description: Ticker symbol associated with the user
        username:
          type: string
          description: Unique username
        status:
          type: string
          description: Account status (e.g. active)
        pref_name:
          type: string
          description: Display name chosen by the user
        picture:
          type: string
          description: URL of the user's profile picture
        twitter_userID:
          type: string
          description: Linked Twitter/X user ID
        registered_at:
          type: string
          format: date-time
          description: ISO 8601 timestamp of when the user registered
        profile_views:
          type: integer
          description: Total number of profile views
        invites:
          type: integer
          description: Number of available invites
        invited_by:
          type: string
          description: Identifier of the user who sent the invite
        twitter_data:
          $ref: '#/components/schemas/AuthMeTwitterData'
          description: Twitter/X profile data for the linked account
        points:
          type: integer
          description: Accumulated reward points
        rank:
          type: integer
          description: User's global rank
        referral_count:
          type: integer
          description: Number of successful referrals
      required:
        - uuid
        - type
        - membership
        - ticker
        - username
        - status
        - pref_name
        - picture
        - twitter_userID
        - registered_at
        - profile_views
        - invites
        - invited_by
        - twitter_data
        - points
        - rank
        - referral_count
    AuthMeTwitterData:
      type: object
      properties:
        verified:
          type: boolean
          description: Whether the linked Twitter/X account is verified
        followers_count:
          type: integer
          description: Number of followers on the linked Twitter/X account
        following_count:
          type: integer
          description: Number of accounts followed on the linked Twitter/X account
        created_at:
          type: string
          description: Twitter/X account creation date
        url:
          type: string
          description: URL associated with the Twitter/X profile
      required:
        - verified
        - followers_count
        - following_count
        - created_at
        - url
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````