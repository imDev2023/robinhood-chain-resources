> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get batch by number.

> Retrieves detailed information about a ZkSync batch by its number.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/zksync/batches/{batch_number_param}
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
  /{chain_id}/api/v2/zksync/batches/{batch_number_param}:
    get:
      tags:
        - zksync
      summary: Get batch by number.
      description: Retrieves detailed information about a ZkSync batch by its number.
      operationId: BlockScoutWeb.API.V2.ZkSyncController.batch
      parameters:
        - description: Batch number
          in: path
          name: batch_number_param
          required: true
          schema:
            minimum: 0
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
                $ref: '#/components/schemas/ZkSync.Batch'
          description: Batch info.
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
        '404':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/NotFoundResponse'
          description: Not Found
        '422':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/JsonErrorResponse'
          description: Unprocessable Entity
components:
  schemas:
    ZkSync.Batch:
      additionalProperties: false
      description: >-
        ZkSync rollup batch - a group of rollup blocks settled together on the
        parent chain - with the corresponding parent-chain lifecycle data.
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
        end_block_number:
          description: Last rollup block included in the batch.
          minimum: 0
          type: integer
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
        l1_gas_price:
          description: Parent-chain gas price observed for this batch, in wei.
          pattern: ^([1-9][0-9]*|0)$
          type: string
        l1_transactions_count:
          description: Number of transactions in the batch originating on the parent chain.
          minimum: 0
          type: integer
        l2_fair_gas_price:
          description: Rollup fair gas price for this batch, in wei.
          pattern: ^([1-9][0-9]*|0)$
          type: string
        l2_transactions_count:
          description: Number of transactions in the batch originating on the rollup.
          minimum: 0
          type: integer
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
        root_hash:
          description: State root hash committed for this batch on the parent chain.
          pattern: ^0x([A-Fa-f0-9]{64})$
          type: string
        start_block_number:
          description: First rollup block included in the batch.
          minimum: 0
          type: integer
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
        - root_hash
        - l1_transactions_count
        - l2_transactions_count
        - l1_gas_price
        - l2_fair_gas_price
        - start_block_number
        - end_block_number
      title: ZkSync.Batch
      type: object
    NotFoundResponse:
      description: Response returned when the requested resource is not found
      properties:
        message:
          description: Error message indicating the requested resource was not found
          example: Resource not found
          type: string
      title: NotFoundResponse
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