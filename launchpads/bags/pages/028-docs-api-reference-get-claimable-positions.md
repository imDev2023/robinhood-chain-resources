# Bags - Get Claimable Positions

> Source: https://docs.bags.fm/api-reference/get-claimable-positions
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/get-claimable-positions.md)

---

# Get Claimable Positions

> Retrieve all claimable fee positions for a wallet. Returns positions with fee information from virtual pools and DAMM v2.

Returns all claimable fee positions for a wallet. Use this to inspect position details and claimable amounts before claiming.

<Note>
  This endpoint is optional for claiming fees. The [v3 claim endpoint](/api-reference/get-claim-transactions-v3) handles position lookup automatically — you only need this if you want to inspect positions beforehand.
</Note>


## OpenAPI

````yaml GET /token-launch/claimable-positions
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
  /token-launch/claimable-positions:
    get:
      tags:
        - Fee Claiming
      summary: Get claimable positions
      description: >-
        Retrieve all claimable fee positions for a wallet. Returns positions
        with fee information from virtual pools and DAMM v2.
      parameters:
        - name: wallet
          in: query
          required: true
          schema:
            type: string
          description: Public key of the wallet to check for claimable positions
      responses:
        '200':
          description: Successfully retrieved claimable positions
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
                          $ref: '#/components/schemas/ClaimablePosition'
        '400':
          description: Bad request - Invalid wallet address
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
    ClaimablePosition:
      type: object
      description: >-
        Represents a claimable fee position. Structure varies based on fee share
        program version.
      properties:
        programId:
          type: string
          description: Fee share program ID (v1 or v2)
        isCustomFeeVault:
          type: boolean
          description: Whether this position uses a custom fee vault
        baseMint:
          type: string
          description: Base token mint public key
        quoteMint:
          type: string
          description: Quote token mint public key (for v2)
          nullable: true
        virtualPool:
          type: string
          description: Virtual pool address
        virtualPoolAddress:
          type: string
          description: Virtual pool address (alternative field name)
          nullable: true
        virtualPoolClaimableAmount:
          type: number
          description: Claimable amount from virtual pool (v1)
          nullable: true
        virtualPoolClaimableLamportsUserShare:
          type: number
          description: User's share of claimable lamports from virtual pool (v2)
          nullable: true
        dammPoolClaimableAmount:
          type: number
          description: Claimable amount from DAMM pool (v1)
          nullable: true
        dammPoolClaimableLamportsUserShare:
          type: number
          description: User's share of claimable lamports from DAMM pool (v2)
          nullable: true
        isMigrated:
          type: boolean
          description: Whether the pool has migrated to DAMM v2
        dammPoolAddress:
          type: string
          description: DAMM pool address
          nullable: true
        dammPositionInfo:
          $ref: '#/components/schemas/DammPositionInfo'
          nullable: true
        totalClaimableLamportsUserShare:
          type: number
          description: Total claimable lamports for the user
        claimableDisplayAmount:
          type: number
          description: Human-readable claimable amount
          nullable: true
        user:
          type: string
          description: User wallet address (v2)
          nullable: true
        claimerIndex:
          type: number
          description: Index of the claimer in the config (v2)
          nullable: true
        userBps:
          type: number
          description: User's basis points allocation (v2)
          nullable: true
        customFeeVault:
          type: string
          description: Custom fee vault address (v1)
          nullable: true
        customFeeVaultClaimerA:
          type: string
          description: Custom fee vault claimer A (v1)
          nullable: true
        customFeeVaultClaimerB:
          type: string
          description: Custom fee vault claimer B (v1)
          nullable: true
        customFeeVaultClaimerSide:
          type: string
          enum:
            - A
            - B
          description: Which side of the custom fee vault the user is on (v1)
          nullable: true
      required:
        - isCustomFeeVault
        - baseMint
        - isMigrated
        - totalClaimableLamportsUserShare
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
    DammPositionInfo:
      type: object
      properties:
        position:
          type: string
          description: DAMM v2 position public key
        pool:
          type: string
          description: DAMM v2 pool public key
        positionNftAccount:
          type: string
          description: Position NFT account public key
        tokenAMint:
          type: string
          description: Token A mint public key
        tokenBMint:
          type: string
          description: Token B mint public key
        tokenAVault:
          type: string
          description: Token A vault public key
        tokenBVault:
          type: string
          description: Token B vault public key
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````