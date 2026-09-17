> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Robinhood Creator Earnings

> Get a single user's earnings view for a Bags V2 token on Robinhood Chain: claimer/partner status, claimable, claimed, and estimated pending amounts. Returns `404` for non-V2 tokens.



## OpenAPI

````yaml GET /evm/rh/creator-earnings
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
  /evm/rh/creator-earnings:
    get:
      tags:
        - Robinhood Chain
      summary: Get creator earnings
      description: >-
        Get a single user's earnings view for a Bags V2 token on Robinhood
        Chain: claimer/partner status, claimable, claimed, and estimated pending
        amounts. Returns `404` for non-V2 tokens.
      parameters:
        - name: tokenAddress
          in: query
          required: true
          schema:
            type: string
          description: >-
            Token address. Accepts any casing; normalized to EIP-55 checksum
            form.
        - name: user
          in: query
          required: true
          schema:
            type: string
          description: >-
            User wallet address. Accepts any casing; normalized to EIP-55
            checksum form.
      responses:
        '200':
          description: Successfully retrieved creator earnings
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/RhCreatorEarnings'
        '400':
          description: Bad request - Invalid token or user address
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
    RhCreatorEarnings:
      type: object
      properties:
        token:
          type: string
          description: EIP-55 checksummed token address.
        user:
          type: string
          description: EIP-55 checksummed address of the queried user.
        isClaimer:
          type: boolean
          description: Whether the user is a fee-share claimer on this token.
        userBps:
          type: number
          description: The user's claimer share in basis points (0 if not a claimer).
        partner:
          type: string
          nullable: true
          description: >-
            EIP-55 checksummed partner address. Null when the token was launched
            without a partner.
        isPartner:
          type: boolean
          description: Whether the user is the token's partner.
        claimableWei:
          type: string
          description: >-
            Live claimable amount for the user (wei), as string to support
            bigint.
        claimedWei:
          type: string
          description: >-
            Total already claimed by the user on this token (wei), as string to
            support bigint.
        pendingEstimateWei:
          type: string
          description: >-
            The user's estimated share of the un-swept pending hook fees (wei),
            as string to support bigint.
      required:
        - token
        - user
        - isClaimer
        - userBps
        - partner
        - isPartner
        - claimableWei
        - claimedWei
        - pendingEstimateWei
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