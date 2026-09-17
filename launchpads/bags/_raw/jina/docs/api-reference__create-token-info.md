> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Create Token Info and Metadata

> Create token information with image upload and generate a token mint that can be used to launch a token



## OpenAPI

````yaml POST /token-launch/create-token-info
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
  /token-launch/create-token-info:
    post:
      tags:
        - Token Launch
      summary: Create token info and Metadata
      description: >-
        Create token information with image upload and generate a token mint
        that can be used to launch a token
      requestBody:
        required: true
        content:
          multipart/form-data:
            schema:
              type: object
              description: >-
                Provide either an image file or imageUrl. If metadataUrl is
                provided, we will not upload metadata to IPFS.
              properties:
                image:
                  type: string
                  format: binary
                  description: Token image file (optional if imageUrl is provided)
                imageUrl:
                  type: string
                  format: uri
                  description: >-
                    Public URL to the token image (optional if image is
                    provided)
                metadataUrl:
                  type: string
                  format: uri
                  description: >-
                    URL to a JSON metadata file. When provided, the API will not
                    upload metadata to IPFS and will use this URL as-is. The
                    JSON must match the fields submitted in this request.
                name:
                  type: string
                  maxLength: 32
                  description: Token name (max 32 characters)
                symbol:
                  type: string
                  maxLength: 10
                  description: >-
                    Token symbol (will be converted to UPPERCASE; max 10
                    characters)
                description:
                  type: string
                  maxLength: 1000
                  description: Token description (max 1000 characters)
                telegram:
                  type: string
                  description: Telegram URL
                  nullable: true
                twitter:
                  type: string
                  description: Twitter URL
                  nullable: true
                website:
                  type: string
                  description: Website URL
                  nullable: true
              required:
                - name
                - symbol
                - description
              oneOf:
                - required:
                    - image
                  not:
                    anyOf:
                      - required:
                          - imageUrl
                      - required:
                          - metadataUrl
                - required:
                    - imageUrl
                  not:
                    anyOf:
                      - required:
                          - image
                      - required:
                          - metadataUrl
                - required:
                    - imageUrl
                    - metadataUrl
                  not:
                    required:
                      - image
      responses:
        '200':
          description: Successfully created token info
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/CreateTokenInfoResponse'
        '400':
          description: Bad request - Invalid parameters or invalid field combination
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
    CreateTokenInfoResponse:
      type: object
      properties:
        tokenMint:
          type: string
          description: Public key of the generated token mint
        tokenMetadata:
          type: string
          description: IPFS URL of the token metadata
        tokenLaunch:
          $ref: '#/components/schemas/BagsLaunchPadTokenLaunch'
      required:
        - tokenMint
        - tokenMetadata
        - tokenLaunch
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
    BagsLaunchPadTokenLaunch:
      type: object
      properties:
        userId:
          type: string
          description: User ID of the token creator
          nullable: true
        name:
          type: string
          description: Token name
        symbol:
          type: string
          description: Token symbol
        description:
          type: string
          description: Token description
        telegram:
          type: string
          description: Telegram URL
          nullable: true
        twitter:
          type: string
          description: Twitter URL
          nullable: true
        website:
          type: string
          description: Website URL
          nullable: true
        image:
          type: string
          description: Token image URL
        tokenMint:
          type: string
          description: Public key of the token mint
        status:
          $ref: '#/components/schemas/TokenLaunchStatus'
        launchWallet:
          type: string
          description: Public key of the launch wallet
          nullable: true
        launchSignature:
          type: string
          description: Launch transaction signature
          nullable: true
        uri:
          type: string
          description: Token metadata URI
          nullable: true
        createdAt:
          type: string
          format: date-time
          description: Creation timestamp
        updatedAt:
          type: string
          format: date-time
          description: Last update timestamp
      required:
        - name
        - symbol
        - description
        - image
        - tokenMint
        - status
        - createdAt
        - updatedAt
    TokenLaunchStatus:
      type: string
      enum:
        - PRE_LAUNCH
        - PRE_GRAD
        - MIGRATING
        - MIGRATED
      description: Status of the token launch
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````