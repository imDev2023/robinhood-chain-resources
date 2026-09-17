> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List internal transactions generated during smart contract execution

> Retrieves a paginated list of internal transactions. Internal transactions are generated during contract execution and not directly recorded on the blockchain.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/internal-transactions
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
  /{chain_id}/api/v2/internal-transactions:
    get:
      tags:
        - internal-transactions
      summary: List internal transactions generated during smart contract execution
      description: >-
        Retrieves a paginated list of internal transactions. Internal
        transactions are generated during contract execution and not directly
        recorded on the blockchain.
      operationId: BlockScoutWeb.API.V2.InternalTransactionController.internal_transactions
      parameters:
        - description: Transaction hash in the query
          in: query
          name: transaction_hash
          schema:
            $ref: '#/components/schemas/FullHash'
        - description: Limit result items in the response
          in: query
          name: limit
          schema:
            nullable: true
            type: integer
        - description: >-
            If `false`, zero-value call-type internal transactions are excluded
            from results.
          in: query
          name: include_zero_value
          schema:
            default: true
            type: boolean
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
        - description: Transaction index for paging
          in: query
          name: transaction_index
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
                      $ref: '#/components/schemas/InternalTransaction'
                    type: array
                  meta:
                    properties:
                      message:
                        nullable: true
                        type: string
                      status:
                        enum:
                          - 1
                          - 2
                        type: integer
                    required:
                      - status
                      - message
                    type: object
                  next_page_params:
                    additionalProperties: true
                    example:
                      block_number: 22133247
                      index: 50
                      transaction_index: 68
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                  - meta
                type: object
          description: List of internal transactions with pagination information.
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
    FullHash:
      pattern: ^0x([A-Fa-f0-9]{64})$
      title: FullHash
      type: string
    InternalTransaction:
      additionalProperties: false
      properties:
        block_number:
          type: integer
        created_contract:
          allOf:
            - $ref: '#/components/schemas/Address'
          nullable: true
        error:
          nullable: true
          type: string
        from:
          $ref: '#/components/schemas/Address'
        gas_limit:
          $ref: '#/components/schemas/IntegerStringNullable'
        index:
          description: The index of this internal transaction inside the transaction.
          type: integer
        success:
          type: boolean
        timestamp:
          $ref: '#/components/schemas/Timestamp'
        to:
          allOf:
            - $ref: '#/components/schemas/Address'
          nullable: true
        transaction_hash:
          $ref: '#/components/schemas/FullHash'
        transaction_index:
          description: The index of the parent transaction inside the block.
          type: integer
        type:
          description: Type of the internal transaction (call, create, etc.)
          type: string
        value:
          $ref: '#/components/schemas/IntegerString'
      required:
        - error
        - success
        - type
        - transaction_hash
        - transaction_index
        - from
        - to
        - created_contract
        - value
        - block_number
        - timestamp
        - index
        - gas_limit
      title: InternalTransaction
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
    Timestamp:
      format: date-time
      title: Timestamp
      type: string
    IntegerString:
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerString
      type: string
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