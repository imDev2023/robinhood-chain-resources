> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get step-by-step execution trace for a specific transaction

> Retrieves the raw execution trace for a transaction, showing the step-by-step execution path and all contract interactions.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/transactions/{transaction_hash_param}/raw-trace
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
  /{chain_id}/api/v2/transactions/{transaction_hash_param}/raw-trace:
    get:
      tags:
        - transactions
      summary: Get step-by-step execution trace for a specific transaction
      description: >-
        Retrieves the raw execution trace for a transaction, showing the
        step-by-step execution path and all contract interactions.
      operationId: BlockScoutWeb.API.V2.TransactionController.raw_trace
      parameters:
        - description: Transaction hash in the path
          in: path
          name: transaction_hash_param
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
                $ref: '#/components/schemas/RawTrace'
          description: Raw execution trace for the specified transaction.
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
    RawTrace:
      items:
        additionalProperties: false
        properties:
          action:
            additionalProperties: false
            properties:
              callType:
                enum:
                  - call
                  - callcode
                  - delegatecall
                  - staticcall
                type: string
              from:
                $ref: '#/components/schemas/AddressHash'
              gas:
                $ref: '#/components/schemas/HexData'
              init:
                $ref: '#/components/schemas/HexData'
              input:
                $ref: '#/components/schemas/HexData'
              to:
                $ref: '#/components/schemas/AddressHash'
              value:
                $ref: '#/components/schemas/HexData'
            required:
              - from
              - gas
              - input
              - value
            type: object
          result:
            additionalProperties: false
            properties:
              gasUsed:
                $ref: '#/components/schemas/HexData'
              output:
                $ref: '#/components/schemas/HexData'
            required:
              - gasUsed
              - output
            type: object
          subtraces:
            minimum: 0
            type: integer
          traceAddress:
            items:
              type: integer
            type: array
          transactionHash:
            $ref: '#/components/schemas/FullHashNullable'
          type:
            enum:
              - call
              - create
              - create2
              - reward
              - selfdestruct
              - stop
              - invalid
            type: string
        required:
          - action
          - subtraces
          - traceAddress
          - type
        type: object
      title: RawTrace
      type: array
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
    AddressHash:
      pattern: ^0x([A-Fa-f0-9]{40})$
      title: AddressHash
      type: string
    HexData:
      pattern: ^0x([A-Fa-f0-9]*)$
      title: HexData
      type: string
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