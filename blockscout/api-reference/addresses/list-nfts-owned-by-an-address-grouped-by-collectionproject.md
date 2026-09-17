> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List NFTs owned by an address grouped by collection/project

> Retrieves NFTs owned by a specific address, organized by collection. Useful for displaying an address's NFT portfolio grouped by project.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/addresses/{address_hash_param}/nft/collections
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
  /{chain_id}/api/v2/addresses/{address_hash_param}/nft/collections:
    get:
      tags:
        - addresses
      summary: List NFTs owned by an address grouped by collection/project
      description: >-
        Retrieves NFTs owned by a specific address, organized by collection.
        Useful for displaying an address's NFT portfolio grouped by project.
      operationId: BlockScoutWeb.API.V2.AddressController.nft_collections
      parameters:
        - description: Address hash in the path
          in: path
          name: address_hash_param
          required: true
          schema:
            $ref: '#/components/schemas/AddressHash'
        - description: >
            Filter by token type. Comma-separated list of:

            * ERC-721 - Non-fungible tokens

            * ERC-1155 - Multi-token standard

            * ERC-404 - Hybrid fungible/non-fungible tokens


            Example: `ERC-721,ERC-1155` to show both NFT and multi-token
            transfers
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
        - description: Token contract address hash for paging
          in: query
          name: token_contract_address_hash
          schema:
            $ref: '#/components/schemas/AddressHash'
        - description: Token type for paging
          in: query
          name: token_type
          schema:
            $ref: '#/components/schemas/TokenType'
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
                      $ref: '#/components/schemas/NFTCollection'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      token_contract_address_hash: '0x1ffe11b9fb7f6ff1b153ab8608cf403ecaf9d44a'
                      token_type: ERC-721
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                type: object
          description: >-
            NFTs owned by the specified address, grouped by collection, with
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
    EmptyString:
      maxLength: 0
      minLength: 0
      title: EmptyString
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
    NFTCollection:
      additionalProperties: false
      properties:
        amount:
          $ref: '#/components/schemas/IntegerStringNullable'
        token:
          $ref: '#/components/schemas/Token'
        token_instances:
          items:
            $ref: '#/components/schemas/TokenInstanceInList'
          type: array
      required:
        - token
        - amount
        - token_instances
      title: NFTCollection
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
    TokenInstanceInList:
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
          $ref: '#/components/schemas/TokenType'
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
        - token_type
        - value
      title: TokenInstanceInList
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
    IntegerString:
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerString
      type: string
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