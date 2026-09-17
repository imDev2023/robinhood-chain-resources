> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List batches.

> Retrieves a paginated list of Arbitrum batches committed to the Parent chain.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/arbitrum/batches
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
  /{chain_id}/api/v2/arbitrum/batches:
    get:
      tags:
        - arbitrum
      summary: List batches.
      description: >-
        Retrieves a paginated list of Arbitrum batches committed to the Parent
        chain.
      operationId: BlockScoutWeb.API.V2.ArbitrumController.batches
      parameters:
        - description: Optional list of specific batch numbers to retrieve.
          in: query
          name: batch_numbers
          schema:
            items:
              minimum: 0
              type: integer
            type: array
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
                      $ref: '#/components/schemas/BatchForList'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      number: 123
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                type: object
          description: Paginated list of Arbitrum batches.
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
    BatchForList:
      additionalProperties: false
      description: Arbitrum batch summary for list endpoints.
      properties:
        batch_data_container:
          $ref: '#/components/schemas/BatchDataContainer'
        blocks_count:
          description: Number of blocks included in the batch.
          minimum: 0
          type: integer
        commitment_transaction:
          $ref: '#/components/schemas/CommitmentTransaction'
        number:
          description: Sequential identifier assigned to this batch by the sequencer.
          minimum: 0
          type: integer
        transactions_count:
          description: Number of transactions in the batch.
          minimum: 0
          type: integer
      required:
        - number
        - transactions_count
        - blocks_count
        - batch_data_container
        - commitment_transaction
      title: BatchForList
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
    BatchDataContainer:
      description: Data availability container type.
      enum:
        - in_blob4844
        - in_calldata
        - in_celestia
        - in_anytrust
        - in_eigenda
      nullable: true
      title: BatchDataContainer
      type: string
    CommitmentTransaction:
      additionalProperties: false
      description: Parent chain transaction that committed the batch.
      properties:
        block_number:
          description: Parent chain block number containing this transaction.
          minimum: 0
          nullable: true
          type: integer
        hash:
          $ref: '#/components/schemas/FullHashNullable'
        status:
          description: Finalization status of the Parent chain transaction.
          enum:
            - unfinalized
            - finalized
          nullable: true
          type: string
        timestamp:
          $ref: '#/components/schemas/TimestampNullable'
      required:
        - hash
        - block_number
        - timestamp
        - status
      title: CommitmentTransaction
      type: object
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