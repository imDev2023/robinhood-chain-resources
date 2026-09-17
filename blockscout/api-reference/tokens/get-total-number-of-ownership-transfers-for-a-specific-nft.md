> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get total number of ownership transfers for a specific NFT

> Retrieves the total number of transfers for a specific NFT instance. Useful for determining how frequently an NFT has changed hands.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/tokens/{address_hash_param}/instances/{token_id_param}/transfers-count
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
  /{chain_id}/api/v2/tokens/{address_hash_param}/instances/{token_id_param}/transfers-count:
    get:
      tags:
        - tokens
      summary: Get total number of ownership transfers for a specific NFT
      description: >-
        Retrieves the total number of transfers for a specific NFT instance.
        Useful for determining how frequently an NFT has changed hands.
      operationId: BlockScoutWeb.API.V2.TokenController.transfers_count_by_instance
      parameters:
        - description: Address hash in the path
          in: path
          name: address_hash_param
          required: true
          schema:
            $ref: '#/components/schemas/AddressHash'
        - description: Token ID for ERC-721/1155/404 tokens
          in: path
          name: token_id_param
          required: true
          schema:
            $ref: '#/components/schemas/IntegerStringNullable'
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
                  transfers_count:
                    type: integer
                type: object
          description: Total number of transfers for the specified NFT instance.
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
        '404':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/NotFoundResponse'
          description: Not Found
        '422':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/JsonErrorResponse'
          description: Unprocessable Entity
components:
  schemas:
    AddressHash:
      pattern: ^0x([A-Fa-f0-9]{40})$
      title: AddressHash
      type: string
    IntegerStringNullable:
      nullable: true
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerStringNullable
      type: string
    NotFoundResponse:
      description: Response returned when the requested resource is not found
      properties:
        message:
          description: Error message indicating the requested resource was not found
          example: Resource not found
          type: string
      title: NotFoundResponse
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