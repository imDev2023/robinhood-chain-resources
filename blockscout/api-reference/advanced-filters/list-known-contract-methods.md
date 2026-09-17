> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# List known contract methods

> Returns a list of known contract methods. When the `q` parameter is provided, searches for a single method by its 4-byte selector or name. Without `q`, returns the default list of popular methods.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/advanced-filters/methods
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
  /{chain_id}/api/v2/advanced-filters/methods:
    get:
      tags:
        - advanced-filters
      summary: List known contract methods
      description: >-
        Returns a list of known contract methods. When the `q` parameter is
        provided, searches for a single method by its 4-byte selector or name.
        Without `q`, returns the default list of popular methods.
      operationId: BlockScoutWeb.API.V2.AdvancedFilterController.list_methods
      parameters:
        - description: >-
            Search string: either a 4-byte method selector (e.g. `0xa9059cbb`)
            or a method name (e.g. `transfer`).
          example: transfer
          in: query
          name: q
          schema:
            nullable: true
            type: string
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
                items:
                  $ref: '#/components/schemas/AdvancedFilterMethod'
                type: array
          description: List of contract methods.
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
        '422':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/JsonErrorResponse'
          description: Unprocessable Entity
components:
  schemas:
    AdvancedFilterMethod:
      additionalProperties: false
      description: >-
        Contract method identified by its 4-byte selector and human-readable
        name.
      properties:
        method_id:
          description: 4-byte method selector prefixed with 0x (lowercase hex).
          example: '0xa9059cbb'
          pattern: ^0x[0-9a-f]{8}$
          type: string
        name:
          description: >-
            Human-readable method name. Empty string if the name could not be
            resolved.
          example: transfer
          type: string
      required:
        - method_id
        - name
      title: AdvancedFilterMethod
      type: object
    JsonErrorResponse:
      properties:
        errors:
          items:
            properties:
              detail:
                example: null value where string expected
                type: string
              source:
                properties:
                  pointer:
                    example: /data/attributes/petName
                    type: string
                required:
                  - pointer
                type: object
              title:
                example: Invalid value
                type: string
            required:
              - title
              - source
              - detail
            type: object
          type: array
      required:
        - errors
      title: JsonErrorResponse
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