# Bags - Get Token Claim Events

> Source: https://docs.bags.fm/api-reference/get-token-claim-events
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/api-reference/get-token-claim-events.md)

---

# Get Token Claim Events

> Retrieve claim events for a specific token. Supports two query modes:

**Offset Mode** (default): Use `mode=offset` (or omit mode) with `limit` and `offset` for traditional pagination.

**Time Mode**: Use `mode=time` with `from` and `to` unix timestamps to retrieve events within a specific time range.

Retrieve claim events for a specific token. This endpoint supports two query modes to give you flexibility in how you fetch claim data.

## Query Modes

### Offset Mode (Default)

Use offset-based pagination to retrieve claim events in batches. This is the default mode and is backward compatible with previous API versions.

```bash theme={null}
curl --request GET \
  --url 'https://public-api-v2.bags.fm/api/v1/fee-share/token/claim-events?tokenMint=YOUR_TOKEN_MINT&mode=offset&limit=50&offset=0' \
  --header 'x-api-key: YOUR_API_KEY'
```

<ParamField query="mode" type="string" default="offset">
  Set to `offset` or omit entirely for pagination mode.
</ParamField>

<ParamField query="limit" type="integer" default="100">
  Maximum number of events to return (1-100).
</ParamField>

<ParamField query="offset" type="integer" default="0">
  Number of events to skip for pagination.
</ParamField>

### Time Mode

Use time-based filtering to retrieve all claim events within a specific time range. Useful for analytics dashboards, scheduled reports, or syncing historical data.

```bash theme={null}
curl --request GET \
  --url 'https://public-api-v2.bags.fm/api/v1/fee-share/token/claim-events?tokenMint=YOUR_TOKEN_MINT&mode=time&from=1704067200&to=1706745600' \
  --header 'x-api-key: YOUR_API_KEY'
```

<ParamField query="mode" type="string" required>
  Must be set to `time` for time-based filtering.
</ParamField>

<ParamField query="from" type="integer" required>
  Start unix timestamp (inclusive). Must be greater than or equal to 0.
</ParamField>

<ParamField query="to" type="integer" required>
  End unix timestamp (inclusive). Must be greater than or equal to `from`.
</ParamField>

<Note>
  When using time mode, the `from` timestamp must be less than or equal to `to`. The API will return an error if this constraint is violated.
</Note>

## Use Cases

* **Offset Mode**: Best for building paginated UIs, real-time feeds, or when you need the most recent events.
* **Time Mode**: Best for analytics, generating reports for specific periods, auditing, or syncing claim history.

For a complete implementation example, see the [Get Token Claim Events](/how-to-guides/get-token-claim-events) how-to guide.


## OpenAPI

````yaml GET /fee-share/token/claim-events
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
  /fee-share/token/claim-events:
    get:
      tags:
        - Analytics
      summary: Get token claim events
      description: >-
        Retrieve claim events for a specific token. Supports two query modes:


        **Offset Mode** (default): Use `mode=offset` (or omit mode) with `limit`
        and `offset` for traditional pagination.


        **Time Mode**: Use `mode=time` with `from` and `to` unix timestamps to
        retrieve events within a specific time range.
      parameters:
        - name: tokenMint
          in: query
          required: true
          schema:
            type: string
          description: Public key of the token mint
        - name: mode
          in: query
          required: false
          schema:
            type: string
            enum:
              - offset
              - time
            default: offset
          description: >-
            Query mode: 'offset' for pagination (default), 'time' for time-based
            filtering
        - name: limit
          in: query
          required: false
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 100
          description: >-
            Maximum number of events to return (1-100, default: 100). Only used
            with mode=offset
        - name: offset
          in: query
          required: false
          schema:
            type: integer
            minimum: 0
            default: 0
          description: >-
            Number of events to skip for pagination (default: 0). Only used with
            mode=offset
        - name: from
          in: query
          required: false
          schema:
            type: integer
            minimum: 0
          description: Start unix timestamp (inclusive). Required when mode=time
        - name: to
          in: query
          required: false
          schema:
            type: integer
            minimum: 0
          description: >-
            End unix timestamp (inclusive). Required when mode=time. Must be
            greater than or equal to 'from'
      responses:
        '200':
          description: Successfully retrieved token claim events
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/SuccessResponse'
                  - type: object
                    properties:
                      response:
                        $ref: '#/components/schemas/TokenClaimEventsResponse'
        '400':
          description: Bad request - Invalid token mint or parameters
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/GetTokenClaimEventsErrorResponse'
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
                $ref: '#/components/schemas/GetTokenClaimEventsErrorResponse'
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
    TokenClaimEventsResponse:
      type: object
      properties:
        events:
          type: array
          items:
            $ref: '#/components/schemas/TokenClaimEvent'
          description: Array of claim events
      required:
        - events
    GetTokenClaimEventsErrorResponse:
      type: object
      properties:
        success:
          type: boolean
          example: false
          enum:
            - false
        response:
          type: string
          description: Error message
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
    TokenClaimEvent:
      type: object
      properties:
        wallet:
          type: string
          description: Public key of the wallet that claimed fees
        isCreator:
          type: boolean
          description: Whether this wallet is the token creator
        amount:
          type: string
          description: Amount claimed in lamports (as string to support bigint)
        signature:
          type: string
          description: Transaction signature of the claim
        timestamp:
          type: string
          description: ISO 8601 timestamp of the claim event
      required:
        - wallet
        - isCreator
        - amount
        - signature
        - timestamp
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: API key authentication. Provide your API key as the header value.

````