> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List batches.

> Retrieves a paginated list of ZkSync rollup batches, newest first.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/zksync/batches
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
  /{chain_id}/api/v2/zksync/batches:
    get:
      tags:
        - zksync
      summary: List batches.
      description: Retrieves a paginated list of ZkSync rollup batches, newest first.
      operationId: BlockScoutWeb.API.V2.ZkSyncController.batches
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
                      $ref: '#/components/schemas/ZkSync.BatchListItem'
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
    ZkSync.BatchListItem:
      additionalProperties: false
      description: ZkSync rollup batch summary for list endpoints.
      properties:
        commit_transaction_hash:
          description: >-
            Hash of the parent-chain transaction that committed this batch.
            `null` until the commit transaction is observed.
          nullable: true
          pattern: ^0x([A-Fa-f0-9]{64})$
          type: string
        commit_transaction_timestamp:
          description: >-
            Timestamp of the parent-chain transaction that committed this batch.
            `null` until the commit transaction is observed.
          format: date-time
          nullable: true
          type: string
        execute_transaction_hash:
          description: >-
            Hash of the parent-chain transaction that executed this batch.
            `null` until the execute transaction is observed.
          nullable: true
          pattern: ^0x([A-Fa-f0-9]{64})$
          type: string
        execute_transaction_timestamp:
          description: >-
            Timestamp of the parent-chain transaction that executed this batch.
            `null` until the execute transaction is observed.
          format: date-time
          nullable: true
          type: string
        number:
          description: Batch number on the rollup.
          minimum: 0
          type: integer
        prove_transaction_hash:
          description: >-
            Hash of the parent-chain transaction that proved this batch. `null`
            until the prove transaction is observed.
          nullable: true
          pattern: ^0x([A-Fa-f0-9]{64})$
          type: string
        prove_transaction_timestamp:
          description: >-
            Timestamp of the parent-chain transaction that proved this batch.
            `null` until the prove transaction is observed.
          format: date-time
          nullable: true
          type: string
        status:
          description: >
            Lifecycle status of the batch:

            * `Sealed on L2` - Batch is finalized on the rollup and no
            parent-chain lifecycle transaction has been observed yet.

            * `Sent to L1` - Commit transaction has been submitted on the parent
            chain.

            * `Validated on L1` - Prove transaction has been submitted on the
            parent chain.

            * `Executed on L1` - Execute transaction has been submitted on the
            parent chain.
          enum:
            - Executed on L1
            - Validated on L1
            - Sent to L1
            - Sealed on L2
          type: string
        timestamp:
          description: Timestamp when the batch was sealed on the rollup.
          format: date-time
          type: string
        transactions_count:
          description: >-
            Total number of transactions in the batch (parent-chain originated
            plus rollup originated).
          minimum: 0
          type: integer
      required:
        - number
        - timestamp
        - status
        - commit_transaction_hash
        - commit_transaction_timestamp
        - prove_transaction_hash
        - prove_transaction_timestamp
        - execute_transaction_hash
        - execute_transaction_timestamp
        - transactions_count
      title: ZkSync.BatchListItem
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