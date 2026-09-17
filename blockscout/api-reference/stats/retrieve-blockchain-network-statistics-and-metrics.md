> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Retrieve blockchain network statistics and metrics

> Retrieves blockchain network statistics including total blocks, transactions, addresses, average block time, market data, and network utilization.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/stats
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
  /{chain_id}/api/v2/stats:
    get:
      tags:
        - stats
      summary: Retrieve blockchain network statistics and metrics
      description: >-
        Retrieves blockchain network statistics including total blocks,
        transactions, addresses, average block time, market data, and network
        utilization.
      operationId: BlockScoutWeb.API.V2.StatsController.stats
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
                $ref: '#/components/schemas/StatsResponse'
          description: Blockchain network statistics.
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
        '422':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/JsonErrorResponse'
          description: Unprocessable Entity
components:
  schemas:
    StatsResponse:
      description: Stats response
      properties:
        average_block_time:
          format: float
          type: number
        coin_image:
          nullable: true
          type: string
        coin_price:
          $ref: '#/components/schemas/FloatStringNullable'
        coin_price_change_percentage:
          format: float
          nullable: true
          type: number
        gas_price_updated_at:
          $ref: '#/components/schemas/TimestampNullable'
        gas_prices:
          nullable: true
          type: object
        gas_prices_update_in:
          nullable: true
          type: integer
        gas_used_today:
          anyOf:
            - $ref: '#/components/schemas/IntegerStringNullable'
            - type: integer
        market_cap:
          $ref: '#/components/schemas/FloatString'
        network_utilization_percentage:
          nullable: true
          type: number
        secondary_coin_image:
          nullable: true
          type: string
        secondary_coin_price:
          $ref: '#/components/schemas/FloatStringNullable'
        static_gas_price:
          $ref: '#/components/schemas/IntegerStringNullable'
        total_addresses:
          $ref: '#/components/schemas/IntegerString'
        total_blocks:
          $ref: '#/components/schemas/IntegerString'
        total_gas_used:
          $ref: '#/components/schemas/IntegerString'
        total_transactions:
          $ref: '#/components/schemas/IntegerString'
        transactions_today:
          $ref: '#/components/schemas/IntegerString'
        tvl:
          $ref: '#/components/schemas/IntegerStringNullable'
      title: StatsResponse
      type: object
    JsonErrorResponse:
      properties:
        errors:
          items:
            properties:
              detail:
                example: null value where string expected
                type: string
              source:
                properties:
                  pointer:
                    example: /data/attributes/petName
                    type: string
                required:
                  - pointer
                type: object
              title:
                example: Invalid value
                type: string
            required:
              - title
              - source
              - detail
            type: object
          type: array
      required:
        - errors
      title: JsonErrorResponse
      type: object
    FloatStringNullable:
      nullable: true
      pattern: ^([1-9][0-9]*|0)(\.[0-9]+)?$
      title: FloatStringNullable
      type: string
    TimestampNullable:
      format: date-time
      nullable: true
      title: TimestampNullable
      type: string
    IntegerStringNullable:
      nullable: true
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerStringNullable
      type: string
    FloatString:
      pattern: ^([1-9][0-9]*|0)(\.[0-9]+)?$
      title: FloatString
      type: string
    IntegerString:
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerString
      type: string
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