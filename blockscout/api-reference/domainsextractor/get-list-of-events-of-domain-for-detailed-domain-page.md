> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get list of events of domain for Detailed domain page



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /services/bens/api/v1/{chain_id}/domains/{name}/events
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
  /services/bens/api/v1/{chain_id}/domains/{name}/events:
    get:
      tags:
        - DomainsExtractor
      summary: Get list of events of domain for Detailed domain page
      operationId: DomainsExtractor_ListDomainEvents
      parameters:
        - description: The chain (network) where domain search should be done
          in: path
          name: chain_id
          required: true
          schema:
            format: int64
            type: string
        - description: Name of domain, for example vitalik.eth
          in: path
          name: name
          required: true
          schema:
            type: string
        - description: Sorting field. Default is `timestamp`
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
        - description: >-
            Protocol id of domain, default is first priority protocol on that
            chain
          in: query
          name: protocol_id
          schema:
            type: string
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1ListDomainEventsResponse'
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
    v1ListDomainEventsResponse:
      properties:
        items:
          items:
            $ref: '#/components/schemas/v1DomainEvent'
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
    v1DomainEvent:
      properties:
        action:
          title: Optional. Action name
          type: string
        from_address:
          $ref: '#/components/schemas/v1Address'
          title: /Sender of transaction
        timestamp:
          title: Timestamp of this transaction
          type: string
        transaction_hash:
          title: Transaction hash where action occured
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
    v1Address:
      properties:
        chain_id:
          type: string
        contract_name:
          type: string
        domain_info:
          $ref: '#/components/schemas/v1DomainInfo'
        hash:
          type: string
        is_contract:
          type: boolean
        is_token:
          type: boolean
        is_verified_contract:
          type: boolean
        token_name:
          type: string
        token_type:
          $ref: '#/components/schemas/v1TokenType'
      type: object
    v1DomainInfo:
      properties:
        address:
          type: string
        expiry_date:
          type: string
        name:
          type: string
        names_count:
          format: int64
          type: integer
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