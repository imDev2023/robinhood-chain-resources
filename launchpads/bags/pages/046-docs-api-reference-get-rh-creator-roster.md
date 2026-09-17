# Bags - Get Robinhood Creator Roster

> Source: https://docs.bags.fm/api-reference/get-rh-creator-roster
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/get-rh-creator-roster.md)

---

# Get Robinhood Creator Roster

> Get the full fee-share roster for a Bags V2 token on Robinhood Chain — every recipient with claimed, claimable, and estimated pending amounts. Combines the fee-share claimer list, live claimable per recipient, the partner and rate from the hook snapshot, per-recipient claim sums from the subgraph, and the estimated pending split. Returns `404` for non-V2 tokens.



## OpenAPI

````yaml GET /evm/rh/creator-roster
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
  /evm/rh/creator-roster:
    get:
      tags:
        - Robinhood Chain
      summary: Get creator roster
      description: >-
        Get the full fee-share roster for a Bags V2 token on Robinhood Chain —
        every recipient with claimed, claimable, and estimated pending amounts.
        Combines the fee-share claimer list, live claimable per recipient, the
        partner and rate from the hook snapshot, per-recipient claim sums from
        the subgraph, and the estimated pending split. Returns `404` for non-V2
        tokens.
      parameters:
        - name: tokenAddress
          in: query
          required: true
          schema:
            type: string
          description: >-
            Token address. Accepts any casing; normalized to EIP-55 checksum
            form.
      responses:
        '200':
          description: Successfully retrieved creator roster
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/RhCreatorRoster'
        '400':
          description: Bad request - Invalid token address
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
    RhCreatorRoster:
      type: object
      properties:
        token:
          type: string
          description: EIP-55 checksummed token address.
        feeShare:
          type: string
          description: Address of the token's fee-share contract.
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
        recipients:
          type: array
          items:
            $ref: '#/components/schemas/RhCreatorRosterRecipient'
          description: >-
            Every fee-share recipient with claimed, claimable, and estimated
            pending amounts.
      required:
        - token
        - feeShare
        - partner
        - partnerFeeBps
        - recipients
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
    RhCreatorRosterRecipient:
      type: object
      properties:
        address:
          type: string
          description: EIP-55 checksummed recipient address.
        bps:
          type: number
          description: >-
            Share in basis points: of the claimer pot for claimers, of the
            creator half for the partner.
        isPartner:
          type: boolean
          description: Whether this recipient is the token's partner.
        claimedWei:
          type: string
          description: >-
            Total already claimed by this recipient on this fee share (wei), as
            string to support bigint.
        claimableWei:
          type: string
          description: >-
            Live claimable amount for this recipient (wei), as string to support
            bigint.
        pendingWei:
          type: string
          description: >-
            This recipient's estimated share of the un-swept pending hook fees
            (wei), as string to support bigint.
      required:
        - address
        - bps
        - isPartner
        - claimedWei
        - claimableWei
        - pendingWei
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````