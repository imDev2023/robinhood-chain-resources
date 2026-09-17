> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List addresses holding a specific token sorted by balance

> Retrieves addresses holding a specific token, sorted by balance. Useful for analyzing token distribution.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/tokens/{address_hash_param}/holders
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
  /{chain_id}/api/v2/tokens/{address_hash_param}/holders:
    get:
      tags:
        - tokens
      summary: List addresses holding a specific token sorted by balance
      description: >-
        Retrieves addresses holding a specific token, sorted by balance. Useful
        for analyzing token distribution.
      operationId: BlockScoutWeb.API.V2.TokenController.holders
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
        - description: Address hash for paging
          in: query
          name: address_hash
          schema:
            $ref: '#/components/schemas/AddressHash'
        - description: Transaction value for paging
          in: query
          name: value
          schema:
            anyOf:
              - $ref: '#/components/schemas/IntegerString'
              - $ref: '#/components/schemas/EmptyString'
              - $ref: '#/components/schemas/NullString'
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
                      $ref: '#/components/schemas/TokenHolderResponse'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      address_hash: '0x48bb9b14483e43c7726df702b271d410e7460656'
                      value: '200000000000000'
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                type: object
          description: Holders of the specified token, with pagination.
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
    AddressHash:
      pattern: ^0x([A-Fa-f0-9]{40})$
      title: AddressHash
      type: string
    IntegerString:
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerString
      type: string
    EmptyString:
      maxLength: 0
      minLength: 0
      title: EmptyString
      type: string
    NullString:
      pattern: ^null$
      title: NullString
      type: string
    TokenHolderResponse:
      additionalProperties: false
      description: Token holder response
      example:
        address:
          ens_domain_name: null
          hash: '0xF977814e90dA44bFA03b6295A0616a897441aceC'
          implementations: []
          is_contract: false
          is_scam: false
          is_verified: false
          metadata:
            tags:
              - meta:
                  main_entity: Binance
                  tooltipUrl: https://www.binance.com/
                name: 'Binance: Hot Wallet 20'
                ordinal: 10
                slug: binance-hot-wallet-20
                tagType: name
              - meta:
                  tooltipUrl: https://www.binance.com
                name: Binance 8
                ordinal: 10
                slug: binance-8
                tagType: name
              - meta: {}
                name: HOT WALLET
                ordinal: 0
                slug: hot-wallet
                tagType: generic
              - meta: {}
                name: Exchange
                ordinal: 0
                slug: exchange
                tagType: generic
              - meta: {}
                name: Binance
                ordinal: 0
                slug: binance
                tagType: protocol
          name: null
          private_tags: []
          proxy_type: null
          public_tags: []
          reputation: ok
          watchlist_names: []
        token_id: null
        value: '19474530513868000'
      properties:
        address:
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
        token_id:
          $ref: '#/components/schemas/IntegerStringNullable'
        value:
          $ref: '#/components/schemas/IntegerStringNullable'
      required:
        - address
        - token_id
        - value
      title: TokenHolderResponse
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
    IntegerStringNullable:
      nullable: true
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerStringNullable
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