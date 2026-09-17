# Bags - Create Robinhood Claim Transactions

> Source: https://docs.bags.fm/api-reference/create-rh-claim-txs
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/create-rh-claim-txs.md)

---

# Create Robinhood Claim Transactions

> Create unsigned EVM transactions for an owner to claim a Robinhood Chain token's accrued fees as native ETH. The response includes the current claimable and estimated pending amounts used to build the transaction.

Sign and submit `transactions` in array order, waiting for each receipt before sending the next. A token normally returns one transaction because it currently has one fee-share contract.

<Note>
  Sign and submit `transactions` in array order, waiting for each receipt before sending the next. Claims unwrap WETH to native ETH.
</Note>


## OpenAPI

````yaml POST /evm/rh/create-claim-txs
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
  /evm/rh/create-claim-txs:
    post:
      tags:
        - Robinhood Chain
      summary: Create claim transactions
      description: >-
        Create unsigned EVM transactions for an owner to claim a Robinhood Chain
        token's accrued fees as native ETH. The response includes the current
        claimable and estimated pending amounts used to build the transaction.


        Sign and submit `transactions` in array order, waiting for each receipt
        before sending the next. A token normally returns one transaction
        because it currently has one fee-share contract.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                tokenAddress:
                  type: string
                  description: >-
                    Token address. Accepts any casing; normalized to EIP-55
                    checksum form.
                owner:
                  type: string
                  description: >-
                    Owner wallet address that will sign and submit the claim
                    transaction. Accepts any casing; normalized to EIP-55
                    checksum form.
              required:
                - tokenAddress
                - owner
      responses:
        '200':
          description: Successfully created unsigned claim transactions
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/RhClaimTransactions'
        '400':
          description: >-
            Bad request - Invalid addresses, nothing to claim, or claim
            simulation failed
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
          description: >-
            Not found - The token address is not a supported Robinhood Chain
            token
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
    RhClaimTransactions:
      type: object
      properties:
        token:
          type: string
          description: EIP-55 checksummed token address associated with the claim.
        feeShare:
          type: string
          description: EIP-55 checksummed fee-share contract address the claim targets.
        version:
          type: string
          enum:
            - v1
            - v2
          description: Robinhood Chain protocol deployment used by the token.
        claimableWei:
          type: string
          description: >-
            Already-notified WETH claimable before execution, in wei as a string
            to support bigint.
        pendingWei:
          type: string
          description: >-
            Estimated owner share of hook fees swept during execution, in wei as
            a string to support bigint.
        actionableWei:
          type: string
          description: >-
            Sum of `claimableWei` and estimated `pendingWei`, in wei as a string
            to support bigint.
        chainId:
          type: number
          enum:
            - 4663
          description: Robinhood Chain ID. Always `4663`.
        unwrap:
          type: boolean
          enum:
            - true
          description: Whether claimed WETH is unwrapped to native ETH. Always `true`.
        transactions:
          type: array
          items:
            $ref: '#/components/schemas/RhClaimTransaction'
          description: >-
            Unsigned EVM transactions to sign and submit in array order, waiting
            for each receipt before sending the next.
      required:
        - token
        - feeShare
        - version
        - claimableWei
        - pendingWei
        - actionableWei
        - chainId
        - unwrap
        - transactions
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
    RhClaimTransaction:
      type: object
      properties:
        to:
          type: string
          description: >-
            EIP-55 checksummed fee-share contract address that receives the
            transaction.
        data:
          type: string
          description: ABI-encoded calldata for `BagsFeeShare.claim(true)`.
        value:
          type: string
          enum:
            - '0'
          description: Native ETH value to attach to the transaction. Always `"0"`.
        from:
          type: string
          description: >-
            EIP-55 checksummed owner address that must sign and submit the
            transaction.
        chainId:
          type: number
          enum:
            - 4663
          description: Robinhood Chain ID. Always `4663`.
      required:
        - to
        - data
        - value
        - from
        - chainId
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````