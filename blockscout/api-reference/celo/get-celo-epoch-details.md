> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Celo epoch details.

> Retrieves detailed information about a Celo epoch.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/celo/epochs/{number}
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
  /{chain_id}/api/v2/celo/epochs/{number}:
    get:
      tags:
        - celo
      summary: Get Celo epoch details.
      description: Retrieves detailed information about a Celo epoch.
      operationId: BlockScoutWeb.API.V2.CeloController.epoch
      parameters:
        - description: Epoch number in the path.
          in: path
          name: number
          required: true
          schema:
            $ref: '#/components/schemas/IntegerString'
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
                $ref: '#/components/schemas/CeloEpochDetailed'
          description: Celo epoch details.
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
    IntegerString:
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerString
      type: string
    CeloEpochDetailed:
      additionalProperties: false
      description: Celo epoch summary.
      properties:
        aggregated_election_rewards:
          additionalProperties:
            additionalProperties: false
            nullable: true
            properties:
              count:
                minimum: 0
                type: integer
              token:
                additionalProperties: true
                nullable: true
                type: object
              total:
                $ref: '#/components/schemas/IntegerString'
            required:
              - total
              - count
              - token
            type: object
          nullable: true
          type: object
        distribution:
          additionalProperties: true
          nullable: true
          type: object
        end_block_number:
          minimum: 0
          type: integer
        end_processing_block_hash:
          $ref: '#/components/schemas/FullHashNullable'
        end_processing_block_number:
          minimum: 0
          nullable: true
          type: integer
        is_finalized:
          type: boolean
        number:
          minimum: 0
          type: integer
        start_block_number:
          minimum: 0
          type: integer
        start_processing_block_hash:
          $ref: '#/components/schemas/FullHashNullable'
        start_processing_block_number:
          minimum: 0
          nullable: true
          type: integer
        timestamp:
          $ref: '#/components/schemas/TimestampNullable'
        type:
          enum:
            - L1
            - L2
          type: string
      required:
        - number
        - type
        - start_block_number
        - end_block_number
        - timestamp
        - is_finalized
        - distribution
        - start_processing_block_hash
        - start_processing_block_number
        - end_processing_block_hash
        - end_processing_block_number
        - aggregated_election_rewards
      title: CeloEpochDetailed
      type: object
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
    FullHashNullable:
      nullable: true
      pattern: ^0x([A-Fa-f0-9]{64})$
      title: FullHashNullable
      type: string
    TimestampNullable:
      format: date-time
      nullable: true
      title: TimestampNullable
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