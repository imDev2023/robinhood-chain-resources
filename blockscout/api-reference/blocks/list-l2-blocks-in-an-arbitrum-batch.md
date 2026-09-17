> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List L2 blocks in an Arbitrum batch

> Retrieves L2 blocks that are bound to a specific Arbitrum batch number.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/blocks/arbitrum-batch/{batch_number_param}
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
  /{chain_id}/api/v2/blocks/arbitrum-batch/{batch_number_param}:
    get:
      tags:
        - blocks
      summary: List L2 blocks in an Arbitrum batch
      description: Retrieves L2 blocks that are bound to a specific Arbitrum batch number.
      operationId: BlockScoutWeb.API.V2.BlockController.arbitrum_batch
      parameters:
        - description: Batch number
          in: path
          name: batch_number_param
          required: true
          schema:
            minimum: 0
            type: integer
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
                      $ref: '#/components/schemas/Block'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      block_number: 22566361
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                type: object
          description: L2 blocks in the specified Arbitrum batch.
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
    Block:
      additionalProperties: false
      properties:
        arbitrum:
          additionalProperties: false
          properties:
            batch_data_container:
              enum:
                - in_blob4844
                - in_calldata
                - in_celestia
                - in_anytrust
                - in_eigenda
              nullable: true
              type: string
            batch_number:
              nullable: true
              type: integer
            commitment_transaction:
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
            delayed_messages:
              type: integer
            l1_block_number:
              nullable: true
              type: integer
            send_count:
              nullable: true
              type: integer
            send_root:
              $ref: '#/components/schemas/FullHashNullable'
            status:
              enum:
                - Confirmed on base
                - Sent to base
                - Sealed on rollup
                - Processed on rollup
              type: string
          required:
            - batch_number
            - status
            - commitment_transaction
            - confirmation_transaction
          type: object
        base_fee_per_gas:
          description: >-
            EIP-1559 base fee per gas, in wei. Null on blocks produced before
            EIP-1559 activation or on chains that do not implement EIP-1559.
          nullable: true
          pattern: ^-?([1-9][0-9]*|0)$
          type: string
        burnt_fees:
          description: >-
            Sum of EIP-1559 base fees burned by transactions in this block, in
            wei.
          nullable: true
          pattern: ^-?([1-9][0-9]*|0)$
          type: string
        burnt_fees_percentage:
          description: >-
            Burned base fees as a percentage of total transaction fees in this
            block.
          format: float
          nullable: true
          type: number
        difficulty:
          description: >-
            Proof-of-work difficulty of this block. Zero on proof-of-stake
            chains.
          nullable: true
          pattern: ^-?([1-9][0-9]*|0)$
          type: string
        gas_limit:
          $ref: '#/components/schemas/IntegerString'
        gas_target_percentage:
          description: >-
            Percent above the EIP-1559 elasticity target (gas_used vs. gas_limit
            / elasticity_multiplier).
          format: float
          type: number
        gas_used:
          $ref: '#/components/schemas/IntegerString'
        gas_used_percentage:
          description: Gas used in this block as a percentage of `gas_limit`.
          format: float
          type: number
        hash:
          $ref: '#/components/schemas/FullHash'
        height:
          description: Block number (zero-based index from genesis).
          minimum: 0
          type: integer
        internal_transactions_count:
          description: >-
            Number of internal transactions in this block; null when the count
            is unavailable.
          minimum: 0
          nullable: true
          type: integer
        is_pending_update:
          description: >-
            True when the block is scheduled for re-fetch; its fields may change
            once re-fetching completes.
          nullable: true
          type: boolean
        miner:
          allOf:
            - $ref: '#/components/schemas/Address'
          description: >-
            Address credited with the block — the miner on PoW chains, the fee
            recipient / proposer on PoS chains, and the sequencer on rollups.
        nonce:
          description: >-
            Proof-of-work nonce used to satisfy the difficulty target. Zero on
            proof-of-stake chains.
          pattern: ^0x([A-Fa-f0-9]*)$
          type: string
        parent_hash:
          $ref: '#/components/schemas/FullHash'
        priority_fee:
          description: >-
            Sum of validator tips (EIP-1559 priority fees) paid by transactions
            in this block, in wei.
          nullable: true
          pattern: ^-?([1-9][0-9]*|0)$
          type: string
        rewards:
          description: >-
            Block rewards grouped by recipient category. Each entry describes a
            reward paid for this block; the set of categories depends on the
            chain and block type.
          items:
            additionalProperties: false
            properties:
              reward:
                $ref: '#/components/schemas/IntegerString'
              type:
                description: Reward category (machine-readable identifier).
                enum:
                  - emission_funds
                  - uncle
                  - validator
                type: string
            required:
              - type
              - reward
            type: object
          type: array
        size:
          description: Block size in bytes (length of the RLP-encoded block).
          minimum: 0
          nullable: true
          type: integer
        timestamp:
          $ref: '#/components/schemas/Timestamp'
        total_difficulty:
          description: >-
            Cumulative chain difficulty through this block (sum of `difficulty`
            of this block and all ancestors).
          nullable: true
          pattern: ^-?([1-9][0-9]*|0)$
          type: string
        transaction_fees:
          description: >-
            Sum of transaction fees (gas price × gas used) paid by transactions
            in this block, in wei.
          pattern: ^-?([1-9][0-9]*|0)$
          type: string
        transactions_count:
          minimum: 0
          type: integer
        type:
          description: >-
            Block classification: `block` = main-chain consensus block; `uncle`
            = ommer (valid but not in main chain); `reorg` = former main-chain
            block lost to reorganization.
          enum:
            - block
            - uncle
            - reorg
          type: string
        uncles_hashes:
          description: Hashes of ommer (uncle) blocks referenced by this block.
          items:
            additionalProperties: false
            properties:
              hash:
                $ref: '#/components/schemas/FullHash'
            required:
              - hash
            type: object
          type: array
        withdrawals_count:
          description: >-
            Number of withdrawals included in this block; null when the count is
            unavailable.
          minimum: 0
          nullable: true
          type: integer
      required:
        - height
        - timestamp
        - transactions_count
        - internal_transactions_count
        - miner
        - size
        - hash
        - parent_hash
        - difficulty
        - total_difficulty
        - gas_used
        - gas_limit
        - nonce
        - base_fee_per_gas
        - burnt_fees
        - priority_fee
        - uncles_hashes
        - rewards
        - gas_target_percentage
        - gas_used_percentage
        - burnt_fees_percentage
        - type
        - transaction_fees
        - withdrawals_count
        - is_pending_update
      title: Block
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
    FullHash:
      pattern: ^0x([A-Fa-f0-9]{64})$
      title: FullHash
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
    Timestamp:
      format: date-time
      title: Timestamp
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