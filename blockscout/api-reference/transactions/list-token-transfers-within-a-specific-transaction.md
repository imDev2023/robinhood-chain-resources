> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List token transfers within a specific transaction

> Retrieves token transfers that occurred within a specific transaction, with optional filtering by token type.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/transactions/{transaction_hash_param}/token-transfers
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
  /{chain_id}/api/v2/transactions/{transaction_hash_param}/token-transfers:
    get:
      tags:
        - transactions
      summary: List token transfers within a specific transaction
      description: >-
        Retrieves token transfers that occurred within a specific transaction,
        with optional filtering by token type.
      operationId: BlockScoutWeb.API.V2.TransactionController.token_transfers
      parameters:
        - description: Transaction hash in the path
          in: path
          name: transaction_hash_param
          required: true
          schema:
            $ref: '#/components/schemas/FullHash'
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
        - description: Number of items per page
          in: query
          name: items_count
          schema:
            minimum: 1
            type: integer
        - description: Item index for paging
          in: query
          name: index
          schema:
            type: integer
        - description: Block number for paging
          in: query
          name: block_number
          schema:
            minimum: 0
            type: integer
        - description: Batch log index for paging
          in: query
          name: batch_log_index
          schema:
            type: integer
        - description: Batch block hash for paging
          in: query
          name: batch_block_hash
          schema:
            $ref: '#/components/schemas/FullHash'
        - description: Batch transaction hash for paging
          in: query
          name: batch_transaction_hash
          schema:
            $ref: '#/components/schemas/FullHash'
        - description: Index in batch for paging
          in: query
          name: index_in_batch
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
                      $ref: '#/components/schemas/TokenTransfer'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      block_number: 21307214
                      index: 442
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                type: object
          description: Token transfers within the specified transaction, with pagination.
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
    EmptyString:
      maxLength: 0
      minLength: 0
      title: EmptyString
      type: string
    TokenTransfer:
      additionalProperties: false
      properties:
        block_hash:
          $ref: '#/components/schemas/FullHash'
        block_number:
          type: integer
        from:
          $ref: '#/components/schemas/Address'
        log_index:
          type: integer
        method:
          $ref: '#/components/schemas/MethodNameNullable'
        timestamp:
          $ref: '#/components/schemas/TimestampNullable'
        to:
          $ref: '#/components/schemas/Address'
        token:
          $ref: '#/components/schemas/Token'
        token_type:
          $ref: '#/components/schemas/TokenType'
        total:
          anyOf:
            - $ref: '#/components/schemas/TotalERC721'
            - $ref: '#/components/schemas/TotalERC1155'
            - $ref: '#/components/schemas/TotalERC7984'
            - $ref: '#/components/schemas/Total'
          nullable: true
        transaction_hash:
          $ref: '#/components/schemas/FullHash'
        type:
          enum:
            - token_burning
            - token_minting
            - token_spawning
            - token_transfer
          type: string
      required:
        - transaction_hash
        - from
        - to
        - total
        - token
        - type
        - timestamp
        - method
        - block_hash
        - block_number
        - log_index
        - token_type
      title: TokenTransfer
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
    MethodNameNullable:
      description: Method name or hex method id
      example: transfer
      nullable: true
      title: MethodNameNullable
      type: string
    TimestampNullable:
      format: date-time
      nullable: true
      title: TimestampNullable
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
    TokenType:
      enum:
        - ERC-20
        - ERC-721
        - ERC-1155
        - ERC-404
        - ERC-7984
      title: TokenType
      type: string
    TotalERC721:
      additionalProperties: false
      properties:
        token_id:
          $ref: '#/components/schemas/IntegerStringNullable'
        token_instance:
          allOf:
            - $ref: '#/components/schemas/TokenInstance'
          nullable: true
      required:
        - token_id
        - token_instance
      title: TotalERC721
      type: object
    TotalERC1155:
      additionalProperties: false
      properties:
        decimals:
          $ref: '#/components/schemas/IntegerStringNullable'
        token_id:
          $ref: '#/components/schemas/IntegerStringNullable'
        token_instance:
          allOf:
            - $ref: '#/components/schemas/TokenInstance'
          nullable: true
        value:
          $ref: '#/components/schemas/IntegerStringNullable'
      required:
        - token_id
        - value
        - decimals
        - token_instance
      title: TotalERC1155
      type: object
    TotalERC7984:
      additionalProperties: false
      properties:
        decimals:
          $ref: '#/components/schemas/IntegerStringNullable'
        value:
          $ref: '#/components/schemas/IntegerStringNullable'
      required:
        - value
        - decimals
      title: TotalERC7984
      type: object
    Total:
      additionalProperties: false
      properties:
        decimals:
          $ref: '#/components/schemas/IntegerStringNullable'
        value:
          $ref: '#/components/schemas/IntegerStringNullable'
      required:
        - value
        - decimals
      title: Total
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
    TokenInstance:
      additionalProperties: false
      properties:
        animation_media_type:
          description: Media type category of the token instance animation URL
          enum:
            - image
            - video
            - html
          nullable: true
          type: string
        animation_url:
          $ref: '#/components/schemas/URLNullable'
        external_app_url:
          $ref: '#/components/schemas/URLNullable'
        id:
          $ref: '#/components/schemas/IntegerString'
        image_media_type:
          description: Media type category of the token instance image URL
          enum:
            - image
            - video
            - html
          nullable: true
          type: string
        image_url:
          $ref: '#/components/schemas/URLNullable'
        is_unique:
          nullable: true
          type: boolean
        media_type:
          description: Mime type of the media in media_url
          example: image/png
          nullable: true
          type: string
        media_url:
          $ref: '#/components/schemas/URLNullable'
        metadata:
          additionalProperties: true
          example:
            description: Test
            image: https://example.com/image.png
            name: Test
          nullable: true
          type: object
        owner:
          allOf:
            - $ref: '#/components/schemas/Address'
          nullable: true
        thumbnails:
          nullable: true
          properties:
            250x250:
              format: uri
              type: string
            500x500:
              format: uri
              type: string
            60x60:
              format: uri
              type: string
            original:
              format: uri
              type: string
          required:
            - original
          type: object
        token:
          allOf:
            - $ref: '#/components/schemas/Token'
          nullable: true
        token_type:
          allOf:
            - $ref: '#/components/schemas/TokenType'
          nullable: true
        value:
          $ref: '#/components/schemas/IntegerStringNullable'
      required:
        - id
        - metadata
        - owner
        - token
        - external_app_url
        - animation_url
        - image_url
        - is_unique
        - thumbnails
        - media_type
        - media_url
      title: TokenInstance
      type: object
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
    IntegerString:
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerString
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