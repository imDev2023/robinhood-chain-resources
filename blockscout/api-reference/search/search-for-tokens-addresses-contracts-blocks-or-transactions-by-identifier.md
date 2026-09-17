> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Search for tokens, addresses, contracts, blocks, or transactions by identifier

> Performs a unified search across multiple blockchain entity types including tokens, addresses, contracts, blocks, transactions and other resources.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v1/search
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
  /{chain_id}/api/v1/search:
    get:
      tags:
        - search
      summary: >-
        Search for tokens, addresses, contracts, blocks, or transactions by
        identifier
      description: >-
        Performs a unified search across multiple blockchain entity types
        including tokens, addresses, contracts, blocks, transactions and other
        resources.
      operationId: BlockScoutWeb.API.V2.SearchController.search
      parameters:
        - description: Search query filter
          in: query
          name: q
          schema:
            nullable: true
            type: string
        - description: Next page params type for paging
          in: query
          name: next_page_params_type
          schema:
            type: string
        - description: Label for paging in the search results
          in: query
          name: label
          schema:
            type: object
        - description: Token for paging in the search results
          in: query
          name: token
          schema:
            type: object
        - description: Contract for paging in the search results
          in: query
          name: contract
          schema:
            type: object
        - description: TAC operation for paging in the search results
          in: query
          name: tac_operation
          schema:
            type: object
        - description: Metadata tag for paging in the search results
          in: query
          name: metadata_tag
          schema:
            type: object
        - description: Block for paging in the search results
          in: query
          name: block
          schema:
            type: object
        - description: Blob for paging in the search results
          in: query
          name: blob
          schema:
            type: object
        - description: User operation for paging in the search results
          in: query
          name: user_operation
          schema:
            type: object
        - description: Address for paging in the search results
          in: query
          name: address
          schema:
            type: object
        - description: ENS domain for paging in the search results
          in: query
          name: ens_domain
          schema:
            type: object
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
                $ref: '#/components/schemas/SearchResult'
          description: >-
            Successful search response containing matched items and pagination
            information.
                        Results are ordered by relevance and limited to 50 items per page.
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
    SearchResult:
      description: Search results containing blocks, transactions, and addresses
      properties:
        items:
          items:
            type: object
          type: array
        next_page_params:
          additionalProperties: true
          nullable: true
          type: object
      title: SearchResult
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