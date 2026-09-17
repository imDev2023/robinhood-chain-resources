> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Returns stats to be displayed on the transactions page.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/stats-service/api/v1/pages/transactions
openapi: 3.0.0
info:
  contact:
    email: info@blockscout.com
    url: https://dev.blockscout.com/
  description: >-
    Blockscout's universal multichain API for accessing explorer-indexed
    blockchain data - such as addresses, transactions, blocks, tokens, NFTs,
    contracts, and related search/results endpoints - across supported networks
    through a single standardized interface.
  title: Blockscout Pro API
  version: 0.5.0
servers:
  - url: https://api.blockscout.com
security:
  - bearerAuth: []
  - apiKeyAuth: []
paths:
  /{chain_id}/stats-service/api/v1/pages/transactions:
    get:
      tags:
        - StatsService
      summary: Returns stats to be displayed on the transactions page.
      operationId: StatsService_GetTransactionsPageStats
      parameters:
        - description: The ID of the blockchain
          in: path
          name: chain_id
          required: true
          schema:
            type: string
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1TransactionsPageStats'
          description: A successful response.
          headers:
            x-credits-remaining:
              description: >-
                Number of credits remaining in your plan. Resets daily on the
                free plan, monthly otherwise.
              schema:
                type: integer
            x-ratelimit-limit:
              description: >-
                Available requests per second with your plan. Returns -1 on
                internal error.
              schema:
                type: integer
            x-ratelimit-remaining:
              description: >-
                Remaining rate limit based on your queries. Returns -1 on
                internal error.
              schema:
                type: integer
            x-ratelimit-reset:
              description: >-
                Time in milliseconds until the rate limit resets. Returns -1 on
                internal error.
              schema:
                type: integer
        default:
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/googlerpcStatus'
          description: An unexpected error response.
components:
  schemas:
    v1TransactionsPageStats:
      description: |-
        Pre-assembled set of statistics for the transactions page.
        Fields are optional because individual charts may be disabled.
      properties:
        average_transactions_fee_24h:
          $ref: '#/components/schemas/v1Counter'
        new_zetachain_cross_chain_txns_24h:
          $ref: '#/components/schemas/v1Counter'
        op_stack_operational_transactions_24h:
          $ref: '#/components/schemas/v1Counter'
        operational_transactions_24h:
          $ref: '#/components/schemas/v1Counter'
        pending_transactions_30m:
          $ref: '#/components/schemas/v1Counter'
        pending_zetachain_cross_chain_txns:
          $ref: '#/components/schemas/v1Counter'
        total_zetachain_cross_chain_txns:
          $ref: '#/components/schemas/v1Counter'
        transactions_24h:
          $ref: '#/components/schemas/v1Counter'
        transactions_fee_24h:
          $ref: '#/components/schemas/v1Counter'
      type: object
    googlerpcStatus:
      properties:
        code:
          format: int32
          type: integer
        details:
          items:
            $ref: '#/components/schemas/protobufAny'
            type: object
          type: array
        message:
          type: string
      type: object
    v1Counter:
      properties:
        description:
          type: string
        id:
          type: string
        title:
          type: string
        units:
          description: Measurement units (e.g. "seconds", "ETH"), if applicable.
          type: string
        value:
          type: string
      type: object
    protobufAny:
      additionalProperties:
        path: >-
          /{chain_id}/api/v2/tokens/{address_hash_param}/instances/{token_id_param}/refetch-metadata
      properties:
        '@type':
          type: string
      type: object
  securitySchemes:
    bearerAuth:
      bearerFormat: JWT
      description: API key passed as a Bearer token in the Authorization header.
      scheme: bearer
      type: http
    apiKeyAuth:
      description: API key passed as the `apikey` query parameter.
      in: query
      name: apikey
      type: apiKey

````