> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Lists all chains in the cluster, optionally sorted by a metric (e.g. active_accounts, tps).



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /services/multichain/api/v1/clusters/{cluster_id}/chains
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
  /services/multichain/api/v1/clusters/{cluster_id}/chains:
    get:
      tags:
        - ClusterExplorerService
      summary: >-
        Lists all chains in the cluster, optionally sorted by a metric (e.g.
        active_accounts, tps).
      operationId: ClusterExplorerService_ListClusterChains
      parameters:
        - in: path
          name: cluster_id
          required: true
          schema:
            type: string
        - description: >-
            Metric used to sort chains. Supported values: active_accounts,
            daily_transactions,

            new_addresses, tps. Defaults to active_accounts.
          in: query
          name: sort
          schema:
            type: string
        - description: >-
            Sort order: "asc" or "desc". Defaults to "desc" (higher values
            first).
          in: query
          name: order
          schema:
            type: string
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1ListClusterChainsResponse'
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
    v1ListClusterChainsResponse:
      properties:
        items:
          items:
            $ref: '#/components/schemas/v1Chain'
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
    v1Chain:
      properties:
        explorer_url:
          type: string
        icon_url:
          type: string
        id:
          type: string
        name:
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