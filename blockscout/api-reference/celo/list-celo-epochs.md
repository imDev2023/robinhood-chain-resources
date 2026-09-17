> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List Celo epochs.

> Retrieves a paginated list of Celo epochs.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/celo/epochs
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
  /{chain_id}/api/v2/celo/epochs:
    get:
      tags:
        - celo
      summary: List Celo epochs.
      description: Retrieves a paginated list of Celo epochs.
      operationId: BlockScoutWeb.API.V2.CeloController.epochs
      parameters:
        - description: Number of items per page
          in: query
          name: items_count
          schema:
            minimum: 1
            type: integer
        - description: Number for paging
          in: query
          name: number
          schema:
            type: integer
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
                additionalProperties: false
                properties:
                  items:
                    items:
                      $ref: '#/components/schemas/Epoch'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      number: 100
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                type: object
          description: List of Celo epochs.
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
    Epoch:
      additionalProperties: false
      description: Celo epoch summary.
      properties:
        distribution:
          additionalProperties: true
          nullable: true
          type: object
        end_block_number:
          minimum: 0
          type: integer
        is_finalized:
          type: boolean
        number:
          minimum: 0
          type: integer
        start_block_number:
          minimum: 0
          type: integer
        timestamp:
          $ref: '#/components/schemas/TimestampNullable'
        type:
          enum:
            - L1
            - L2
          type: string
      required:
        - number
        - type
        - start_block_number
        - end_block_number
        - timestamp
        - is_finalized
        - distribution
      title: Epoch
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
    TimestampNullable:
      format: date-time
      nullable: true
      title: TimestampNullable
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