# Bags - Get Robinhood Creator Fees

> Source: https://docs.bags.fm/api-reference/get-rh-creator-fees
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/get-rh-creator-fees.md)

---

# Get Robinhood Creator Fees

> Get lifetime and pending fees for a Bags V2 token on Robinhood Chain. Lifetime figures are summed from subgraph fee notifications; the pending leg is the hook's un-swept accrual. Lifetime earnings for display = notified sums + pending. Returns `404` for non-V2 tokens.

<Note>
  A token's total lifetime earnings for display = `lifetimeCreatorFeesWei` + `lifetimePartnerFeesWei` + `pendingHookFeesWei` (the un-swept accrual still sitting on the hook).
</Note>


## OpenAPI

````yaml GET /evm/rh/creator-fees
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
  /evm/rh/creator-fees:
    get:
      tags:
        - Robinhood Chain
      summary: Get creator fees
      description: >-
        Get lifetime and pending fees for a Bags V2 token on Robinhood Chain.
        Lifetime figures are summed from subgraph fee notifications; the pending
        leg is the hook's un-swept accrual. Lifetime earnings for display =
        notified sums + pending. Returns `404` for non-V2 tokens.
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
          description: Successfully retrieved creator fees
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/RhCreatorFees'
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
    RhCreatorFees:
      type: object
      properties:
        lifetimeCreatorFeesWei:
          type: string
          description: >-
            Lifetime notified creator-side fees (wei), summed from subgraph fee
            notifications, as string to support bigint.
        lifetimePartnerFeesWei:
          type: string
          description: >-
            Lifetime notified partner fees (wei), summed from subgraph fee
            notifications, as string to support bigint.
        pendingHookFeesWei:
          type: string
          description: >-
            Un-swept fee accrual currently sitting on the hook for this token's
            pool (wei), as string to support bigint. Lifetime earnings =
            notified sums + pending.
      required:
        - lifetimeCreatorFeesWei
        - lifetimePartnerFeesWei
        - pendingHookFeesWei
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