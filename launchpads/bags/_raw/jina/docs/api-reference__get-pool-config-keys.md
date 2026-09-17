> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Pool Config Keys by Fee Claimer Vaults

> Given a list of fee claimer vault public keys, returns the first Meteora DBC pool config key for each if present.

WARNING: This function will assume there is only one config key for a fee claimer vault. If this is used for non bags-fee-share fee claimer vault, it will return the first config key found.



## OpenAPI

````yaml POST /token-launch/state/pool-config
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
  /token-launch/state/pool-config:
    post:
      tags:
        - State
      summary: Get pool config keys by fee claimer vaults
      description: >-
        Given a list of fee claimer vault public keys, returns the first Meteora
        DBC pool config key for each if present.


        WARNING: This function will assume there is only one config key for a
        fee claimer vault. If this is used for non bags-fee-share fee claimer
        vault, it will return the first config key found.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/GetPoolConfigKeyByFeeClaimerVaultRequest'
      responses:
        '200':
          description: Successfully retrieved pool config keys
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: >-
                          #/components/schemas/GetPoolConfigKeyByFeeClaimerVaultResponse
        '400':
          description: Bad request - Invalid parameters
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
    GetPoolConfigKeyByFeeClaimerVaultRequest:
      type: object
      properties:
        feeClaimerVaults:
          type: array
          items:
            type: string
            description: Public key of a fee claimer vault
          description: List of fee claimer vault public keys to query
      required:
        - feeClaimerVaults
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
    GetPoolConfigKeyByFeeClaimerVaultResponse:
      type: object
      properties:
        poolConfigKeys:
          type: array
          items:
            type: string
            nullable: true
            description: >-
              First matching Meteora DBC pool config key for the corresponding
              fee claimer vault, or null if none found
          description: >-
            Array aligned with input fee claimer vaults, containing first found
            pool config keys when present
      required:
        - poolConfigKeys
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