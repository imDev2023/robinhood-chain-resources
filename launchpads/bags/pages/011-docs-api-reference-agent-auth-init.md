# Bags - Initialize Agent Authentication

> Source: https://docs.bags.fm/api-reference/agent-auth-init
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/agent-auth-init.md)

---

# Initialize Agent Authentication

> Generate a signable challenge message and nonce for wallet-signature based agent authentication.



## OpenAPI

````yaml POST /agent/v2/auth/init
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
  /agent/v2/auth/init:
    post:
      tags:
        - Agent
      summary: Initialize agent authentication
      description: >-
        Generate a signable challenge message and nonce for wallet-signature
        based agent authentication.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/AgentAuthInitRequest'
      responses:
        '200':
          description: Successfully generated wallet challenge
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/AgentAuthInitResponse'
        '400':
          description: Bad request - Invalid wallet address or request payload
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
        '429':
          description: Too many requests - Rate limit exceeded
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
      security: []
components:
  schemas:
    AgentAuthInitRequest:
      type: object
      properties:
        address:
          type: string
          description: >-
            Solana wallet public key (base58) that will sign the authentication
            challenge
      required:
        - address
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
    AgentAuthInitResponse:
      type: object
      properties:
        message:
          type: string
          description: >-
            Base58-encoded challenge message. Decode to raw bytes before signing
            with Ed25519.
        nonce:
          type: string
          description: Single-use authentication nonce tied to the challenge message
      required:
        - message
        - nonce
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