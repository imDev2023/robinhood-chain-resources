> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Returns multichain-aggregated stats to be displayed on the main page of multichain indexer.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/stats-service/api/v1/pages/multichain/main
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
  /{chain_id}/stats-service/api/v1/pages/multichain/main:
    get:
      tags:
        - StatsService
      summary: >-
        Returns multichain-aggregated stats to be displayed on the main page of
        multichain indexer.
      operationId: StatsService_GetMainPageMultichainStats
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
                $ref: '#/components/schemas/v1MainPageMultichainStats'
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
    v1MainPageMultichainStats:
      description: >-
        Multichain-aggregated statistics for the main page of multichain
        indexer.

        Fields are optional because individual charts may be disabled.
      properties:
        new_txns_multichain_window:
          $ref: '#/components/schemas/v1LineChart'
        total_multichain_addresses:
          $ref: '#/components/schemas/v1Counter'
        total_multichain_txns:
          $ref: '#/components/schemas/v1Counter'
        yesterday_txns_multichain:
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
    v1LineChart:
      description: 'A line chart: its metadata and the series of data points.'
      properties:
        chart:
          items:
            $ref: '#/components/schemas/v1Point'
            type: object
          type: array
        info:
          $ref: '#/components/schemas/v1LineChartInfo'
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
    v1Point:
      description: |-
        A single data point on a line chart.
        All integers are encoded as strings to prevent data loss.
      properties:
        date:
          description: Start date of the period this point covers.
          type: string
        date_to:
          description: |-
            End date of the period (relevant for aggregated resolutions
            like WEEK, MONTH, YEAR; equal to `date` for DAY resolution).
          type: string
        is_approximate:
          description: |-
            True when the value is an approximation (i.e. the period is
            not yet complete).
          type: boolean
        value:
          type: string
      type: object
    v1LineChartInfo:
      description: Metadata describing a line chart.
      properties:
        description:
          type: string
        id:
          type: string
        resolutions:
          description: Available time resolutions for this chart (e.g. "DAY", "WEEK").
          items:
            type: string
          type: array
        title:
          type: string
        units:
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