> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Zilliqa validators list.

> Retrieves the list of Zilliqa validators.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/validators/zilliqa
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
  /{chain_id}/api/v2/validators/zilliqa:
    get:
      tags:
        - zilliqa
        - stability
      summary: Zilliqa validators list.
      description: Retrieves the list of Zilliqa validators.
      operationId: BlockScoutWeb.API.V2.ValidatorController.zilliqa_validators_list
      parameters:
        - description: Number of items per page
          in: query
          name: items_count
          schema:
            minimum: 1
            type: integer
        - description: Item index for paging
          in: query
          name: index
          schema:
            type: integer
        - description: |
            Sort results by:
            * index - Sort by validator index
            Should be used together with `order` parameter.
          in: query
          name: sort
          schema:
            enum:
              - index
            type: string
        - description: |
            Sort order:
            * asc - Ascending order
            * desc - Descending order
            Should be used together with `sort` parameter.
          in: query
          name: order
          schema:
            enum:
              - asc
              - desc
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
                additionalProperties: false
                properties:
                  items:
                    items:
                      $ref: '#/components/schemas/Staker'
                    type: array
                  next_page_params:
                    additionalProperties: true
                    example:
                      index: 55
                    nullable: true
                    type: object
                required:
                  - items
                  - next_page_params
                type: object
          description: List of validators.
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
    Staker:
      additionalProperties: false
      description: Zilliqa Staker struct.
      properties:
        balance:
          $ref: '#/components/schemas/IntegerString'
        bls_public_key:
          $ref: '#/components/schemas/HexData'
        index:
          type: integer
      required:
        - balance
        - bls_public_key
        - index
      title: Staker
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
    IntegerString:
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerString
      type: string
    HexData:
      pattern: ^0x([A-Fa-f0-9]*)$
      title: HexData
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