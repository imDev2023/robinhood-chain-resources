> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Token Launch

> Retrieve a single token launch record by its token mint.



## OpenAPI

````yaml GET /token-launch
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
  /token-launch:
    get:
      tags:
        - Token Launch
      summary: Get token launch
      description: Retrieve a single token launch record by its token mint.
      parameters:
        - name: tokenMint
          in: query
          required: true
          schema:
            type: string
          description: Base58 public key of the token mint
      responses:
        '200':
          description: Successfully retrieved the token launch
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        allOf:
                          - $ref: '#/components/schemas/TokenLaunchResponseItem'
                        nullable: true
                        description: '`null` when no token launch exists for the given mint'
        '400':
          description: Bad request - Invalid or missing tokenMint
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
    TokenLaunchResponseItem:
      type: object
      properties:
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
          description: Telegram URL or handle
          nullable: true
        twitter:
          type: string
          description: X/Twitter URL or handle
          nullable: true
        website:
          type: string
          description: Project website
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
          description: Public key of the wallet that submitted the launch
          nullable: true
        launchSignature:
          type: string
          description: Launch transaction signature
          nullable: true
        accountKeys:
          type: array
          items:
            type: string
          description: Launch transaction account keys
          nullable: true
        numRequiredSigners:
          type: number
          description: Number of required launch transaction signers
          nullable: true
        creatorFeeBps:
          type: number
          description: Creator fee in basis points
          nullable: true
        uri:
          type: string
          description: Token metadata URI
          nullable: true
        dbcPoolKey:
          type: string
          description: Meteora DBC pool address
          nullable: true
        dbcConfigKey:
          type: string
          description: Meteora DBC config address
          nullable: true
        bagsConfigType:
          type: string
          description: >-
            DBC launch mode. `null` when the token has no `dbcConfigKey`
            (pre-launch or DAMM v2 direct)
          nullable: true
        dammV2PoolKey:
          type: string
          description: DAMM v2 pool address
          nullable: true
        launchType:
          type: string
          description: Launch mechanism; missing or `null` means legacy DBC
          nullable: true
        quoteMint:
          type: string
          description: DAMM v2 direct quote mint
          nullable: true
        dammV2TreasuryPositionNftMint:
          type: string
          description: Treasury position NFT mint
          nullable: true
        dammV2FeeClaimerPositionNftMint:
          type: string
          description: Fee claimer position NFT mint
          nullable: true
        feeClaimerWallet:
          type: string
          description: Fee claimer wallet
          nullable: true
        dammV2LookupTable:
          type: string
          description: Address lookup table used by the launch
          nullable: true
        dammV2PositionCustody:
          type: string
          description: DAMM v2 position custody account
          nullable: true
        dammV2CustodyAuthority:
          type: string
          description: Authority for the DAMM v2 custody account
          nullable: true
        dammV2Partner:
          type: string
          description: Optional custody partner wallet
          nullable: true
        dammV2Deployer:
          type: string
          description: Optional custody deployer wallet
          nullable: true
        dammV2DeployerFeeCollectionMode:
          type: number
          description: Deployer fee collection mode
          nullable: true
        dammV2DeployerPlatformBps:
          type: number
          description: Deployer platform fee in basis points
          nullable: true
        dammV2DeployerClaimersBps:
          type: number
          description: Deployer claimer fee in basis points
          nullable: true
        createdAt:
          type: string
          format: date-time
          description: Record creation time
        updatedAt:
          type: string
          format: date-time
          description: Record last update time
      required:
        - name
        - symbol
        - description
        - image
        - tokenMint
        - status
        - bagsConfigType
        - createdAt
        - updatedAt
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