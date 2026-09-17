> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Full-text search for NFTs by query string; optional chain filter and pagination.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /services/multichain/api/v1/clusters/{cluster_id}/search/nfts
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
  /services/multichain/api/v1/clusters/{cluster_id}/search/nfts:
    get:
      tags:
        - ClusterExplorerService
      summary: >-
        Full-text search for NFTs by query string; optional chain filter and
        pagination.
      operationId: ClusterExplorerService_SearchNfts
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
        - description: Comma-separated list of chain ids to filter by.
          in: query
          name: chain_id
          schema:
            items:
              type: string
            type: array
        - in: query
          name: page_size
          schema:
            format: int64
            type: integer
        - in: query
          name: page_token
          schema:
            type: string
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1SearchNftsResponse'
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
    v1SearchNftsResponse:
      properties:
        items:
          items:
            $ref: '#/components/schemas/v1AggregatedTokenInfo'
            type: object
          type: array
        next_page_params:
          $ref: '#/components/schemas/v1Pagination'
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
    v1Pagination:
      properties:
        pageSize:
          format: int64
          type: integer
        pageToken:
          type: string
      type: object
    protobufAny:
      additionalProperties:
        path: >-
          /{chain_id}/api/v2/tokens/{address_hash_param}/instances/{token_id_param}/refetch-metadata
      properties:
        '@type':
          type: string
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