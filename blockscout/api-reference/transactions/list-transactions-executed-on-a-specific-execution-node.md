> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List transactions executed on a specific execution node

> Retrieves transactions that were executed on the specified execution node.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/transactions/execution-node/{execution_node_hash_param}
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
  /{chain_id}/api/v2/transactions/execution-node/{execution_node_hash_param}:
    get:
      tags:
        - transactions
      summary: List transactions executed on a specific execution node
      description: >-
        Retrieves transactions that were executed on the specified execution
        node.
      operationId: BlockScoutWeb.API.V2.TransactionController.execution_node
      parameters:
        - description: Execution node hash in the path
          in: path
          name: execution_node_hash_param
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
        - description: Item index for paging
          in: query
          name: index
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
                      $ref: '#/components/schemas/TransactionResponse'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      block_number: 14127868
                      index: 0
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                type: object
          description: List of transactions.
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
    AddressHash:
      pattern: ^0x([A-Fa-f0-9]{40})$
      title: AddressHash
      type: string
    TransactionResponse:
      additionalProperties: false
      description: Transaction response
      properties:
        arbitrum:
          additionalProperties: false
          properties:
            batch_data_container:
              nullable: true
              type: string
            batch_number:
              nullable: true
              type: integer
            commitment_transaction:
              additionalProperties: false
              properties:
                hash:
                  $ref: '#/components/schemas/FullHashNullable'
                status:
                  enum:
                    - unfinalized
                    - finalized
                  nullable: true
                  type: string
                timestamp:
                  $ref: '#/components/schemas/TimestampNullable'
              required:
                - hash
                - timestamp
                - status
              type: object
            confirmation_transaction:
              additionalProperties: false
              properties:
                hash:
                  $ref: '#/components/schemas/FullHashNullable'
                status:
                  enum:
                    - unfinalized
                    - finalized
                  nullable: true
                  type: string
                timestamp:
                  $ref: '#/components/schemas/TimestampNullable'
              required:
                - hash
                - timestamp
                - status
              type: object
            contains_message:
              enum:
                - incoming
                - outcoming
              nullable: true
              type: string
            gas_used_for_l1:
              $ref: '#/components/schemas/IntegerString'
            gas_used_for_l2:
              $ref: '#/components/schemas/IntegerString'
            message_related_info:
              additionalProperties: false
              properties:
                associated_l1_transaction_hash:
                  $ref: '#/components/schemas/FullHashNullable'
                message_id:
                  type: integer
                message_status:
                  enum:
                    - Syncing with base layer
                    - Relayed
                    - Settlement pending
                    - Waiting for confirmation
                    - Ready for relay
                  type: string
              type: object
            network_fee:
              $ref: '#/components/schemas/IntegerString'
            poster_fee:
              $ref: '#/components/schemas/IntegerString'
            status:
              enum:
                - Confirmed on base
                - Sent to base
                - Sealed on rollup
                - Processed on rollup
              type: string
          required:
            - gas_used_for_l1
            - gas_used_for_l2
            - poster_fee
            - network_fee
          type: object
        authorization_list:
          items:
            $ref: '#/components/schemas/SignedAuthorization'
          nullable: true
          type: array
        base_fee_per_gas:
          $ref: '#/components/schemas/IntegerStringNullable'
        block_number:
          nullable: true
          type: integer
        confirmation_duration:
          description: >-
            Array of time intervals in milliseconds. Can be empty [] (no info),
            single value [interval] (means that the transaction was confirmed
            within {interval} milliseconds), or two values [short_interval,
            long_interval] (means that the transaction's confirmation took from
            {short_interval} to {long_interval} milliseconds)
          example:
            - 1000
            - 2000
          items:
            description: Duration in milliseconds
            minimum: 0
            type: integer
          maxItems: 2
          type: array
        confirmations:
          minimum: 0
          type: integer
        created_contract:
          allOf:
            - $ref: '#/components/schemas/Address'
          nullable: true
        decoded_input:
          allOf:
            - $ref: '#/components/schemas/DecodedInput'
          nullable: true
        exchange_rate:
          $ref: '#/components/schemas/FloatStringNullable'
        fee:
          $ref: '#/components/schemas/Fee'
        fhe_operations_count:
          description: >-
            Number of FHE (Fully Homomorphic Encryption) operations in the
            transaction
          type: integer
        from:
          $ref: '#/components/schemas/Address'
        gas_limit:
          $ref: '#/components/schemas/IntegerString'
        gas_price:
          $ref: '#/components/schemas/IntegerStringNullable'
        gas_used:
          $ref: '#/components/schemas/IntegerStringNullable'
        has_error_in_internal_transactions:
          nullable: true
          type: boolean
        hash:
          $ref: '#/components/schemas/FullHash'
        historic_exchange_rate:
          $ref: '#/components/schemas/FloatStringNullable'
        is_pending_update:
          nullable: true
          type: boolean
        max_fee_per_gas:
          $ref: '#/components/schemas/IntegerStringNullable'
        max_priority_fee_per_gas:
          $ref: '#/components/schemas/IntegerStringNullable'
        method:
          $ref: '#/components/schemas/MethodNameNullable'
        nonce:
          minimum: 0
          type: integer
        position:
          minimum: 0
          nullable: true
          type: integer
        priority_fee:
          $ref: '#/components/schemas/IntegerStringNullable'
        raw_input:
          $ref: '#/components/schemas/HexData'
        result:
          anyOf:
            - enum:
                - pending
                - awaiting_internal_transactions
                - success
                - dropped/replaced
              type: string
            - description: Error message
              example: out of gas
              type: string
        revert_reason:
          nullable: true
          oneOf:
            - $ref: '#/components/schemas/DecodedInput'
            - additionalProperties: false
              properties:
                raw:
                  anyOf:
                    - $ref: '#/components/schemas/HexData'
                    - type: string
                  nullable: true
              required:
                - raw
              type: object
        status:
          enum:
            - ok
            - error
          nullable: true
          type: string
        timestamp:
          $ref: '#/components/schemas/TimestampNullable'
        to:
          $ref: '#/components/schemas/Address'
        token_transfers:
          items:
            $ref: '#/components/schemas/TokenTransfer'
          nullable: true
          type: array
        token_transfers_overflow:
          nullable: true
          type: boolean
        transaction_burnt_fee:
          $ref: '#/components/schemas/IntegerStringNullable'
        transaction_tag:
          description: Transaction tag set in My Account
          example: personal
          nullable: true
          type: string
        transaction_types:
          items:
            enum:
              - coin_transfer
              - contract_call
              - contract_creation
              - rootstock_bridge
              - rootstock_remasc
              - token_creation
              - token_transfer
              - blob_transaction
              - set_code_transaction
            type: string
          type: array
        type:
          nullable: true
          type: integer
        value:
          $ref: '#/components/schemas/IntegerString'
      required:
        - hash
        - result
        - status
        - block_number
        - timestamp
        - from
        - to
        - created_contract
        - confirmations
        - confirmation_duration
        - value
        - fee
        - gas_price
        - type
        - gas_used
        - gas_limit
        - max_fee_per_gas
        - max_priority_fee_per_gas
        - base_fee_per_gas
        - priority_fee
        - transaction_burnt_fee
        - nonce
        - position
        - revert_reason
        - raw_input
        - decoded_input
        - token_transfers
        - token_transfers_overflow
        - exchange_rate
        - historic_exchange_rate
        - method
        - transaction_types
        - transaction_tag
        - has_error_in_internal_transactions
        - authorization_list
        - is_pending_update
        - fhe_operations_count
      title: TransactionResponse
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
    TimestampNullable:
      format: date-time
      nullable: true
      title: TimestampNullable
      type: string
    IntegerString:
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerString
      type: string
    SignedAuthorization:
      additionalProperties: false
      properties:
        address_hash:
          $ref: '#/components/schemas/AddressHash'
        authority:
          $ref: '#/components/schemas/AddressHash'
        chain_id:
          type: integer
        nonce:
          $ref: '#/components/schemas/IntegerString'
        r:
          $ref: '#/components/schemas/IntegerString'
        s:
          $ref: '#/components/schemas/IntegerString'
        status:
          enum:
            - ok
            - invalid_chain_id
            - invalid_signature
            - invalid_nonce
          nullable: true
          type: string
        v:
          type: integer
      required:
        - address_hash
        - chain_id
        - nonce
        - r
        - s
        - v
        - authority
        - status
      title: SignedAuthorization
      type: object
    IntegerStringNullable:
      nullable: true
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerStringNullable
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
    DecodedInput:
      additionalProperties: false
      properties:
        method_call:
          nullable: true
          type: string
        method_id:
          nullable: true
          type: string
        parameters:
          items:
            additionalProperties: false
            properties:
              name:
                type: string
              type:
                type: string
              value:
                anyOf:
                  - type: object
                  - items:
                      anyOf:
                        - type: object
                        - items:
                            type: string
                          type: array
                        - type: string
                    type: array
                  - type: string
            type: object
          type: array
      required:
        - method_id
        - method_call
        - parameters
      title: DecodedInput
      type: object
    FloatStringNullable:
      nullable: true
      pattern: ^([1-9][0-9]*|0)(\.[0-9]+)?$
      title: FloatStringNullable
      type: string
    Fee:
      additionalProperties: false
      properties:
        type:
          enum:
            - maximum
            - actual
          type: string
        value:
          $ref: '#/components/schemas/IntegerStringNullable'
      required:
        - type
        - value
      title: Fee
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
    HexData:
      pattern: ^0x([A-Fa-f0-9]*)$
      title: HexData
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