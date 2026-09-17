> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get servicesmetadataapiv1metadata



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /services/metadata/api/v1/metadata
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
  /services/metadata/api/v1/metadata:
    get:
      tags:
        - Metadata
      operationId: Metadata_BatchGetMetadata
      parameters:
        - description: Comma separated list of addresses
          in: query
          name: addresses
          schema:
            type: string
        - description: If not provided, only multichain tags will be returned
          in: query
          name: chainId
          schema:
            format: int64
            type: string
        - description: >-
            If provided, the first `tags_limit` tags will be returned for each
            address
          in: query
          name: tagsLimit
          schema:
            format: int64
            type: integer
        - description: Comma separated list of tag types
          in: query
          name: tagTypes
          schema:
            type: string
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1BatchGetMetadataResponse'
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
    v1BatchGetMetadataResponse:
      properties:
        addresses:
          additionalProperties:
            $ref: '#/components/schemas/v1AddressMetadataResponse'
          type: object
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
    v1AddressMetadataResponse:
      properties:
        tags:
          items:
            $ref: '#/components/schemas/v1Tag'
            type: object
          type: array
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