> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List verified smart contracts with optional filtering options

> Retrieves a paginated list of verified smart contracts with optional filtering by proxy status or programming language.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/smart-contracts/
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
  /{chain_id}/api/v2/smart-contracts/:
    get:
      tags:
        - smart-contracts
      summary: List verified smart contracts with optional filtering options
      description: >-
        Retrieves a paginated list of verified smart contracts with optional
        filtering by proxy status or programming language.
      operationId: BlockScoutWeb.API.V2.SmartContractController.smart_contracts_list
      parameters:
        - description: |
            Sort results by:
            * balance - Sort by account balance
            * transactions_count - Sort by number of transactions
            Should be used together with `order` parameter.
          in: query
          name: sort
          schema:
            enum:
              - balance
              - transactions_count
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
        - description: Search query filter
          in: query
          name: q
          schema:
            nullable: true
            type: string
        - description: Filter to apply
          in: query
          name: filter
          schema:
            $ref: '#/components/schemas/Language'
        - description: Number of items per page
          in: query
          name: items_count
          schema:
            minimum: 1
            type: integer
        - description: Smart-contract ID for paging
          in: query
          name: smart_contract_id
          schema:
            type: integer
        - description: Coin balance for paging
          in: query
          name: coin_balance
          schema:
            anyOf:
              - type: integer
              - $ref: '#/components/schemas/EmptyString'
              - $ref: '#/components/schemas/NullString'
        - description: Address hash for paging
          in: query
          name: hash
          schema:
            $ref: '#/components/schemas/AddressHash'
        - description: Transactions count for paging
          in: query
          name: transactions_count
          schema:
            anyOf:
              - type: integer
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
                      $ref: '#/components/schemas/SmartContractListItem'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      smart_contract_id: 1947801
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                type: object
          description: >-
            List of verified smart contracts matching the filter criteria, with
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
        '422':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/JsonErrorResponse'
          description: Unprocessable Entity
components:
  schemas:
    Language:
      enum:
        - solidity
        - vyper
        - yul
        - geas
        - stylus_rust
      title: Language
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
    AddressHash:
      pattern: ^0x([A-Fa-f0-9]{40})$
      title: AddressHash
      type: string
    SmartContractListItem:
      additionalProperties: false
      description: Smart contract list item
      properties:
        address:
          $ref: '#/components/schemas/Address'
        certified:
          type: boolean
        coin_balance:
          nullable: true
          type: string
        compiler_version:
          nullable: true
          type: string
        github_repository_metadata:
          nullable: true
          type: object
        has_constructor_args:
          nullable: true
          type: boolean
        language:
          nullable: true
          type: string
        license_type:
          nullable: true
          type: string
        market_cap:
          nullable: true
          type: string
        optimization_enabled:
          nullable: true
          type: boolean
        package_name:
          nullable: true
          type: string
        reputation:
          nullable: true
          type: string
        transactions_count:
          nullable: true
          type: integer
        verified_at:
          format: date-time
          nullable: true
          type: string
      required:
        - address
        - compiler_version
        - optimization_enabled
        - language
        - verified_at
        - has_constructor_args
        - license_type
        - certified
        - reputation
      title: SmartContractListItem
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