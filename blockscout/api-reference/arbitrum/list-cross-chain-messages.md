> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List cross-chain messages.

> Retrieves a paginated list of Arbitrum cross-chain messages filtered by the specified direction.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/arbitrum/messages/{direction}
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
  /{chain_id}/api/v2/arbitrum/messages/{direction}:
    get:
      tags:
        - arbitrum
      summary: List cross-chain messages.
      description: >-
        Retrieves a paginated list of Arbitrum cross-chain messages filtered by
        the specified direction.
      operationId: BlockScoutWeb.API.V2.ArbitrumController.messages
      parameters:
        - description: >-
            Message direction: `from-rollup` for Rollup to Parent chain,
            `to-rollup` for Parent chain to Rollup.
          in: path
          name: direction
          required: true
          schema:
            enum:
              - from-rollup
              - to-rollup
            type: string
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
                      $ref: '#/components/schemas/Arbitrum.Message'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      id: 123
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                type: object
          description: Paginated list of cross-chain messages.
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
    Arbitrum.Message:
      additionalProperties: false
      description: Full Arbitrum cross-chain message.
      properties:
        completion_transaction_hash:
          description: >-
            Hash of the transaction on the destination chain that executed this
            message.
          nullable: true
          pattern: ^0x([A-Fa-f0-9]{64})$
          type: string
        id:
          description: Unique cross-chain message identifier assigned by the protocol.
          minimum: 0
          type: integer
        origination_address_hash:
          description: Address that initiated the message on the originating chain.
          nullable: true
          pattern: ^0x([A-Fa-f0-9]{40})$
          type: string
        origination_timestamp:
          $ref: '#/components/schemas/TimestampNullable'
        origination_transaction_block_number:
          description: >-
            Block number on the originating chain containing the initiation
            transaction.
          minimum: 0
          nullable: true
          type: integer
        origination_transaction_hash:
          description: >-
            Hash of the transaction on the originating chain that initiated this
            message.
          nullable: true
          pattern: ^0x([A-Fa-f0-9]{64})$
          type: string
        status:
          description: >-
            Cross-chain message lifecycle. For Rollup→Parent messages:
            `initiated` (L2ToL1Tx event emitted on Rollup) → `sent` (included in
            a batch committed to Parent chain) → `confirmed` (batch state root
            posted to the Outbox contract) → `relayed` (executed on Parent
            chain). For Parent→Rollup messages only `initiated` and `relayed`
            apply.
          enum:
            - initiated
            - sent
            - confirmed
            - relayed
          type: string
      required:
        - origination_transaction_hash
        - origination_timestamp
        - origination_transaction_block_number
        - completion_transaction_hash
        - id
        - origination_address_hash
        - status
      title: Arbitrum.Message
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