# Bags - Claim DAMM v2 Vault

> Source: https://docs.bags.fm/api-reference/claim-damm-v2-vault
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/claim-damm-v2-vault.md)

---

# Claim DAMM v2 Vault

> Sweeps the caller's partner or deployer aggregate vault for a quote mint to their wallet. Returns a gas-sponsored transaction: the gas sponsor is the fee payer, and the partner/deployer wallet co-signs client-side as the authorizer.



## OpenAPI

````yaml POST /token-launch/damm-v2/claim-vault
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
  /token-launch/damm-v2/claim-vault:
    post:
      tags:
        - Token Launch
      summary: Claim DAMM v2 vault
      description: >-
        Sweeps the caller's partner or deployer aggregate vault for a quote mint
        to their wallet. Returns a gas-sponsored transaction: the gas sponsor is
        the fee payer, and the partner/deployer wallet co-signs client-side as
        the authorizer.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                kind:
                  type: string
                  enum:
                    - partner
                    - deployer
                  description: Which aggregate vault to sweep
                wallet:
                  type: string
                  description: >-
                    The partner/deployer wallet whose vault is being swept (also
                    the destination)
                quoteMint:
                  type: string
                  description: Quote mint of the vault to sweep
              required:
                - kind
                - wallet
                - quoteMint
      responses:
        '200':
          description: Successfully built the claim transaction
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/ClaimDammV2VaultResponsePayload'
        '400':
          description: Bad request - Invalid parameters, or nothing to claim
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
    ClaimDammV2VaultResponsePayload:
      type: object
      properties:
        transaction:
          type: string
          description: >-
            Base58-encoded, gas-sponsored transaction that drains the vault to
            the wallet's ATA. The gas sponsor is the fee payer; the
            partner/deployer wallet co-signs client-side as the authorizer.
        claimable:
          $ref: '#/components/schemas/DammV2VaultClaimable'
      required:
        - transaction
        - claimable
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