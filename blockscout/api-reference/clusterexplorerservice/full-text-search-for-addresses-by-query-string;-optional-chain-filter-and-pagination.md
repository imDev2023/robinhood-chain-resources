> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Full-text search for addresses by query string; optional chain filter and pagination.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /services/multichain/api/v1/clusters/{cluster_id}/search/addresses
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
  /services/multichain/api/v1/clusters/{cluster_id}/search/addresses:
    get:
      tags:
        - ClusterExplorerService
      summary: >-
        Full-text search for addresses by query string; optional chain filter
        and pagination.
      operationId: ClusterExplorerService_SearchAddresses
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
                $ref: '#/components/schemas/v1SearchAddressesResponse'
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
    v1SearchAddressesResponse:
      properties:
        items:
          items:
            $ref: '#/components/schemas/v1GetAddressResponse'
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