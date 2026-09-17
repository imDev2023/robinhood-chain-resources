> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get withdrawal messages for a transaction.

> Returns the list of Rollup withdrawal messages (L2ToL1Tx events) emitted by the given transaction.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/arbitrum/messages/withdrawals/{transaction_hash}
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
  /{chain_id}/api/v2/arbitrum/messages/withdrawals/{transaction_hash}:
    get:
      tags:
        - arbitrum
      summary: Get withdrawal messages for a transaction.
      description: >-
        Returns the list of Rollup withdrawal messages (L2ToL1Tx events) emitted
        by the given transaction.
      operationId: BlockScoutWeb.API.V2.ArbitrumController.withdrawals
      parameters:
        - description: Transaction hash.
          in: path
          name: transaction_hash
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
                additionalProperties: false
                properties:
                  items:
                    items:
                      $ref: '#/components/schemas/Arbitrum.Withdrawal'
                    type: array
                required:
                  - items
                type: object
          description: Withdrawal messages for the transaction.
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
    FullHash:
      pattern: ^0x([A-Fa-f0-9]{64})$
      title: FullHash
      type: string
    Arbitrum.Withdrawal:
      additionalProperties: false
      description: Arbitrum Rollup withdrawal message.
      properties:
        arb_block_number:
          description: Rollup block number.
          minimum: 0
          type: integer
        caller_address_hash:
          description: Address of the account that initiated the withdrawal on the Rollup.
          pattern: ^0x([A-Fa-f0-9]{40})$
          type: string
        callvalue:
          description: Native coin amount in wei attached to the withdrawal message.
          pattern: ^-?([1-9][0-9]*|0)$
          type: string
        completion_transaction_hash:
          $ref: '#/components/schemas/FullHashNullable'
        data:
          description: >-
            ABI-encoded calldata passed to the destination address when the
            withdrawal is executed on the Parent chain. Empty (`0x`) for plain
            native coin transfers.
          pattern: ^0x([A-Fa-f0-9]*)$
          type: string
        destination_address_hash:
          description: >-
            Recipient address on the Parent chain that will receive funds when
            the withdrawal is executed.
          pattern: ^0x([A-Fa-f0-9]{40})$
          type: string
        eth_block_number:
          description: Parent chain block number.
          minimum: 0
          type: integer
        id:
          description: Withdrawal message ID.
          minimum: 0
          type: integer
        l2_timestamp:
          description: Unix timestamp of the originating transaction.
          minimum: 0
          type: integer
        status:
          description: >-
            Withdrawal lifecycle status. Progresses from `initiated` (L2ToL1Tx
            event emitted) through `sent` (included in an RBlock) and
            `confirmed` (RBlock confirmed on Parent chain) to `relayed`
            (executed on Parent chain). `unknown` indicates the status could not
            be determined, e.g. when the Parent chain RPC is unavailable.
          enum:
            - unknown
            - initiated
            - sent
            - confirmed
            - relayed
          type: string
        token:
          additionalProperties: false
          description: >-
            Token withdrawal details. Present when the withdrawal is for a
            bridged token, null for native coin.
          nullable: true
          properties:
            address_hash:
              description: Token contract address on the Parent chain.
              nullable: true
              pattern: ^0x([A-Fa-f0-9]{40})$
              type: string
            amount:
              description: Token amount in the token's smallest unit.
              pattern: ^-?([1-9][0-9]*|0)$
              type: string
            decimals:
              minimum: 0
              nullable: true
              type: integer
            destination_address_hash:
              description: Token recipient address on the Parent chain.
              nullable: true
              pattern: ^0x([A-Fa-f0-9]{40})$
              type: string
            name:
              nullable: true
              type: string
            symbol:
              nullable: true
              type: string
          required:
            - address_hash
            - destination_address_hash
            - amount
            - decimals
            - name
            - symbol
          type: object
      required:
        - id
        - status
        - caller_address_hash
        - destination_address_hash
        - arb_block_number
        - eth_block_number
        - l2_timestamp
        - callvalue
        - data
        - token
        - completion_transaction_hash
      title: Arbitrum.Withdrawal
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
    FullHashNullable:
      nullable: true
      pattern: ^0x([A-Fa-f0-9]{64})$
      title: FullHashNullable
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