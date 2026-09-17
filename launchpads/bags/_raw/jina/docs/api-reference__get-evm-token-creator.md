> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get EVM Token Creators

> Resolve the creator and fee-share claimers of a Bags EVM token, enriched with Bags social profile data (username, pfp, connected social provider).

On-chain data (creator, claimers, and their basis-point shares) is read from the Bags EVM factory registry. Each wallet is resolved to a Bags user, and wallets with no known Bags user are returned with blank social fields. The creator is always included; if the creator is not also a claimer, they are appended with `royaltyBps: 0` and `isCreator: true`.

The `tokenAddress` is trimmed and normalized to its EIP-55 checksum form before use. A token with a single creator/claimer still returns a one-element array.

<Note>
  Provide a checksummed or lowercase `0x` address; the backend trims it and normalizes it to EIP-55 checksum form.

  The response is always an array — a token with a single creator/claimer still returns a one-element array. Wallets without a linked Bags user are returned with `provider: "unknown"` and empty `username`/`pfp`.
</Note>


## OpenAPI

````yaml GET /evm/token-creator
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
  /evm/token-creator:
    get:
      tags:
        - EVM
      summary: Get EVM token creators
      description: >-
        Resolve the creator and fee-share claimers of a Bags EVM token, enriched
        with Bags social profile data (username, pfp, connected social
        provider).


        On-chain data (creator, claimers, and their basis-point shares) is read
        from the Bags EVM factory registry. Each wallet is resolved to a Bags
        user, and wallets with no known Bags user are returned with blank social
        fields. The creator is always included; if the creator is not also a
        claimer, they are appended with `royaltyBps: 0` and `isCreator: true`.


        The `tokenAddress` is trimmed and normalized to its EIP-55 checksum form
        before use. A token with a single creator/claimer still returns a
        one-element array.
      parameters:
        - name: tokenAddress
          in: query
          required: true
          schema:
            type: string
          description: >-
            Bags EVM token address. Must be a valid `0x`-prefixed, 20-byte hex
            EVM address. Normalized to EIP-55 checksum form.
      responses:
        '200':
          description: Successfully retrieved EVM token creators
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
                          $ref: '#/components/schemas/EvmTokenCreator'
        '400':
          description: >-
            Bad request - Invalid EVM address, must be a 0x-prefixed 20-byte hex
            address
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/EvmTokenCreatorErrorResponse'
        '401':
          description: Unauthorized - Invalid or missing API key
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
        '404':
          description: >-
            Not found - The address is not a Bags EVM token, or no
            creators/claimers could be resolved
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/EvmTokenCreatorErrorResponse'
        '429':
          description: Too many requests - Rate limit exceeded
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/EvmTokenCreatorErrorResponse'
        '500':
          description: Internal server error
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/EvmTokenCreatorErrorResponse'
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
    EvmTokenCreator:
      type: object
      properties:
        username:
          type: string
          description: >-
            Bags username of the creator/claimer. Empty string when the wallet
            has no usable social provider (i.e. no linked Bags user).
        pfp:
          type: string
          description: >-
            Profile image URL. Empty string when the wallet has no usable social
            provider.
        royaltyBps:
          type: number
          description: >-
            Share of the claimer pot in basis points (10000 = 100%). 0 for a
            creator who is not also a claimer.
        isCreator:
          type: boolean
          description: Whether this wallet launched the token.
        wallet:
          type: string
          description: EIP-55 checksummed EVM address of the creator/claimer.
        provider:
          oneOf:
            - $ref: '#/components/schemas/SocialProvider'
            - type: string
              enum:
                - unknown
          nullable: true
          description: >-
            Social/auth provider for the associated account (e.g. 'twitter').
            Use this to render a platform logo. 'unknown' when the wallet is not
            linked to a Bags user, or null when unavailable.
        providerUsername:
          type: string
          nullable: true
          description: >-
            Username/handle on the connected social provider. null when
            unavailable.
        twitterUsername:
          type: string
          description: >-
            Twitter/X username. Optional; present only when provider is
            'twitter'.
        bagsUsername:
          type: string
          description: >-
            Bags platform username. Optional; present only when a Bags username
            is available.
      required:
        - username
        - pfp
        - royaltyBps
        - isCreator
        - wallet
    EvmTokenCreatorErrorResponse:
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