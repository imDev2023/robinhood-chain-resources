# Bags - Get DAMM v2 Vault Claimables

> Source: https://docs.bags.fm/api-reference/get-damm-v2-vault-claimables
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/get-damm-v2-vault-claimables.md)

---

# Get DAMM v2 Vault Claimables

> Every non-empty partner/deployer aggregate vault balance for a wallet. Partners and deployers do not own a DAMM v2 position directly; their revenue share accrues into a per-wallet aggregate vault (one per quote mint) that is swept with this and the claim-vault endpoint.



## OpenAPI

````yaml GET /token-launch/damm-v2/vault-claimables
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
  /token-launch/damm-v2/vault-claimables:
    get:
      tags:
        - Token Launch
      summary: Get DAMM v2 vault claimables
      description: >-
        Every non-empty partner/deployer aggregate vault balance for a wallet.
        Partners and deployers do not own a DAMM v2 position directly; their
        revenue share accrues into a per-wallet aggregate vault (one per quote
        mint) that is swept with this and the claim-vault endpoint.
      parameters:
        - name: wallet
          in: query
          required: true
          schema:
            type: string
          description: Base58 public key of the partner/deployer wallet
      responses:
        '200':
          description: Successfully retrieved vault claimables
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: >-
                          #/components/schemas/GetDammV2VaultClaimablesResponsePayload
        '400':
          description: Bad request - Invalid or missing wallet
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
    GetDammV2VaultClaimablesResponsePayload:
      type: object
      properties:
        vaults:
          type: array
          items:
            $ref: '#/components/schemas/DammV2VaultClaimable'
          description: Every non-empty partner/deployer vault balance for the given wallet
      required:
        - vaults
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
    DammV2VaultClaimable:
      type: object
      properties:
        kind:
          type: string
          enum:
            - partner
            - deployer
          description: Which aggregate vault this balance belongs to
        wallet:
          type: string
          description: Public key of the partner/deployer wallet
        quoteMint:
          type: string
          description: Public key of the quote mint this vault is denominated in
        quoteDecimals:
          type: number
          description: Decimals of the quote mint
        vaultAta:
          type: string
          description: Public key of the vault's associated token account
        claimableAmount:
          type: string
          description: >-
            Claimable balance in quote mint base units, as string to support
            bigint
        claimableDisplayAmount:
          type: number
          description: Claimable balance in whole quote tokens
      required:
        - kind
        - wallet
        - quoteMint
        - quoteDecimals
        - vaultAta
        - claimableAmount
        - claimableDisplayAmount
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````