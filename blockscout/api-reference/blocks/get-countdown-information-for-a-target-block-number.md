> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get countdown information for a target block number

> Calculates the estimated time remaining until a specified block number is reached based on current block and average block time.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/blocks/{block_number_param}/countdown
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
  /{chain_id}/api/v2/blocks/{block_number_param}/countdown:
    get:
      tags:
        - blocks
      summary: Get countdown information for a target block number
      description: >-
        Calculates the estimated time remaining until a specified block number
        is reached based on current block and average block time.
      operationId: BlockScoutWeb.API.V2.BlockController.block_countdown
      parameters:
        - description: Block number in the path
          in: path
          name: block_number_param
          required: true
          schema:
            minimum: 0
            type: integer
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
                $ref: '#/components/schemas/BlockCountdown'
          description: Block countdown information.
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
    BlockCountdown:
      description: >-
        Block countdown information showing estimated time until a target block
        is reached
      example:
        countdown_block: 22600000
        current_block: 22566361
        estimated_time_in_sec: 404868
        remaining_blocks: 33639
      properties:
        countdown_block:
          description: The target block number for the countdown
          example: 22600000
          minimum: 0
          type: integer
        current_block:
          description: The current highest block number in the blockchain
          example: 22566361
          minimum: 0
          type: integer
        estimated_time_in_sec:
          description: Estimated time in seconds until the target block is reached
          example: 404868
          format: float
          minimum: 0
          type: number
        remaining_blocks:
          description: Number of blocks remaining until the target block is reached
          example: 33639
          minimum: 0
          type: integer
      required:
        - current_block
        - countdown_block
        - remaining_blocks
        - estimated_time_in_sec
      title: BlockCountdown
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