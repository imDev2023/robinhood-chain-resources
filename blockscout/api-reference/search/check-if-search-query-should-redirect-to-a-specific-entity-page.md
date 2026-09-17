> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Check if search query should redirect to a specific entity page

> Checks if a search query redirects to a specific entity page rather than showing search results.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/search/check-redirect
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
  /{chain_id}/api/v2/search/check-redirect:
    get:
      tags:
        - search
      summary: Check if search query should redirect to a specific entity page
      description: >-
        Checks if a search query redirects to a specific entity page rather than
        showing search results.
      operationId: BlockScoutWeb.API.V2.SearchController.check_redirect
      parameters:
        - description: Search query filter
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
                properties:
                  parameter:
                    nullable: true
                    type: string
                  redirect:
                    nullable: true
                    type: boolean
                  type:
                    enum:
                      - address
                      - block
                      - transaction
                      - user_operation
                      - blob
                      - ens_domain
                    nullable: true
                    type: string
                type: object
          description: >-
            Response indicating whether the query should redirect to a specific
            entity page.
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