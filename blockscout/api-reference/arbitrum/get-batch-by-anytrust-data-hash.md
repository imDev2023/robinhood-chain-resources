> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get batch by AnyTrust data hash.

> Retrieves an Arbitrum batch associated with the given AnyTrust data hash. By default, returns the most recently associated batch. When `type=all`, returns a paginated list of all batches referencing this data hash.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/arbitrum/batches/da/anytrust/{data_hash}
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
  /{chain_id}/api/v2/arbitrum/batches/da/anytrust/{data_hash}:
    get:
      tags:
        - arbitrum
      summary: Get batch by AnyTrust data hash.
      description: >-
        Retrieves an Arbitrum batch associated with the given AnyTrust data
        hash. By default, returns the most recently associated batch. When
        `type=all`, returns a paginated list of all batches referencing this
        data hash.
      operationId: BlockScoutWeb.API.V2.ArbitrumController.batch_by_anytrust_da_info
      parameters:
        - description: AnyTrust data hash.
          in: path
          name: data_hash
          required: true
          schema:
            $ref: '#/components/schemas/FullHash'
        - description: >-
            When set to `all`, returns a paginated list of all batches for this
            data hash.
          in: query
          name: type
          schema:
            enum:
              - all
            type: string
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
                oneOf:
                  - $ref: '#/components/schemas/Arbitrum.BatchByAnytrust'
                  - additionalProperties: false
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
          description: Batch info, or paginated batch list when `type=all`.
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
    Arbitrum.BatchByAnytrust:
      additionalProperties: false
      description: Arbitrum batch with AnyTrust data availability.
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
          $ref: '#/components/schemas/Anytrust'
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
      title: Arbitrum.BatchByAnytrust
      type: object
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
    Anytrust:
      additionalProperties: false
      description: AnyTrust data availability certificate.
      properties:
        batch_data_container:
          enum:
            - in_anytrust
          type: string
        bls_signature:
          description: Aggregated BLS signature of committee members.
          nullable: true
          type: string
        data_hash:
          description: AnyTrust data hash.
          nullable: true
          type: string
        signers:
          description: Committee members who guaranteed data availability.
          items:
            additionalProperties: false
            properties:
              key:
                description: BLS public key.
                type: string
              proof:
                description: Proof of possession (absent for trusted members).
                type: string
              trusted:
                description: Whether the signer is a trusted member.
                type: boolean
            required:
              - trusted
              - key
            type: object
          type: array
        timeout:
          description: Data availability timeout (ISO 8601).
          nullable: true
          type: string
      required:
        - batch_data_container
        - data_hash
        - timeout
        - bls_signature
        - signers
      title: Anytrust
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