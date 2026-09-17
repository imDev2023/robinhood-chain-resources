> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get a user operation by hash

> Retrieves a user operation by its hash.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/proxy/account-abstraction/operations/{operation_hash_param}
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
  /{chain_id}/api/v2/proxy/account-abstraction/operations/{operation_hash_param}:
    get:
      tags:
        - account-abstraction
      summary: Get a user operation by hash
      description: Retrieves a user operation by its hash.
      operationId: BlockScoutWeb.API.V2.Proxy.AccountAbstractionController.operation
      parameters:
        - description: User operation hash in the path
          in: path
          name: operation_hash_param
          required: true
          schema:
            $ref: '#/components/schemas/FullHash'
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
                $ref: '#/components/schemas/UserOperation'
          description: User operation
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
        '404':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/NotFoundResponse'
          description: Not Found
        '501':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/NotImplementedResponse'
          description: Not Implemented
components:
  schemas:
    FullHash:
      pattern: ^0x([A-Fa-f0-9]{64})$
      title: FullHash
      type: string
    UserOperation:
      additionalProperties: false
      description: UserOperation struct.
      properties:
        aggregator:
          $ref: '#/components/schemas/AddressHashNullable'
        aggregator_signature:
          $ref: '#/components/schemas/HexDataNullable'
        block_hash:
          $ref: '#/components/schemas/FullHash'
        block_number:
          $ref: '#/components/schemas/IntegerString'
        bundle_index:
          type: integer
        bundler:
          $ref: '#/components/schemas/Address'
        call_data:
          $ref: '#/components/schemas/HexData'
        call_gas_limit:
          $ref: '#/components/schemas/IntegerString'
        consensus:
          nullable: true
          type: boolean
        decoded_call_data:
          allOf:
            - $ref: '#/components/schemas/DecodedInput'
          nullable: true
        decoded_execute_call_data:
          allOf:
            - $ref: '#/components/schemas/DecodedInput'
          nullable: true
        entry_point:
          $ref: '#/components/schemas/Address'
        entry_point_version:
          enum:
            - v0.6
            - v0.7
            - v0.8
            - v0.9
          type: string
        execute_call_data:
          $ref: '#/components/schemas/HexDataNullable'
        execute_target:
          $ref: '#/components/schemas/AddressNullable'
        factory:
          $ref: '#/components/schemas/AddressNullable'
        fee:
          $ref: '#/components/schemas/IntegerString'
        gas:
          $ref: '#/components/schemas/IntegerString'
        gas_price:
          $ref: '#/components/schemas/IntegerString'
        gas_used:
          $ref: '#/components/schemas/IntegerString'
        hash:
          $ref: '#/components/schemas/FullHash'
        index:
          type: integer
        max_fee_per_gas:
          $ref: '#/components/schemas/IntegerString'
        max_priority_fee_per_gas:
          $ref: '#/components/schemas/IntegerString'
        nonce:
          $ref: '#/components/schemas/FullHash'
        paymaster:
          $ref: '#/components/schemas/AddressNullable'
        pre_verification_gas:
          $ref: '#/components/schemas/IntegerString'
        raw:
          anyOf:
            - additionalProperties: false
              description: Raw user operation data v0.6.
              properties:
                call_data:
                  $ref: '#/components/schemas/HexData'
                call_gas_limit:
                  $ref: '#/components/schemas/IntegerString'
                init_code:
                  $ref: '#/components/schemas/HexData'
                max_fee_per_gas:
                  $ref: '#/components/schemas/IntegerString'
                max_priority_fee_per_gas:
                  $ref: '#/components/schemas/IntegerString'
                nonce:
                  $ref: '#/components/schemas/IntegerString'
                paymaster_and_data:
                  $ref: '#/components/schemas/HexData'
                pre_verification_gas:
                  $ref: '#/components/schemas/IntegerString'
                sender:
                  $ref: '#/components/schemas/AddressHash'
                signature:
                  $ref: '#/components/schemas/HexData'
                verification_gas_limit:
                  $ref: '#/components/schemas/IntegerString'
              required:
                - sender
                - nonce
                - init_code
                - call_data
                - call_gas_limit
                - verification_gas_limit
                - pre_verification_gas
                - max_fee_per_gas
                - max_priority_fee_per_gas
                - paymaster_and_data
                - signature
              type: object
            - additionalProperties: false
              description: Raw user operation data v0.7-v0.9.
              properties:
                account_gas_limits:
                  $ref: '#/components/schemas/FullHash'
                call_data:
                  $ref: '#/components/schemas/HexData'
                gas_fees:
                  $ref: '#/components/schemas/FullHash'
                init_code:
                  $ref: '#/components/schemas/HexData'
                nonce:
                  $ref: '#/components/schemas/IntegerString'
                paymaster_and_data:
                  $ref: '#/components/schemas/HexData'
                pre_verification_gas:
                  $ref: '#/components/schemas/IntegerString'
                sender:
                  $ref: '#/components/schemas/AddressHash'
                signature:
                  $ref: '#/components/schemas/HexData'
              required:
                - sender
                - nonce
                - init_code
                - call_data
                - account_gas_limits
                - pre_verification_gas
                - gas_fees
                - paymaster_and_data
                - signature
              type: object
          description: Raw user operation data.
        revert_reason:
          $ref: '#/components/schemas/HexDataNullable'
        sender:
          $ref: '#/components/schemas/Address'
        signature:
          $ref: '#/components/schemas/HexData'
        sponsor_type:
          enum:
            - wallet_deposit
            - wallet_balance
            - paymaster_sponsor
            - paymaster_hybrid
          type: string
        status:
          type: boolean
        timestamp:
          $ref: '#/components/schemas/TimestampNullable'
        transaction_hash:
          $ref: '#/components/schemas/FullHash'
        user_logs_count:
          type: integer
        user_logs_start_index:
          type: integer
        verification_gas_limit:
          $ref: '#/components/schemas/IntegerString'
      required:
        - hash
        - sender
        - nonce
        - call_data
        - call_gas_limit
        - verification_gas_limit
        - pre_verification_gas
        - max_fee_per_gas
        - max_priority_fee_per_gas
        - signature
        - raw
        - aggregator
        - aggregator_signature
        - entry_point
        - entry_point_version
        - transaction_hash
        - block_number
        - block_hash
        - bundler
        - bundle_index
        - index
        - factory
        - paymaster
        - status
        - revert_reason
        - gas
        - gas_price
        - gas_used
        - sponsor_type
        - user_logs_start_index
        - user_logs_count
        - fee
        - consensus
        - timestamp
        - execute_target
        - execute_call_data
        - decoded_call_data
        - decoded_execute_call_data
      title: UserOperation
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
    NotFoundResponse:
      description: Response returned when the requested resource is not found
      properties:
        message:
          description: Error message indicating the requested resource was not found
          example: Resource not found
          type: string
      title: NotFoundResponse
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
    AddressHashNullable:
      nullable: true
      pattern: ^0x([A-Fa-f0-9]{40})$
      title: AddressHashNullable
      type: string
    HexDataNullable:
      nullable: true
      pattern: ^0x([A-Fa-f0-9]*)$
      title: HexDataNullable
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
    HexData:
      pattern: ^0x([A-Fa-f0-9]*)$
      title: HexData
      type: string
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
    AddressNullable:
      additionalProperties: false
      description: AddressNullable
      nullable: true
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
      title: AddressNullable
      type: object
    AddressHash:
      pattern: ^0x([A-Fa-f0-9]{40})$
      title: AddressHash
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