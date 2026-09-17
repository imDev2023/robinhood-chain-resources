> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get block number by time stamp

> Returns the block number created closest to a provided timestamp.

Required:
- `timestamp`
- `closest`




## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/legacy/block/get-block-number-by-time
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
  /{chain_id}/api/legacy/block/get-block-number-by-time:
    get:
      tags:
        - legacy
      summary: Get block number by time stamp
      description: |
        Returns the block number created closest to a provided timestamp.

        Required:
        - `timestamp`
        - `closest`
      operationId: BlockScoutWeb.API.Legacy.BlockController.get_block_number_by_time
      parameters:
        - description: Unix timestamp in seconds.
          in: query
          name: timestamp
          schema:
            $ref: '#/components/schemas/IntegerString'
        - description: Whether to return the block before or after the timestamp.
          in: query
          name: closest
          schema:
            enum:
              - before
              - after
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
                  message:
                    description: >-
                      Human-readable status string — `OK` on success, a
                      descriptive error message otherwise.
                    type: string
                  result:
                    $ref: '#/components/schemas/GetBlockNumberByTimeResult'
                  status:
                    description: '`1` = OK, `0` = error, `2` = pending.'
                    enum:
                      - '0'
                      - '1'
                      - '2'
                    type: string
                required:
                  - status
                  - message
                  - result
                type: object
          description: Block number
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
components:
  schemas:
    IntegerString:
      pattern: ^-?([1-9][0-9]*|0)$
      title: IntegerString
      type: string
    GetBlockNumberByTimeResult:
      additionalProperties: false
      description: >-
        Block number closest to the requested timestamp; `null` if the lookup
        fails.
      nullable: true
      properties:
        blockNumber:
          description: Decimal-string block number.
          pattern: ^-?([1-9][0-9]*|0)$
          type: string
      required:
        - blockNumber
      title: GetBlockNumberByTimeResult
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