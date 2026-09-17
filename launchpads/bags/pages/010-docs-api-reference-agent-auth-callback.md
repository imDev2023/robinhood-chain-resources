# Bags - Complete Agent Authentication Callback

> Source: https://docs.bags.fm/api-reference/agent-auth-callback
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/agent-auth-callback.md)

---

# Complete Agent Authentication Callback

> Submit either a wallet signature callback payload or an MFA callback payload to receive an API key.



## OpenAPI

````yaml POST /agent/v2/auth/callback
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
  /agent/v2/auth/callback:
    post:
      tags:
        - Agent
      summary: Complete agent authentication callback
      description: >-
        Submit either a wallet signature callback payload or an MFA callback
        payload to receive an API key.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              oneOf:
                - $ref: '#/components/schemas/AgentAuthCallbackSignatureRequest'
                - $ref: '#/components/schemas/AgentAuthCallbackMfaRequest'
      responses:
        '200':
          description: Successfully completed callback
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        oneOf:
                          - $ref: >-
                              #/components/schemas/AgentAuthCallbackSuccessResponse
                          - $ref: >-
                              #/components/schemas/AgentAuthCallbackMfaRequiredResponse
        '400':
          description: Bad request - Invalid signature, nonce, auth code, or MFA code
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
    AgentAuthCallbackSignatureRequest:
      type: object
      properties:
        signature:
          type: string
          description: >-
            Base58-encoded Ed25519 signature of the decoded challenge message
            bytes
        address:
          type: string
          description: Solana wallet public key (base58) used to create the signature
        nonce:
          type: string
          description: Nonce returned by /agent/v2/auth/init
        keyName:
          type: string
          description: Human-readable label for the API key to be created
      required:
        - signature
        - address
        - nonce
        - keyName
    AgentAuthCallbackMfaRequest:
      type: object
      properties:
        authCode:
          type: string
          description: One-time auth code returned when MFA is required
        mfaCode:
          type: string
          description: One-time MFA verification code
        keyName:
          type: string
          description: Human-readable label for the API key to be created
      required:
        - authCode
        - mfaCode
        - keyName
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
    AgentAuthCallbackSuccessResponse:
      type: object
      properties:
        apiKey:
          type: string
          description: >-
            Newly created API key. This value is shown once and should be stored
            securely.
        keyId:
          type: string
          description: Unique identifier for the created API key
        isSignup:
          type: boolean
          description: Whether this authentication flow created a new account
      required:
        - apiKey
        - keyId
        - isSignup
    AgentAuthCallbackMfaRequiredResponse:
      type: object
      properties:
        mfaRequired:
          type: boolean
          description: Whether a second callback step with MFA is required
        mfaMethod:
          type: string
          description: MFA method requested by the server (for example, totp)
        authCode:
          type: string
          description: One-time auth code required for the MFA callback step
      required:
        - mfaRequired
        - mfaMethod
        - authCode
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