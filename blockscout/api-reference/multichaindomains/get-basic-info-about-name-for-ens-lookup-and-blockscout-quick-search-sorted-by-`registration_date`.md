> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get basic info about name for ens-lookup and blockscout quick-search. Sorted by `registration_date`



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /services/bens/api/v1/domains:lookup
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
  /services/bens/api/v1/domains:lookup:
    get:
      tags:
        - MultichainDomains
      summary: >-
        Get basic info about name for ens-lookup and blockscout quick-search.
        Sorted by `registration_date`
      operationId: MultichainDomains_LookupDomainNameMultichain
      parameters:
        - description: >-
            Optional. Name of domain, for example vitalik.eth. None means lookup
            for any name
          in: query
          name: name
          schema:
            type: string
        - description: The chain (network) where domain search should be done
          in: query
          name: chain_id
          schema:
            format: int64
            type: string
        - description: comma separated list of protocol ids. Default is ENS protocol only
          in: query
          name: protocols
          schema:
            type: string
        - description: >-
            If true, search across all supported protocols and ignore
            `protocols`.

            When `chain_id` is set, the search is scoped to all protocols on
            that chain.
          in: query
          name: all_protocols
          schema:
            type: boolean
        - description: Filtering field to remove expired names
          in: query
          name: only_active
          schema:
            type: boolean
        - description: Sorting field. Default is `registration_date`
          in: query
          name: sort
          schema:
            type: string
        - description: Order direction. Default is DESC
          in: query
          name: order
          schema:
            default: ORDER_UNSPECIFIED
            enum:
              - ORDER_UNSPECIFIED
              - ASC
              - DESC
            type: string
        - description: Optional. Max number of items in single response. Default is 50
          in: query
          name: page_size
          schema:
            format: int64
            type: integer
        - description: Optional. Value of `.pagination.page_token` from previous response
          in: query
          name: page_token
          schema:
            type: string
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1LookupAddressResponse'
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
    v1LookupAddressResponse:
      properties:
        items:
          items:
            $ref: '#/components/schemas/v1Domain'
            type: object
          title: >-
            List of domains that resolved to or owned by requested address

            Sorted by relevance, so first address could be displayed as main
            resolved address
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