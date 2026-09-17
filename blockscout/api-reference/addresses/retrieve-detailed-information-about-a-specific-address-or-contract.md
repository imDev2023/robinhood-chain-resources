> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Retrieve detailed information about a specific address or contract

> Retrieves detailed information for a specific address, including balance, transaction count, and metadata.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/addresses/{address_hash_param}
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
  /{chain_id}/api/v2/addresses/{address_hash_param}:
    get:
      tags:
        - addresses
      summary: Retrieve detailed information about a specific address or contract
      description: >-
        Retrieves detailed information for a specific address, including
        balance, transaction count, and metadata.
      operationId: BlockScoutWeb.API.V2.AddressController.address
      parameters:
        - description: Address hash in the path
          in: path
          name: address_hash_param
          required: true
          schema:
            $ref: '#/components/schemas/AddressHash'
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
                $ref: '#/components/schemas/AddressResponse'
          description: Detailed information about the specified address.
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
    AddressResponse:
      additionalProperties: false
      description: Address response
      properties:
        block_number_balance_updated_at:
          minimum: 0
          nullable: true
          type: integer
        coin_balance:
          $ref: '#/components/schemas/IntegerStringNullable'
        creation_status:
          description: Creation status of the contract
          enum:
            - success
            - failed
            - selfdestructed
          nullable: true
          type: string
        creation_transaction_hash:
          $ref: '#/components/schemas/FullHashNullable'
        creator_address_hash:
          $ref: '#/components/schemas/AddressHashNullable'
        ens_domain_name:
          description: ENS domain name associated with the address
          nullable: true
          type: string
        exchange_rate:
          $ref: '#/components/schemas/FloatStringNullable'
        has_beacon_chain_withdrawals:
          type: boolean
        has_logs:
          type: boolean
        has_token_transfers:
          type: boolean
        has_tokens:
          type: boolean
        has_validated_blocks:
          type: boolean
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
        token:
          allOf:
            - $ref: '#/components/schemas/Token'
          nullable: true
        watchlist_address_id:
          nullable: true
          type: integer
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
        - creator_address_hash
        - creation_transaction_hash
        - token
        - coin_balance
        - exchange_rate
        - block_number_balance_updated_at
        - has_validated_blocks
        - has_logs
        - has_tokens
        - has_token_transfers
        - watchlist_address_id
        - has_beacon_chain_withdrawals
        - creation_status
      title: AddressResponse
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
    IntegerStringNullable:
      nullable: true
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerStringNullable
      type: string
    FullHashNullable:
      nullable: true
      pattern: ^0x([A-Fa-f0-9]{64})$
      title: FullHashNullable
      type: string
    AddressHashNullable:
      nullable: true
      pattern: ^0x([A-Fa-f0-9]{40})$
      title: AddressHashNullable
      type: string
    FloatStringNullable:
      nullable: true
      pattern: ^([1-9][0-9]*|0)(\.[0-9]+)?$
      title: FloatStringNullable
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