# Bags - Get Robinhood Claimable Positions

> Source: https://docs.bags.fm/api-reference/get-rh-claimable-positions
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/get-rh-claimable-positions.md)

---

# Get Robinhood Claimable Positions

> Get every Robinhood Chain fee position the owner can act on across V1 and V2 tokens. Each position includes already-notified claimable WETH, the owner's estimated share of un-swept hook fees, lifetime claimed amounts, and claimer or partner eligibility.

`pendingWei` remains an estimate until the claim executes. When `truncated` is `true`, token discovery reached a safety bound and `positions` may be incomplete.

<Note>
  `pendingWei` is an estimate until the claim executes and sweeps accrued hook fees. When `truncated` is `true`, `positions` may be incomplete.
</Note>


## OpenAPI

````yaml GET /evm/rh/claimable-positions
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
  /evm/rh/claimable-positions:
    get:
      tags:
        - Robinhood Chain
      summary: Get claimable positions
      description: >-
        Get every Robinhood Chain fee position the owner can act on across V1
        and V2 tokens. Each position includes already-notified claimable WETH,
        the owner's estimated share of un-swept hook fees, lifetime claimed
        amounts, and claimer or partner eligibility.


        `pendingWei` remains an estimate until the claim executes. When
        `truncated` is `true`, token discovery reached a safety bound and
        `positions` may be incomplete.
      parameters:
        - name: owner
          in: query
          required: true
          schema:
            type: string
          description: >-
            Owner wallet address. Accepts any casing; normalized to EIP-55
            checksum form.
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
                        $ref: '#/components/schemas/RhClaimablePositions'
        '400':
          description: Bad request - Invalid owner address
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
    RhClaimablePositions:
      type: object
      properties:
        positions:
          type: array
          items:
            $ref: '#/components/schemas/RhClaimablePosition'
          description: Claimable fee positions discovered for the owner.
        truncated:
          type: boolean
          description: >-
            True when any token-discovery stream reached its bounded scan limit,
            so `positions` may be incomplete.
      required:
        - positions
        - truncated
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
    RhClaimablePosition:
      type: object
      properties:
        token:
          allOf:
            - $ref: '#/components/schemas/RhToken'
          description: The token associated with this claimable fee position.
        feeShare:
          type: string
          description: >-
            EIP-55 checksummed fee-share contract address that receives the
            claim transaction.
        version:
          type: string
          enum:
            - v1
            - v2
          description: Robinhood Chain protocol deployment used by the token.
        claimableWei:
          type: string
          description: >-
            Already-notified WETH that the owner can claim immediately, in wei
            as a string to support bigint.
        pendingWei:
          type: string
          description: >-
            Estimated owner share of hook fees that will be swept by the claim,
            in wei as a string to support bigint.
        actionableWei:
          type: string
          description: >-
            Sum of `claimableWei` and `pendingWei`, in wei as a string to
            support bigint. The pending component remains an estimate until the
            claim executes.
        claimedWei:
          type: string
          description: >-
            Total indexed fees already claimed by this owner from the fee-share
            contract, in wei as a string to support bigint.
        lifetimeWei:
          type: string
          description: >-
            Sum of `claimedWei` and `claimableWei`, in wei as a string to
            support bigint. Un-swept pending fees are excluded.
        isClaimer:
          type: boolean
          description: Whether the owner is a configured fee-share claimer for this token.
        isPartner:
          type: boolean
          description: Whether the owner is the token's partner.
        userBps:
          type: number
          description: >-
            The owner's current claimer allocation in basis points. Zero when
            the owner is not a claimer.
      required:
        - token
        - feeShare
        - version
        - claimableWei
        - pendingWei
        - actionableWei
        - claimedWei
        - lifetimeWei
        - isClaimer
        - isPartner
        - userBps
    RhToken:
      type: object
      properties:
        address:
          type: string
          description: EIP-55 checksummed token address.
        name:
          type: string
          description: Token name.
        symbol:
          type: string
          description: Token symbol.
        metadataURI:
          type: string
          description: Token metadata URI as stored on-chain (typically IPFS).
        metadata:
          allOf:
            - $ref: '#/components/schemas/RhTokenMetadata'
          nullable: true
          description: >-
            Backend-resolved metadata (image, description). Null when resolution
            failed or is still pending.
        curve:
          type: string
          description: Address of the token's bonding curve contract.
        feeShare:
          type: string
          description: Address of the token's fee-share contract.
        poolId:
          type: string
          description: Uniswap V4 pool ID (bytes32 hex string) assigned at launch.
        creator:
          type: string
          description: EIP-55 checksummed address of the token creator.
        partner:
          type: string
          nullable: true
          description: >-
            EIP-55 checksummed partner address. Null when the token was launched
            without a partner.
        partnerFeeBps:
          type: number
          description: >-
            Partner's share of the creator-side fee half in basis points,
            snapshotted at launch.
        createdAtBlock:
          type: number
          description: Block number of the launch transaction.
        createdAtTimestamp:
          type: number
          description: Launch time as unix seconds.
        txHash:
          type: string
          description: Transaction hash of the launch.
        migrated:
          type: boolean
          description: >-
            Whether the token has graduated from the bonding curve to its
            Uniswap V4 pool.
        migratedAtBlock:
          type: number
          nullable: true
          description: >-
            Block number of the migration. Null while the token is still
            bonding.
        migratedAtTimestamp:
          type: number
          nullable: true
          description: >-
            Migration time as unix seconds. Null while the token is still
            bonding.
      required:
        - address
        - name
        - symbol
        - metadataURI
        - metadata
        - curve
        - feeShare
        - poolId
        - creator
        - partner
        - partnerFeeBps
        - createdAtBlock
        - createdAtTimestamp
        - txHash
        - migrated
        - migratedAtBlock
        - migratedAtTimestamp
    RhTokenMetadata:
      type: object
      properties:
        image:
          type: string
          nullable: true
          description: >-
            Resolved token image URL. Null when the metadata URI could not be
            resolved.
        description:
          type: string
          nullable: true
          description: >-
            Resolved token description. Null when the metadata URI could not be
            resolved.
      required:
        - image
        - description
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````