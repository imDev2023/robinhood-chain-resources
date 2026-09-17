> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List of recent user operations

> Retrieves a list of recent user operations.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/proxy/account-abstraction/operations
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
  /{chain_id}/api/v2/proxy/account-abstraction/operations:
    get:
      tags:
        - account-abstraction
      summary: List of recent user operations
      description: Retrieves a list of recent user operations.
      operationId: BlockScoutWeb.API.V2.Proxy.AccountAbstractionController.operations
      parameters:
        - description: User operation sender address hash
          in: query
          name: sender
          schema:
            $ref: '#/components/schemas/AddressHash'
        - description: User operation bundler address hash
          in: query
          name: bundler
          schema:
            $ref: '#/components/schemas/AddressHash'
        - description: User operation paymaster address hash
          in: query
          name: paymaster
          schema:
            $ref: '#/components/schemas/AddressHash'
        - description: User operation factory address hash
          in: query
          name: factory
          schema:
            $ref: '#/components/schemas/AddressHash'
        - description: Transaction hash in the query
          in: query
          name: transaction_hash
          schema:
            $ref: '#/components/schemas/FullHash'
        - description: User operation entry point address hash
          in: query
          name: entry_point
          schema:
            $ref: '#/components/schemas/AddressHash'
        - description: User operation bundle index
          in: query
          name: bundle_index
          schema:
            minimum: 0
            type: integer
        - description: User operation block number
          in: query
          name: block_number
          schema:
            minimum: 0
            type: integer
        - description: Number of items per page
          in: query
          name: items_count
          schema:
            minimum: 1
            type: integer
        - description: Number of items returned per page
          in: query
          name: page_size
          schema:
            maximum: 50
            minimum: 1
            type: integer
        - description: Page token for paging
          in: query
          name: page_token
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
                      $ref: '#/components/schemas/UserOperationInList'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      page_size: 50
                      page_token: >-
                        3937439,0xbb680271614883525ac8056c388489e80b3518ec12ec46e1b910c7238c46b565
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                type: object
          description: List of user operations with pagination.
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
        '400':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/BadRequestResponse'
          description: Bad Request
        '501':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/NotImplementedResponse'
          description: Not Implemented
components:
  schemas:
    AddressHash:
      pattern: ^0x([A-Fa-f0-9]{40})$
      title: AddressHash
      type: string
    FullHash:
      pattern: ^0x([A-Fa-f0-9]{64})$
      title: FullHash
      type: string
    UserOperationInList:
      additionalProperties: false
      description: UserOperationInList struct.
      properties:
        address:
          $ref: '#/components/schemas/Address'
        block_number:
          $ref: '#/components/schemas/IntegerString'
        entry_point:
          $ref: '#/components/schemas/Address'
        entry_point_version:
          enum:
            - v0.6
            - v0.7
            - v0.8
            - v0.9
          type: string
        fee:
          $ref: '#/components/schemas/IntegerString'
        hash:
          $ref: '#/components/schemas/FullHash'
        status:
          type: boolean
        timestamp:
          $ref: '#/components/schemas/TimestampNullable'
        transaction_hash:
          $ref: '#/components/schemas/FullHash'
      required:
        - hash
        - address
        - entry_point
        - entry_point_version
        - transaction_hash
        - block_number
        - status
        - fee
        - timestamp
      title: UserOperationInList
      type: object
    BadRequestResponse:
      description: Response returned when the request is invalid
      properties:
        message:
          description: Error message indicating the request is invalid
          example: Invalid request
          type: string
      title: BadRequestResponse
      type: object
    NotImplementedResponse:
      description: Response returned when the feature is not implemented
      properties:
        message:
          description: Error message indicating the feature is not implemented
          example: Feature not implemented
          type: string
      title: NotImplementedResponse
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
    IntegerString:
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerString
      type: string
    TimestampNullable:
      format: date-time
      nullable: true
      title: TimestampNullable
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