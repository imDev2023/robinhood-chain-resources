> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List transactions, internal transactions and token transfers matching the advanced filter criteria

> Returns a paginated, mixed list of activity — native value transfers, internal transactions and token transfers — filtered by transaction type, contract method, time window, address relations, value range and/or token contract. The response also echoes the resolved human-readable names of the methods and tokens referenced in the request filters.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/advanced-filters
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
  /{chain_id}/api/v2/advanced-filters:
    get:
      tags:
        - advanced-filters
      summary: >-
        List transactions, internal transactions and token transfers matching
        the advanced filter criteria
      description: >-
        Returns a paginated, mixed list of activity — native value transfers,
        internal transactions and token transfers — filtered by transaction
        type, contract method, time window, address relations, value range
        and/or token contract. The response also echoes the resolved
        human-readable names of the methods and tokens referenced in the request
        filters.
      operationId: BlockScoutWeb.API.V2.AdvancedFilterController.list
      parameters:
        - description: >-
            Comma-separated list of transaction types to include. Allowed
            values: `COIN_TRANSFER`, `CONTRACT_INTERACTION`,
            `CONTRACT_CREATION`, `ERC-20`, `ERC-404`, `ERC-721`, `ERC-1155`,
            `ERC-7984` (plus `ZRC-2` on Zilliqa). Values are matched
            case-insensitively; unknown entries are silently dropped.
          example: COIN_TRANSFER,ERC-20
          in: query
          name: transaction_types
          schema:
            nullable: true
            type: string
        - description: >-
            Comma-separated list of 4-byte contract method selectors (lowercase,
            `0x`-prefixed). At most 20 unique entries are honored; invalid
            entries are dropped.
          example: 0xa9059cbb,0x095ea7b3
          in: query
          name: methods
          schema:
            nullable: true
            type: string
        - description: Inclusive lower bound on `timestamp` (ISO 8601).
          example: '2024-01-01T00:00:00Z'
          in: query
          name: age_from
          schema:
            nullable: true
            type: string
        - description: Inclusive upper bound on `timestamp` (ISO 8601).
          example: '2024-12-31T23:59:59Z'
          in: query
          name: age_to
          schema:
            nullable: true
            type: string
        - description: Comma-separated list of sender address hashes to include.
          example: >-
            0x5a52e96bacdabb82fd05763e25335261b270efcb,0x00000000219ab540356cbb839cbe05303d7705fa
          in: query
          name: from_address_hashes_to_include
          schema:
            nullable: true
            type: string
        - description: Comma-separated list of sender address hashes to exclude.
          example: >-
            0x5a52e96bacdabb82fd05763e25335261b270efcb,0x00000000219ab540356cbb839cbe05303d7705fa
          in: query
          name: from_address_hashes_to_exclude
          schema:
            nullable: true
            type: string
        - description: Comma-separated list of recipient address hashes to include.
          example: >-
            0x5a52e96bacdabb82fd05763e25335261b270efcb,0x00000000219ab540356cbb839cbe05303d7705fa
          in: query
          name: to_address_hashes_to_include
          schema:
            nullable: true
            type: string
        - description: Comma-separated list of recipient address hashes to exclude.
          example: >-
            0x5a52e96bacdabb82fd05763e25335261b270efcb,0x00000000219ab540356cbb839cbe05303d7705fa
          in: query
          name: to_address_hashes_to_exclude
          schema:
            nullable: true
            type: string
        - description: >-
            How to combine the `from_address_hashes_*` and `to_address_hashes_*`
            filters. Accepts `or` or `and` (case-insensitive). `or` (default)
            matches an item if either side matches; `and` requires both sides to
            match. Any other value is silently coerced to `nil` (no relation
            constraint).
          example: and
          in: query
          name: address_relation
          schema:
            nullable: true
            type: string
        - description: >-
            Inclusive lower bound on the item's transferred amount (decimal
            string in the token's base units).
          example: '0'
          in: query
          name: amount_from
          schema:
            nullable: true
            type: string
        - description: >-
            Inclusive upper bound on the item's transferred amount (decimal
            string in the token's base units).
          example: '1000000'
          in: query
          name: amount_to
          schema:
            nullable: true
            type: string
        - description: >-
            Comma-separated list of token contract address hashes to include.
            Use the literal `native` to also include native coin transfers. Each
            list (include and exclude) is capped to 20 entries separately.
          example: native,0xdac17f958d2ee523a2206206994597c13d831ec7
          in: query
          name: token_contract_address_hashes_to_include
          schema:
            nullable: true
            type: string
        - description: >-
            Comma-separated list of token contract address hashes to exclude.
            Use the literal `native` to also exclude native coin transfers. Each
            list (include and exclude) is capped to 20 entries separately.
          example: '0x0000000000000000000000000000000000000000'
          in: query
          name: token_contract_address_hashes_to_exclude
          schema:
            nullable: true
            type: string
        - description: >-
            Comma-separated list of human-readable method names corresponding to
            the `methods` selectors.
          example: transfer,approve
          in: query
          name: methods_names
          schema:
            nullable: true
            type: string
        - description: Comma-separated list of token symbols to include.
          example: USDT,USDC
          in: query
          name: token_contract_symbols_to_include
          schema:
            nullable: true
            type: string
        - description: Comma-separated list of token symbols to exclude.
          example: USDT,USDC
          in: query
          name: token_contract_symbols_to_exclude
          schema:
            nullable: true
            type: string
        - description: 'Keyset cursor: block number of the last item from the previous page.'
          example: '23532302'
          in: query
          name: block_number
          schema:
            pattern: ^([1-9][0-9]*|0)$
            type: string
        - description: >-
            Keyset cursor: transaction index within the block of the last item
            from the previous page.
          example: '1'
          in: query
          name: transaction_index
          schema:
            pattern: ^([1-9][0-9]*|0)$
            type: string
        - description: >-
            Keyset cursor: internal-transaction index of the last item from the
            previous page. Use an empty string or the literal `null` when the
            previous item was not an internal transaction.
          in: query
          name: internal_transaction_index
          schema:
            $ref: '#/components/schemas/IntegerStringOrEmptyOrNullLiteral'
        - description: >-
            Keyset cursor: token-transfer index of the last item from the
            previous page. Use an empty string or the literal `null` when the
            previous item was not a token transfer.
          in: query
          name: token_transfer_index
          schema:
            $ref: '#/components/schemas/IntegerStringOrEmptyOrNullLiteral'
        - description: >-
            Keyset cursor: index within an ERC-1155 batch token transfer. Use an
            empty string or the literal `null` when the previous item was not
            part of a batch.
          in: query
          name: token_transfer_batch_index
          schema:
            $ref: '#/components/schemas/IntegerStringOrEmptyOrNullLiteral'
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
                $ref: '#/components/schemas/AdvancedFilterResponse'
          description: >-
            List of matching items with pagination information and resolved
            search params.
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
    IntegerStringOrEmptyOrNullLiteral:
      oneOf:
        - pattern: ^([1-9][0-9]*|0)$
          type: string
        - enum:
            - ''
            - 'null'
          type: string
      title: IntegerStringOrEmptyOrNullLiteral
    AdvancedFilterResponse:
      additionalProperties: false
      properties:
        items:
          items:
            $ref: '#/components/schemas/AdvancedFilterItem'
          type: array
        next_page_params:
          additionalProperties: true
          example:
            block_number: 23532302
            internal_transaction_index: null
            token_transfer_batch_index: null
            token_transfer_index: 0
            transaction_index: 1
          nullable: true
          type: object
        search_params:
          $ref: '#/components/schemas/AdvancedFilterSearchParams'
      required:
        - items
        - search_params
        - next_page_params
      title: AdvancedFilterResponse
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
    AdvancedFilterItem:
      additionalProperties: false
      properties:
        block_number:
          description: Number of the block that contains the parent transaction.
          minimum: 0
          type: integer
        created_contract:
          allOf:
            - $ref: '#/components/schemas/Address'
          description: >-
            Address of the contract deployed by this item. `null` unless the
            item is a contract creation.
          nullable: true
        fee:
          description: >-
            Transaction fee paid by the sender, in the chain's base unit (e.g.
            wei).
          pattern: ^([1-9][0-9]*|0)$
          type: string
        from:
          allOf:
            - $ref: '#/components/schemas/Address'
          description: Sender address. `null` for contract-creation items.
          nullable: true
        hash:
          $ref: '#/components/schemas/FullHash'
        internal_transaction_index:
          description: >-
            Zero-based position of the internal transaction within its parent
            transaction. Populated only for internal-transaction items; `null`
            otherwise.
          minimum: 0
          nullable: true
          type: integer
        method:
          $ref: '#/components/schemas/MethodNameNullable'
        status:
          description: >-
            Execution status of the parent transaction. One of `pending`,
            `awaiting_internal_transactions`, `success`, or a free-form error
            reason string when the transaction reverted (e.g. `Reverted`).
          type: string
        timestamp:
          description: Block timestamp of the parent transaction.
          format: date-time
          type: string
        to:
          allOf:
            - $ref: '#/components/schemas/Address'
          description: >-
            Recipient address. `null` for contract-creation items and some
            internal transactions.
          nullable: true
        token:
          allOf:
            - $ref: '#/components/schemas/Token'
          description: >-
            Token contract metadata. Populated only for token-transfer items;
            `null` otherwise.
          nullable: true
        token_transfer_batch_index:
          description: >-
            Zero-based position within an ERC-1155 batch token transfer.
            Populated only for items that belong to a batch; `null` otherwise.
          minimum: 0
          nullable: true
          type: integer
        token_transfer_index:
          description: >-
            Zero-based position of the token transfer, unique per parent
            transaction. Populated only for token-transfer items; `null`
            otherwise.
          minimum: 0
          nullable: true
          type: integer
        total:
          anyOf:
            - $ref: '#/components/schemas/TotalERC721'
            - $ref: '#/components/schemas/TotalERC1155'
            - $ref: '#/components/schemas/TotalERC7984'
            - $ref: '#/components/schemas/Total'
          description: >-
            Token transfer amount (or token id for NFTs). Populated only for
            token-transfer items; `null` otherwise.
          nullable: true
        transaction_index:
          description: Zero-based position of the parent transaction within its block.
          minimum: 0
          type: integer
        type:
          description: >-
            Kind of activity represented by the item. Values `coin_transfer`,
            `contract_interaction`, and `contract_creation` apply to top-level
            transactions and internal transactions; the `ERC-*` values apply to
            token transfers.
          enum:
            - coin_transfer
            - contract_interaction
            - contract_creation
            - ERC-20
            - ERC-721
            - ERC-1155
            - ERC-404
            - ERC-7984
          type: string
        value:
          description: >-
            Native coin amount transferred, in the chain's base unit (e.g. wei).
            `null` for token-transfer items.
          nullable: true
          pattern: ^([1-9][0-9]*|0)$
          type: string
      required:
        - hash
        - type
        - status
        - method
        - from
        - to
        - created_contract
        - value
        - total
        - token
        - timestamp
        - block_number
        - transaction_index
        - internal_transaction_index
        - token_transfer_index
        - token_transfer_batch_index
        - fee
      title: AdvancedFilterItem
      type: object
    AdvancedFilterSearchParams:
      additionalProperties: false
      properties:
        methods:
          additionalProperties:
            type: string
          description: >-
            Map of 4-byte method selectors (keys) to resolved method names
            (values) for the `methods` filter.
          type: object
        tokens:
          additionalProperties:
            $ref: '#/components/schemas/Token'
          description: >-
            Map of token contract address hashes (keys) to `Token` objects for
            tokens referenced in the
            `token_contract_address_hashes_to_include`/`_exclude` filters. At
            most 20 entries are returned (combined across both lists).
          type: object
      required:
        - methods
        - tokens
      title: AdvancedFilterSearchParams
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
    FullHash:
      pattern: ^0x([A-Fa-f0-9]{64})$
      title: FullHash
      type: string
    MethodNameNullable:
      description: Method name or hex method id
      example: transfer
      nullable: true
      title: MethodNameNullable
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
    TokenType:
      enum:
        - ERC-20
        - ERC-721
        - ERC-1155
        - ERC-404
        - ERC-7984
      title: TokenType
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