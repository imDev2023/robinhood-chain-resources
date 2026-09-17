> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List FHE operations for a specific transaction

> Retrieves Fully Homomorphic Encryption (FHE) operations parsed from transaction logs. Includes operation details, HCU (Homomorphic Compute Unit) costs, operation types, and related metadata.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/transactions/{transaction_hash_param}/fhe-operations
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
  /{chain_id}/api/v2/transactions/{transaction_hash_param}/fhe-operations:
    get:
      tags:
        - transactions
      summary: List FHE operations for a specific transaction
      description: >-
        Retrieves Fully Homomorphic Encryption (FHE) operations parsed from
        transaction logs. Includes operation details, HCU (Homomorphic Compute
        Unit) costs, operation types, and related metadata.
      operationId: BlockScoutWeb.API.V2.TransactionController.fhe_operations
      parameters:
        - description: Transaction hash in the path
          in: path
          name: transaction_hash_param
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
                $ref: '#/components/schemas/FheOperationsResponse'
          description: >-
            FHE operations for the specified transaction with transaction-level
            metrics.
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
    FheOperationsResponse:
      additionalProperties: false
      properties:
        items:
          items:
            allOf:
              - $ref: '#/components/schemas/FheOperation'
          type: array
        max_depth_hcu:
          description: Maximum HCU depth across all operations in the transaction
          example: 3
          minimum: 0
          type: integer
        operation_count:
          description: Total number of FHE operations in the transaction
          example: 5
          minimum: 0
          type: integer
        total_hcu:
          description: >-
            Total HCU (Homomorphic Compute Units) cost for all operations in the
            transaction
          example: 500
          minimum: 0
          type: integer
      required:
        - items
        - total_hcu
        - max_depth_hcu
        - operation_count
      title: FheOperationsResponse
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
    FheOperation:
      additionalProperties: false
      properties:
        block_number:
          example: 12345678
          type: integer
        caller:
          allOf:
            - $ref: '#/components/schemas/Address'
          nullable: true
        fhe_type:
          enum:
            - Bool
            - Uint8
            - Uint16
            - Uint32
            - Uint64
            - Uint128
            - Uint160
            - Uint256
            - Bytes64
            - Bytes128
            - Bytes256
          example: Uint8
          type: string
        hcu_cost:
          example: 100
          minimum: 0
          type: integer
        hcu_depth:
          example: 1
          minimum: 0
          type: integer
        inputs:
          additionalProperties: false
          properties:
            control:
              nullable: true
              type: string
            ct:
              nullable: true
              type: string
            if_false:
              nullable: true
              type: string
            if_true:
              nullable: true
              type: string
            lhs:
              nullable: true
              type: string
            plaintext:
              nullable: true
              type: number
            rhs:
              nullable: true
              type: string
          type: object
        is_scalar:
          example: false
          type: boolean
        log_index:
          type: integer
        operation:
          example: FheAdd
          type: string
        result:
          $ref: '#/components/schemas/HexData'
        type:
          enum:
            - arithmetic
            - bitwise
            - comparison
            - unary
            - control
            - encryption
            - random
          example: arithmetic
          type: string
      required:
        - log_index
        - operation
        - type
        - fhe_type
        - is_scalar
        - hcu_cost
        - hcu_depth
        - inputs
        - result
        - block_number
      title: FheOperation
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
    HexData:
      pattern: ^0x([A-Fa-f0-9]*)$
      title: HexData
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