> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get batch by Celestia blob reference.

> Retrieves an Arbitrum batch whose data availability blob is identified by the given Celestia block height and transaction commitment hash.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/arbitrum/batches/da/celestia/{height}/{transaction_commitment}
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
  /{chain_id}/api/v2/arbitrum/batches/da/celestia/{height}/{transaction_commitment}:
    get:
      tags:
        - arbitrum
      summary: Get batch by Celestia blob reference.
      description: >-
        Retrieves an Arbitrum batch whose data availability blob is identified
        by the given Celestia block height and transaction commitment hash.
      operationId: BlockScoutWeb.API.V2.ArbitrumController.batch_by_celestia_da_info
      parameters:
        - description: Celestia block height.
          in: path
          name: height
          required: true
          schema:
            minimum: 0
            type: integer
        - description: Celestia transaction commitment hash.
          in: path
          name: transaction_commitment
          required: true
          schema:
            $ref: '#/components/schemas/FullHash'
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
                $ref: '#/components/schemas/Arbitrum.BatchByCelestia'
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
    FullHash:
      pattern: ^0x([A-Fa-f0-9]{64})$
      title: FullHash
      type: string
    Arbitrum.BatchByCelestia:
      additionalProperties: false
      description: Arbitrum batch with Celestia data availability.
      properties:
        after_acc_hash:
          description: >-
            Accumulator hash of the sequencer inbox after this batch was
            appended. Must equal `before_acc_hash` of the next batch.
          pattern: ^0x([A-Fa-f0-9]{64})$
          type: string
        before_acc_hash:
          description: >-
            Accumulator hash of the sequencer inbox before this batch was
            appended. Forms a hash chain: must equal `after_acc_hash` of the
            previous batch.
          pattern: ^0x([A-Fa-f0-9]{64})$
          type: string
        commitment_transaction:
          $ref: '#/components/schemas/CommitmentTransaction'
        data_availability:
          $ref: '#/components/schemas/Celestia'
        end_block_number:
          description: Last Rollup block included in the batch.
          minimum: 0
          type: integer
        number:
          description: Sequential identifier assigned to this batch by the sequencer.
          minimum: 0
          type: integer
        start_block_number:
          description: First Rollup block included in the batch.
          minimum: 0
          type: integer
        transactions_count:
          description: Number of transactions in the batch.
          minimum: 0
          type: integer
      required:
        - number
        - transactions_count
        - start_block_number
        - end_block_number
        - before_acc_hash
        - after_acc_hash
        - commitment_transaction
        - data_availability
      title: Arbitrum.BatchByCelestia
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
    Celestia:
      additionalProperties: false
      description: Celestia data availability blob reference.
      properties:
        batch_data_container:
          enum:
            - in_celestia
          type: string
        height:
          description: Celestia block height.
          nullable: true
          type: integer
        transaction_commitment:
          description: Celestia transaction commitment hash.
          nullable: true
          type: string
      required:
        - batch_data_container
        - height
        - transaction_commitment
      title: Celestia
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