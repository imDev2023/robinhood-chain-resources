> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List tokens with optional filtering by name, symbol, or type

> Retrieves a paginated list of tokens with optional filtering by name, symbol, or type.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/tokens/
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
  /{chain_id}/api/v2/tokens/:
    get:
      tags:
        - tokens
      summary: List tokens with optional filtering by name, symbol, or type
      description: >-
        Retrieves a paginated list of tokens with optional filtering by name,
        symbol, or type.
      operationId: BlockScoutWeb.API.V2.TokenController.tokens_list
      parameters:
        - description: |
            Filter by token type. Comma-separated list of:
            * ERC-20 - Fungible tokens
            * ERC-721 - Non-fungible tokens
            * ERC-1155 - Multi-token standard
            * ERC-404 - Hybrid fungible/non-fungible tokens


            Example: `ERC-20,ERC-721` to show both fungible and NFT transfers
          in: query
          name: type
          schema:
            anyOf:
              - $ref: '#/components/schemas/EmptyString'
              - pattern: >-
                  ^\[?(ERC-20|ERC-721|ERC-1155|ERC-404|ERC-7984)(,(ERC-20|ERC-721|ERC-1155|ERC-404|ERC-7984))*\]?$
                type: string
        - description: Search query filter
          in: query
          name: q
          schema:
            nullable: true
            type: string
        - description: Limit result items in the response
          in: query
          name: limit
          schema:
            nullable: true
            type: integer
        - description: >
            Sort results by:

            * fiat_value - Sort by fiat value

            * holders_count - Sort by number of token holders

            * circulating_market_cap - Sort by circulating market cap of the
            token

            Should be used together with `order` parameter.
          in: query
          name: sort
          schema:
            enum:
              - fiat_value
              - holders_count
              - circulating_market_cap
            type: string
        - description: |
            Sort order:
            * asc - Ascending order
            * desc - Descending order
            Should be used together with `sort` parameter.
          in: query
          name: order
          schema:
            enum:
              - asc
              - desc
            type: string
        - description: Number of items per page
          in: query
          name: items_count
          schema:
            minimum: 1
            type: integer
        - description: Contract address hash for paging
          in: query
          name: contract_address_hash
          schema:
            $ref: '#/components/schemas/AddressHashNullable'
        - description: Fiat value for paging
          in: query
          name: fiat_value
          schema:
            anyOf:
              - $ref: '#/components/schemas/FloatString'
              - $ref: '#/components/schemas/EmptyString'
              - $ref: '#/components/schemas/NullString'
        - description: Number of holders returned per page
          in: query
          name: holders_count
          schema:
            anyOf:
              - $ref: '#/components/schemas/IntegerString'
              - $ref: '#/components/schemas/EmptyString'
              - $ref: '#/components/schemas/NullString'
        - description: Is name null for paging
          in: query
          name: is_name_null
          schema:
            type: boolean
        - description: Market cap for paging
          in: query
          name: market_cap
          schema:
            anyOf:
              - $ref: '#/components/schemas/FloatString'
              - $ref: '#/components/schemas/EmptyString'
              - $ref: '#/components/schemas/NullString'
        - description: Name for paging
          in: query
          name: name
          schema:
            type: string
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
                      $ref: '#/components/schemas/Token'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      contract_address_hash: '0xbe9895146f7af43049ca1c1ae358b0541ea49704'
                      fiat_value: '4724.32'
                      holders_count: 59731
                      is_name_null: false
                      market_cap: '570958125.135513'
                      name: Wrapped Staked ETH
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                type: object
          description: List of tokens matching the filter criteria, with pagination.
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
    EmptyString:
      maxLength: 0
      minLength: 0
      title: EmptyString
      type: string
    AddressHashNullable:
      nullable: true
      pattern: ^0x([A-Fa-f0-9]{40})$
      title: AddressHashNullable
      type: string
    FloatString:
      pattern: ^([1-9][0-9]*|0)(\.[0-9]+)?$
      title: FloatString
      type: string
    NullString:
      pattern: ^null$
      title: NullString
      type: string
    IntegerString:
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerString
      type: string
    Token:
      additionalProperties: false
      description: Token struct
      properties:
        address_hash:
          $ref: '#/components/schemas/AddressHash'
        bridge_type:
          description: Type of bridge used for this bridged token
          enum:
            - omni
            - amb
          nullable: true
          type: string
        circulating_market_cap:
          $ref: '#/components/schemas/FloatStringNullable'
        circulating_supply:
          $ref: '#/components/schemas/FloatStringNullable'
        decimals:
          $ref: '#/components/schemas/IntegerStringNullable'
        exchange_rate:
          $ref: '#/components/schemas/FloatStringNullable'
        foreign_address:
          nullable: true
          pattern: ^0x([A-Fa-f0-9]{40})$
          type: string
        holders_count:
          $ref: '#/components/schemas/IntegerStringNullable'
        icon_url:
          $ref: '#/components/schemas/URLNullable'
        name:
          nullable: true
          type: string
        origin_chain_id:
          $ref: '#/components/schemas/IntegerStringNullable'
        reputation:
          description: Reputation of the token
          enum:
            - ok
            - scam
          nullable: true
          type: string
        symbol:
          nullable: true
          type: string
        total_supply:
          $ref: '#/components/schemas/IntegerStringNullable'
        type:
          allOf:
            - $ref: '#/components/schemas/TokenType'
          nullable: true
        volume_24h:
          $ref: '#/components/schemas/FloatStringNullable'
      required:
        - address_hash
        - symbol
        - name
        - decimals
        - type
        - holders_count
        - exchange_rate
        - volume_24h
        - total_supply
        - icon_url
        - circulating_market_cap
        - circulating_supply
        - reputation
      title: Token
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
    FloatStringNullable:
      nullable: true
      pattern: ^([1-9][0-9]*|0)(\.[0-9]+)?$
      title: FloatStringNullable
      type: string
    IntegerStringNullable:
      nullable: true
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerStringNullable
      type: string
    URLNullable:
      example: https://example.com
      format: uri
      nullable: true
      title: URLNullable
      type: string
    TokenType:
      enum:
        - ERC-20
        - ERC-721
        - ERC-1155
        - ERC-404
        - ERC-7984
      title: TokenType
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