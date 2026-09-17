> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List recent Parent chain to Rollup messages on the main page.

> Retrieves the most recent relayed messages from Parent chain to Rollup, displayed on the main page.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/main-page/arbitrum/messages/to-rollup
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
  /{chain_id}/api/v2/main-page/arbitrum/messages/to-rollup:
    get:
      tags:
        - arbitrum
        - main-page
      summary: List recent Parent chain to Rollup messages on the main page.
      description: >-
        Retrieves the most recent relayed messages from Parent chain to Rollup,
        displayed on the main page.
      operationId: BlockScoutWeb.API.V2.ArbitrumController.recent_messages_to_l2
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
                additionalProperties: false
                properties:
                  items:
                    items:
                      $ref: '#/components/schemas/MinimalMessage'
                    type: array
                required:
                  - items
                type: object
          description: List of recent Parent chain to Rollup messages.
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
    MinimalMessage:
      additionalProperties: false
      description: >-
        Minimal Arbitrum cross-chain message with origination and completion
        fields.
      properties:
        completion_transaction_hash:
          description: >-
            Hash of the transaction on the destination chain that executed this
            message.
          nullable: true
          pattern: ^0x([A-Fa-f0-9]{64})$
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
      required:
        - origination_transaction_hash
        - origination_timestamp
        - origination_transaction_block_number
        - completion_transaction_hash
      title: MinimalMessage
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