# Bags - Create DAMM v2 Launch Transaction

> Source: https://docs.bags.fm/api-reference/create-damm-v2-launch-transaction
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/create-damm-v2-launch-transaction.md)

---

# Create DAMM v2 Launch Transaction

> Builds the partially-signed transaction bundle that launches a token previously registered via `POST /token-launch/create-token-info` straight into a single-sided DAMM v2 customizable pool (no DBC bonding curve, no migration). The token's launch status must still be `PRE_LAUNCH`. Every transaction in the bundle must be co-signed by `wallet` before submission; see the bundle item `type` for submission order (`LUT_SETUP` and `CREATE_TOKEN` first, then `LAUNCH`, then optionally `LUT_DEACTIVATE`/`LUT_CLOSE`).

## Submission order

The response bundle can contain up to five transactions. Submit them in this order:

1. **`LUT_SETUP`** and **`CREATE_TOKEN`** — independent; submit both (in parallel is fine) and wait for both to confirm. `LUT_SETUP` creates the address lookup table `LAUNCH` depends on; a lookup table is only usable starting the slot *after* it is extended, so confirming this before submitting `LAUNCH` is required. `CREATE_TOKEN` is omitted from the bundle on rebuilds where the mint already landed on-chain.
2. **`LAUNCH`** — atomic: initializes the pool, deposits both locked positions, and executes the optional initial buy. Trading is live the moment this lands. If the first submission races the lookup-table warmup, retry once the table has warmed up.
3. **`LUT_DEACTIVATE`** — deactivates the lookup table. Submit only after `LAUNCH` confirms. Carries no server signature — replace `recentBlockhash` with a fresh one right before signing.
4. **`LUT_CLOSE`** (optional) — reclaims the lookup table rent. Only valid for a window starting shortly after `LUT_DEACTIVATE`. Carries no server signature — replace `recentBlockhash` with a fresh one right before signing.

Every transaction must be co-signed by `wallet`. If the bundle's blockhash expires before `LAUNCH` lands, request a new bundle rather than resubmitting — nothing partial is left on-chain.


## OpenAPI

````yaml POST /token-launch/damm-v2/create-transaction
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
  /token-launch/damm-v2/create-transaction:
    post:
      tags:
        - Token Launch
      summary: Create DAMM v2 direct launch transaction
      description: >-
        Builds the partially-signed transaction bundle that launches a token
        previously registered via `POST /token-launch/create-token-info`
        straight into a single-sided DAMM v2 customizable pool (no DBC bonding
        curve, no migration). The token's launch status must still be
        `PRE_LAUNCH`. Every transaction in the bundle must be co-signed by
        `wallet` before submission; see the bundle item `type` for submission
        order (`LUT_SETUP` and `CREATE_TOKEN` first, then `LAUNCH`, then
        optionally `LUT_DEACTIVATE`/`LUT_CLOSE`).
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                ipfs:
                  type: string
                  maxLength: 200
                  description: Metadata URI from the create-token-info endpoint
                tokenMint:
                  type: string
                  description: Mint from the create-token-info endpoint
                wallet:
                  type: string
                  description: >-
                    Launch wallet; fee payer and signer of every transaction in
                    the bundle
                quoteMint:
                  type: string
                  description: Badged quote mint (see the supported quote tokens endpoint)
                feeClaimerWallet:
                  type: string
                  description: Receives the 50% fee position NFT; defaults to `wallet`
                initialBuyQuoteAmount:
                  type: integer
                  description: >-
                    Initial buy amount in quote mint base units; `wallet` must
                    already hold at least this quote balance at build time
                partner:
                  type: string
                  description: >-
                    Existing PartnerConfig wallet to attach to the custody (its
                    global bps applies)
              required:
                - ipfs
                - tokenMint
                - wallet
                - quoteMint
      responses:
        '200':
          description: Successfully built the launch transaction bundle
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: >-
                          #/components/schemas/CreateDammV2LaunchTransactionResponsePayload
        '400':
          description: >-
            Bad request - Invalid parameters, token already launched, quote mint
            not supported, or insufficient initial-buy balance
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
        '403':
          description: Forbidden - Token launch does not belong to this caller
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
    CreateDammV2LaunchTransactionResponsePayload:
      type: object
      properties:
        transactions:
          type: array
          items:
            $ref: '#/components/schemas/DammV2LaunchTransactionBundleItem'
          description: >-
            Ordered transaction bundle; see the endpoint description for
            submission order
        launch:
          $ref: '#/components/schemas/DammV2LaunchDetails'
      required:
        - transactions
        - launch
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
    DammV2LaunchTransactionBundleItem:
      type: object
      properties:
        type:
          type: string
          enum:
            - LUT_SETUP
            - CREATE_TOKEN
            - LAUNCH
            - LUT_DEACTIVATE
            - LUT_CLOSE
          description: Which step of the launch bundle this transaction performs
        transaction:
          type: string
          description: Base58-encoded serialized transaction
      required:
        - type
        - transaction
    DammV2LaunchDetails:
      type: object
      properties:
        tokenMint:
          type: string
          description: Public key of the token mint
        quoteMint:
          type: string
          description: Public key of the quote mint
        quoteTokenProgram:
          type: string
          description: Token program that owns the quote mint
        pool:
          type: string
          description: Public key of the DAMM v2 pool
        treasuryPositionNftMint:
          type: string
          description: Treasury (platform) locked position NFT mint
        feeClaimerPositionNftMint:
          type: string
          description: Fee claimer (creator) locked position NFT mint
        feeClaimerWallet:
          type: string
          description: Wallet recorded as the fee claimer recipient
        lookupTable:
          type: string
          description: Address lookup table used by the launch transactions
        positionCustody:
          type: string
          description: Fee-share position custody account holding both locked positions
        custodyAuthority:
          type: string
          description: Authority for the position custody account
        launchPriceQuotePerToken:
          type: number
          description: Launch price in quote units per token
        impliedLaunchFdvUsd:
          type: number
          description: Implied fully-diluted valuation in USD at launch price
      required:
        - tokenMint
        - quoteMint
        - quoteTokenProgram
        - pool
        - treasuryPositionNftMint
        - feeClaimerPositionNftMint
        - feeClaimerWallet
        - lookupTable
        - positionCustody
        - custodyAuthority
        - launchPriceQuotePerToken
        - impliedLaunchFdvUsd
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````