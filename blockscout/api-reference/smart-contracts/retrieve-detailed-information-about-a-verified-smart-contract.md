> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Retrieve detailed information about a verified smart contract

> Retrieves detailed information about a specific verified smart contract, including source code, ABI, and deployment details.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/smart-contracts/{address_hash_param}
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
  /{chain_id}/api/v2/smart-contracts/{address_hash_param}:
    get:
      tags:
        - smart-contracts
      summary: Retrieve detailed information about a verified smart contract
      description: >-
        Retrieves detailed information about a specific verified smart contract,
        including source code, ABI, and deployment details.
      operationId: BlockScoutWeb.API.V2.SmartContractController.smart_contract
      parameters:
        - description: Address hash in the path
          in: path
          name: address_hash_param
          required: true
          schema:
            $ref: '#/components/schemas/AddressHash'
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
                $ref: '#/components/schemas/SmartContract'
          description: Detailed information about the specified verified smart contract.
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
components:
  schemas:
    AddressHash:
      pattern: ^0x([A-Fa-f0-9]{40})$
      title: AddressHash
      type: string
    SmartContract:
      additionalProperties: false
      description: Smart contract
      properties:
        abi:
          items:
            type: object
          nullable: true
          type: array
        additional_sources:
          items:
            properties:
              file_path:
                type: string
              source_code:
                type: string
            type: object
          nullable: true
          type: array
        can_be_visualized_via_sol2uml:
          nullable: true
          type: boolean
        certified:
          type: boolean
        coin_balance:
          nullable: true
          type: string
        compiler_settings:
          nullable: true
          type: object
        compiler_version:
          nullable: true
          type: string
        conflicting_implementations:
          items:
            type: object
          nullable: true
          type: array
        constructor_args:
          nullable: true
          type: string
        creation_bytecode:
          nullable: true
          type: string
        creation_status:
          nullable: true
          type: string
        decoded_constructor_args:
          items:
            items:
              anyOf:
                - type: object
                - type: string
            type: array
          nullable: true
          type: array
        deployed_bytecode:
          nullable: true
          type: string
        evm_version:
          nullable: true
          type: string
        external_libraries:
          items:
            properties:
              address_hash:
                $ref: '#/components/schemas/AddressHash'
              name:
                nullable: true
                type: string
            type: object
          nullable: true
          type: array
        file_path:
          nullable: true
          type: string
        github_repository_metadata:
          nullable: true
          type: object
        has_constructor_args:
          nullable: true
          type: boolean
        implementations:
          items:
            properties:
              address_hash:
                $ref: '#/components/schemas/AddressHash'
              name:
                nullable: true
                type: string
            type: object
          nullable: true
          type: array
        is_blueprint:
          nullable: true
          type: boolean
        is_changed_bytecode:
          nullable: true
          type: boolean
        is_fully_verified:
          nullable: true
          type: boolean
        is_partially_verified:
          nullable: true
          type: boolean
        is_verified:
          nullable: true
          type: boolean
        is_verified_via_eth_bytecode_db:
          nullable: true
          type: boolean
        is_verified_via_sourcify:
          nullable: true
          type: boolean
        is_verified_via_verifier_alliance:
          nullable: true
          type: boolean
        language:
          enum:
            - solidity
            - vyper
            - yul
            - scilla
            - stylus_rust
            - geas
          nullable: true
          type: string
        license_type:
          nullable: true
          type: string
        market_cap:
          nullable: true
          type: string
        name:
          nullable: true
          type: string
        optimization_enabled:
          nullable: true
          type: boolean
        optimization_runs:
          nullable: true
          type: integer
        package_name:
          nullable: true
          type: string
        proxy_type:
          nullable: true
          type: string
        reputation:
          nullable: true
          type: string
        source_code:
          nullable: true
          type: string
        sourcify_repo_url:
          nullable: true
          type: string
        transactions_count:
          nullable: true
          type: integer
        verification_metadata:
          nullable: true
          type: object
        verified_at:
          format: date-time
          nullable: true
          type: string
        verified_twin_address_hash:
          nullable: true
          type: string
      required:
        - proxy_type
        - implementations
        - conflicting_implementations
        - deployed_bytecode
        - creation_bytecode
        - creation_status
      title: SmartContract
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