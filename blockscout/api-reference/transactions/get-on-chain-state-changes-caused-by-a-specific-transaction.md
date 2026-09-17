> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get on-chain state changes caused by a specific transaction

> Retrieves state changes (balance changes, token transfers) caused by a specific transaction.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/transactions/{transaction_hash_param}/state-changes
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
  /{chain_id}/api/v2/transactions/{transaction_hash_param}/state-changes:
    get:
      tags:
        - transactions
      summary: Get on-chain state changes caused by a specific transaction
      description: >-
        Retrieves state changes (balance changes, token transfers) caused by a
        specific transaction.
      operationId: BlockScoutWeb.API.V2.TransactionController.state_changes
      parameters:
        - description: Transaction hash in the path
          in: path
          name: transaction_hash_param
          required: true
          schema:
            $ref: '#/components/schemas/FullHash'
        - description: Number of items per page
          in: query
          name: items_count
          schema:
            minimum: 1
            type: integer
        - description: >-
            Cumulative number of state changes to skip for keyset-based
            pagination
          in: query
          name: state_changes_count
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
                      $ref: '#/components/schemas/StateChange'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      state_changes_count: 50
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                type: object
          description: State changes caused by the specified transaction, with pagination.
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
    StateChange:
      additionalProperties: false
      properties:
        address:
          $ref: '#/components/schemas/Address'
        balance_after:
          $ref: '#/components/schemas/IntegerStringNullable'
        balance_before:
          $ref: '#/components/schemas/IntegerStringNullable'
        change:
          $ref: '#/components/schemas/IntegerStringNullable'
        is_miner:
          type: boolean
        token:
          allOf:
            - $ref: '#/components/schemas/Token'
          nullable: true
        token_id:
          $ref: '#/components/schemas/IntegerStringNullable'
        type:
          enum:
            - token
            - coin
          type: string
      required:
        - address
        - balance_after
        - balance_before
        - change
        - is_miner
        - token
        - type
      title: StateChange
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
    Address:
      additionalProperties: false
      description: Address
      properties:
        ens_domain_name:
          description: ENS domain name associated with the address
          nullable: true
          type: string
        hash:
          $ref: '#/components/schemas/AddressHash'
        implementations:
          description: Implementations linked with the contract
          items:
            $ref: '#/components/schemas/Implementation'
          type: array
        is_contract:
          description: Has address contract code?
          nullable: true
          type: boolean
        is_scam:
          description: Has address scam badge?
          type: boolean
        is_verified:
          description: Has address associated source code?
          nullable: true
          type: boolean
        metadata:
          allOf:
            - $ref: '#/components/schemas/Metadata'
          nullable: true
        name:
          description: Name associated with the address
          nullable: true
          type: string
        private_tags:
          description: Private tags associated with the address
          items:
            $ref: '#/components/schemas/Tag'
          type: array
        proxy_type:
          $ref: '#/components/schemas/ProxyType'
        public_tags:
          description: Public tags associated with the address
          items:
            $ref: '#/components/schemas/Tag'
          type: array
        reputation:
          description: Reputation of the address
          enum:
            - ok
            - scam
          type: string
        watchlist_names:
          description: Watchlist name associated with the address
          items:
            $ref: '#/components/schemas/WatchlistName'
          type: array
      required:
        - hash
        - is_contract
        - name
        - is_scam
        - reputation
        - proxy_type
        - implementations
        - is_verified
        - ens_domain_name
        - metadata
      title: Address
      type: object
    IntegerStringNullable:
      nullable: true
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerStringNullable
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
    AddressHash:
      pattern: ^0x([A-Fa-f0-9]{40})$
      title: AddressHash
      type: string
    Implementation:
      additionalProperties: false
      description: Proxy smart contract implementation
      properties:
        address_hash:
          $ref: '#/components/schemas/AddressHash'
        name:
          nullable: true
          type: string
      required:
        - address_hash
        - name
      title: Implementation
      type: object
    Metadata:
      additionalProperties: false
      description: Metadata struct
      properties:
        tags:
          description: Metadata tags linked with the address
          items:
            $ref: '#/components/schemas/MetadataTag'
          type: array
      required:
        - tags
      title: Metadata
      type: object
    Tag:
      additionalProperties: false
      description: Address tag struct
      properties:
        address_hash:
          $ref: '#/components/schemas/AddressHash'
        display_name:
          type: string
        label:
          type: string
      required:
        - address_hash
        - display_name
        - label
      title: Tag
      type: object
    ProxyType:
      enum:
        - eip1167
        - eip1967
        - eip1822
        - eip1967_oz
        - eip1967_beacon
        - master_copy
        - basic_implementation
        - basic_get_implementation
        - comptroller
        - eip2535
        - clone_with_immutable_arguments
        - eip7702
        - resolved_delegate_proxy
        - erc7760
        - minimal_proxy
      nullable: true
      title: ProxyType
      type: string
    WatchlistName:
      additionalProperties: false
      description: Watchlist name struct
      properties:
        display_name:
          type: string
        label:
          type: string
      required:
        - display_name
        - label
      title: WatchlistName
      type: object
    FloatStringNullable:
      nullable: true
      pattern: ^([1-9][0-9]*|0)(\.[0-9]+)?$
      title: FloatStringNullable
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
    MetadataTag:
      additionalProperties: false
      description: Metadata tag struct
      properties:
        meta:
          additionalProperties: true
          nullable: true
          type: object
        name:
          type: string
        ordinal:
          type: integer
        slug:
          type: string
        tagType:
          enum:
            - name
            - generic
            - classifier
            - information
            - note
            - protocol
          type: string
      required:
        - slug
        - name
        - tagType
        - ordinal
        - meta
      title: MetadataTag
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