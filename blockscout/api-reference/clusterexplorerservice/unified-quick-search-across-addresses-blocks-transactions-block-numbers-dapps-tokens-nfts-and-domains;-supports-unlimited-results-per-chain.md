> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Unified quick search across addresses, blocks, transactions, block numbers, dapps, tokens, NFTs, and domains; supports unlimited results per chain.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /services/multichain/api/v1/clusters/{cluster_id}/search:quick
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
  /services/multichain/api/v1/clusters/{cluster_id}/search:quick:
    get:
      tags:
        - ClusterExplorerService
      summary: >-
        Unified quick search across addresses, blocks, transactions, block
        numbers, dapps, tokens, NFTs, and domains; supports unlimited results
        per chain.
      operationId: ClusterExplorerService_QuickSearch
      parameters:
        - in: path
          name: cluster_id
          required: true
          schema:
            type: string
        - in: query
          name: q
          schema:
            type: string
        - in: query
          name: unlimited_per_chain
          schema:
            type: boolean
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1ClusterQuickSearchResponse'
          description: A successful response.
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
        default:
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/googlerpcStatus'
          description: An unexpected error response.
components:
  schemas:
    v1ClusterQuickSearchResponse:
      properties:
        addresses:
          items:
            $ref: '#/components/schemas/v1GetAddressResponse'
            type: object
          type: array
        block_numbers:
          items:
            $ref: '#/components/schemas/v1ChainBlockNumber'
            type: object
          type: array
        blocks:
          items:
            $ref: '#/components/schemas/v1Hash'
            type: object
          type: array
        dapps:
          items:
            $ref: '#/components/schemas/v1MarketplaceDapp'
            type: object
          type: array
        domains:
          items:
            $ref: '#/components/schemas/v1Domain'
            type: object
          type: array
        nfts:
          items:
            $ref: '#/components/schemas/v1AggregatedTokenInfo'
            type: object
          type: array
        tokens:
          items:
            $ref: '#/components/schemas/v1AggregatedTokenInfo'
            type: object
          type: array
        transactions:
          items:
            $ref: '#/components/schemas/v1Hash'
            type: object
          type: array
      type: object
    googlerpcStatus:
      properties:
        code:
          format: int32
          type: integer
        details:
          items:
            $ref: '#/components/schemas/protobufAny'
            type: object
          type: array
        message:
          type: string
      type: object
    v1GetAddressResponse:
      properties:
        chain_infos:
          additionalProperties:
            $ref: '#/components/schemas/v1GetAddressResponseChainInfo'
          description: Map of chain id to chain-specific information.
          type: object
        coin_balance:
          description: Sum of coin balances across all chains.
          type: string
        domains:
          items:
            $ref: '#/components/schemas/v1BasicDomainInfo'
            type: object
          type: array
        exchange_rate:
          description: Exchange rate of the cluster native coin.
          type: string
        has_interop_message_transfers:
          type: boolean
        has_tokens:
          type: boolean
        hash:
          type: string
      type: object
    v1ChainBlockNumber:
      properties:
        block_number:
          format: uint64
          type: string
        chain_id:
          format: int64
          type: string
      type: object
    v1Hash:
      properties:
        chain_id:
          type: string
        hash:
          type: string
        hash_type:
          $ref: '#/components/schemas/v1HashType'
      type: object
    v1MarketplaceDapp:
      properties:
        chain_id:
          type: string
        id:
          type: string
        logo:
          type: string
        short_description:
          type: string
        title:
          type: string
      type: object
    v1Domain:
      properties:
        address:
          type: string
        expiry_date:
          type: string
        name:
          type: string
        protocol:
          $ref: '#/components/schemas/v1ProtocolInfo'
      type: object
    v1AggregatedTokenInfo:
      properties:
        address_hash:
          type: string
        chain_infos:
          additionalProperties:
            $ref: '#/components/schemas/v1AggregatedTokenInfoChainInfo'
          description: Map of chain id to chain-specific information.
          type: object
        circulating_market_cap:
          type: string
        decimals:
          type: string
        exchange_rate:
          type: string
        holders_count:
          type: string
        icon_url:
          type: string
        name:
          type: string
        symbol:
          type: string
        total_supply:
          type: string
        type:
          $ref: '#/components/schemas/v1TokenType'
      type: object
    protobufAny:
      additionalProperties:
        path: >-
          /{chain_id}/api/v2/tokens/{address_hash_param}/instances/{token_id_param}/refetch-metadata
      properties:
        '@type':
          type: string
      type: object
    v1GetAddressResponseChainInfo:
      description: Chain-specific information.
      properties:
        coin_balance:
          type: string
        contract_name:
          type: string
        is_contract:
          type: boolean
        is_verified:
          type: boolean
      type: object
    v1BasicDomainInfo:
      properties:
        name:
          type: string
        protocol:
          $ref: '#/components/schemas/v1ProtocolInfo'
      type: object
    v1HashType:
      default: HASH_TYPE_BLOCK
      enum:
        - HASH_TYPE_BLOCK
        - HASH_TYPE_TRANSACTION
      type: string
    v1ProtocolInfo:
      properties:
        deployment_blockscout_base_url:
          type: string
        description:
          type: string
        docs_url:
          type: string
        icon_url:
          type: string
        id:
          type: string
        short_name:
          type: string
        title:
          type: string
        tld_list:
          items:
            type: string
          type: array
      type: object
    v1AggregatedTokenInfoChainInfo:
      properties:
        contract_name:
          type: string
        holders_count:
          type: string
        is_verified:
          type: boolean
        total_supply:
          type: string
      type: object
    v1TokenType:
      default: TOKEN_TYPE_UNSPECIFIED
      enum:
        - TOKEN_TYPE_UNSPECIFIED
        - TOKEN_TYPE_ERC_20
        - TOKEN_TYPE_ERC_721
        - TOKEN_TYPE_ERC_1155
        - TOKEN_TYPE_ERC_404
        - TOKEN_TYPE_ERC_7802
        - TOKEN_TYPE_ZRC_2
        - TOKEN_TYPE_NATIVE
        - TOKEN_TYPE_ERC_7984
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