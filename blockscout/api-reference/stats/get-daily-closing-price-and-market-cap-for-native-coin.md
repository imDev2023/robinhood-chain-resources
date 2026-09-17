> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get daily closing price and market cap for native coin

> Retrieves time series data of market information (daily closing price, market cap) for rendering charts.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/stats/charts/market
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
  /{chain_id}/api/v2/stats/charts/market:
    get:
      tags:
        - stats
      summary: Get daily closing price and market cap for native coin
      description: >-
        Retrieves time series data of market information (daily closing price,
        market cap) for rendering charts.
      operationId: BlockScoutWeb.API.V2.StatsController.market_chart
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
                properties:
                  available_supply:
                    anyOf:
                      - $ref: '#/components/schemas/FloatString'
                      - type: integer
                  chart_data:
                    items:
                      type: object
                    type: array
                type: object
          description: Time series data for market charts and available token supply.
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
    FloatString:
      pattern: ^([1-9][0-9]*|0)(\.[0-9]+)?$
      title: FloatString
      type: string
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