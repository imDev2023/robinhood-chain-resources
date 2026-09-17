> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Perform batch resolving of list of addresses to names for blockscout backend requests



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json post /services/bens/api/v1/addresses:batch-resolve
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
  /services/bens/api/v1/addresses:batch-resolve:
    post:
      tags:
        - MultichainDomains
      summary: >-
        Perform batch resolving of list of addresses to names for blockscout
        backend requests
      operationId: MultichainDomains_BatchResolveAddressesMultichain
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/v1BatchResolveAddressesMultichainRequest'
        required: true
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1BatchResolveAddressNamesResponse'
          description: A successful response.
        default:
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/googlerpcStatus'
          description: An unexpected error response.
components:
  schemas:
    v1BatchResolveAddressesMultichainRequest:
      properties:
        addresses:
          items:
            type: string
          title: List of requested addresses
          type: array
        all_protocols:
          description: >-
            If true, search across all supported protocols and ignore
            `protocols`.

            When `chain_id` is set, the search is scoped to all protocols on
            that chain.
          type: boolean
        chain_id:
          format: int64
          title: The chain (network) where domain search should be done
          type: string
        protocols:
          title: comma separated list of protocol ids. Default is ENS protocol only
          type: string
      type: object
    v1BatchResolveAddressNamesResponse:
      properties:
        names:
          additionalProperties:
            type: string
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