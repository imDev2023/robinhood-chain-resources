> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List batches.

> Retrieves a paginated list of batches.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/optimism/batches
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
  /{chain_id}/api/v2/optimism/batches:
    get:
      tags:
        - optimism
      summary: List batches.
      description: Retrieves a paginated list of batches.
      operationId: BlockScoutWeb.API.V2.OptimismController.batches
      parameters:
        - description: Number of items per page
          in: query
          name: items_count
          schema:
            minimum: 1
            type: integer
        - description: ID for paging
          in: query
          name: id
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
                      $ref: '#/components/schemas/Optimism.Batch'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      id: 394591
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
    Optimism.Batch:
      additionalProperties: false
      description: Optimism Batch struct.
      properties:
        batch_data_container:
          enum:
            - in_blob4844
            - in_celestia
            - in_eigenda
            - in_alt_da
            - in_calldata
          nullable: true
          type: string
        l1_timestamp:
          $ref: '#/components/schemas/Timestamp'
        l1_transaction_hashes:
          items:
            $ref: '#/components/schemas/FullHash'
          type: array
        l2_end_block_number:
          type: integer
        l2_start_block_number:
          type: integer
        number:
          type: integer
        transactions_count:
          type: integer
      required:
        - number
        - transactions_count
        - l1_timestamp
        - l1_transaction_hashes
        - batch_data_container
        - l2_end_block_number
        - l2_start_block_number
      title: Optimism.Batch
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
    Timestamp:
      format: date-time
      title: Timestamp
      type: string
    FullHash:
      pattern: ^0x([A-Fa-f0-9]{64})$
      title: FullHash
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