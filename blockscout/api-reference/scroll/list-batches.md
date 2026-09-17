> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List batches.

> Retrieves a paginated list of batches.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/scroll/batches
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
  /{chain_id}/api/v2/scroll/batches:
    get:
      tags:
        - scroll
      summary: List batches.
      description: Retrieves a paginated list of batches.
      operationId: BlockScoutWeb.API.V2.ScrollController.batches
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
                      $ref: '#/components/schemas/Scroll.Batch'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      number: 502655
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                type: object
          description: List of batches.
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
    Scroll.Batch:
      additionalProperties: false
      description: Scroll Batch struct.
      properties:
        commitment_transaction:
          additionalProperties: false
          properties:
            block_number:
              type: integer
            hash:
              $ref: '#/components/schemas/FullHash'
            timestamp:
              $ref: '#/components/schemas/Timestamp'
          required:
            - block_number
            - hash
            - timestamp
          type: object
        confirmation_transaction:
          additionalProperties: false
          properties:
            block_number:
              nullable: true
              type: integer
            hash:
              $ref: '#/components/schemas/FullHashNullable'
            timestamp:
              $ref: '#/components/schemas/TimestampNullable'
          required:
            - block_number
            - hash
            - timestamp
          type: object
        data_availability:
          additionalProperties: false
          properties:
            batch_data_container:
              enum:
                - in_blob4844
                - in_calldata
              type: string
          required:
            - batch_data_container
          type: object
        end_block_number:
          nullable: true
          type: integer
        number:
          type: integer
        start_block_number:
          nullable: true
          type: integer
        transactions_count:
          nullable: true
          type: integer
      required:
        - number
        - transactions_count
        - start_block_number
        - end_block_number
        - data_availability
        - commitment_transaction
        - confirmation_transaction
      title: Scroll.Batch
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
    FullHash:
      pattern: ^0x([A-Fa-f0-9]{64})$
      title: FullHash
      type: string
    Timestamp:
      format: date-time
      title: Timestamp
      type: string
    FullHashNullable:
      nullable: true
      pattern: ^0x([A-Fa-f0-9]{64})$
      title: FullHashNullable
      type: string
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