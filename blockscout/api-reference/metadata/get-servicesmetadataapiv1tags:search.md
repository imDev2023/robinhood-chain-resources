> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get servicesmetadataapiv1tags:search



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /services/metadata/api/v1/tags:search
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
  /services/metadata/api/v1/tags:search:
    get:
      tags:
        - Metadata
      operationId: Metadata_SearchPublicTags
      parameters:
        - in: query
          name: chain_id
          schema:
            format: int64
            type: string
        - description: Comma separated list of tag types
          in: query
          name: tag_types
          schema:
            type: string
        - in: query
          name: name
          schema:
            type: string
        - in: query
          name: page_size
          schema:
            format: int64
            type: integer
        - in: query
          name: page_token
          schema:
            type: string
        - in: query
          name: address_limit
          schema:
            format: int64
            type: integer
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1SearchPublicTagsResponse'
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
    v1SearchPublicTagsResponse:
      properties:
        items:
          items:
            $ref: '#/components/schemas/v1TagAddresses'
            type: object
          type: array
        nextPageParams:
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
    v1TagAddresses:
      properties:
        addresses:
          items:
            type: string
          type: array
        tag:
          $ref: '#/components/schemas/v1Tag'
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
    v1Tag:
      properties:
        meta:
          type: string
        name:
          type: string
        ordinal:
          format: int32
          type: integer
        slug:
          type: string
        tagType:
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