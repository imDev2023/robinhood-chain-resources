> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get native coin balance history for an address showing all balance changes

> Retrieves historical native coin balance changes for a specific address, tracking how an address's balance has changed over time.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/addresses/{address_hash_param}/coin-balance-history
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
  /{chain_id}/api/v2/addresses/{address_hash_param}/coin-balance-history:
    get:
      tags:
        - addresses
      summary: >-
        Get native coin balance history for an address showing all balance
        changes
      description: >-
        Retrieves historical native coin balance changes for a specific address,
        tracking how an address's balance has changed over time.
      operationId: BlockScoutWeb.API.V2.AddressController.coin_balance_history
      parameters:
        - description: Address hash in the path
          in: path
          name: address_hash_param
          required: true
          schema:
            $ref: '#/components/schemas/AddressHash'
        - description: Number of items per page
          in: query
          name: items_count
          schema:
            minimum: 1
            type: integer
        - description: Block number for paging
          in: query
          name: block_number
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
                additionalProperties: false
                properties:
                  items:
                    items:
                      $ref: '#/components/schemas/CoinBalance'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      block_number: 22546398
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                type: object
          description: >-
            Historical coin balance changes for the specified address, with
            pagination.
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
        '403':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ForbiddenResponse'
          description: Forbidden
        '422':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/JsonErrorResponse'
          description: Unprocessable Entity
components:
  schemas:
    AddressHash:
      pattern: ^0x([A-Fa-f0-9]{40})$
      title: AddressHash
      type: string
    CoinBalance:
      additionalProperties: false
      properties:
        block_number:
          type: integer
        block_timestamp:
          $ref: '#/components/schemas/Timestamp'
        delta:
          $ref: '#/components/schemas/IntegerString'
        transaction_hash:
          $ref: '#/components/schemas/FullHashNullable'
        value:
          $ref: '#/components/schemas/IntegerString'
      required:
        - transaction_hash
        - block_number
        - delta
        - value
        - block_timestamp
      title: CoinBalance
      type: object
    ForbiddenResponse:
      description: Response returned when the user is forbidden to access the resource
      properties:
        message:
          description: >-
            Error message indicating the user is forbidden to access the
            resource
          example: Unverified email
          type: string
      title: ForbiddenResponse
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
    IntegerString:
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerString
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