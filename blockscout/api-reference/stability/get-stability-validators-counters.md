> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Stability validators counters.

> Retrieves aggregate counters for the Stability chain validator set.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/validators/stability/counters
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
  /{chain_id}/api/v2/validators/stability/counters:
    get:
      tags:
        - stability
      summary: Get Stability validators counters.
      description: Retrieves aggregate counters for the Stability chain validator set.
      operationId: BlockScoutWeb.API.V2.ValidatorController.stability_validators_counters
      parameters:
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
                $ref: '#/components/schemas/StabilityValidatorsCounters'
          description: Stability validators counters.
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
    StabilityValidatorsCounters:
      additionalProperties: false
      description: Aggregate counters describing the Stability chain validator set.
      example:
        active_validators_count: '3'
        active_validators_percentage: 33.33
        new_validators_count_24h: '2'
        validators_count: '9'
      properties:
        active_validators_count:
          description: Number of validators currently in the `active` operational state.
          pattern: ^([1-9][0-9]*|0)$
          type: string
        active_validators_percentage:
          description: >-
            Share of `active` validators in the total set, expressed as a
            percentage and floored to two decimal places. `null` when there are
            no validators.
          format: float
          maximum: 100
          minimum: 0
          nullable: true
          type: number
        new_validators_count_24h:
          description: Number of validators that joined the set within the last 24 hours.
          pattern: ^([1-9][0-9]*|0)$
          type: string
        validators_count:
          description: >-
            Total number of validators known on the Stability chain across all
            operational states.
          pattern: ^([1-9][0-9]*|0)$
          type: string
      required:
        - validators_count
        - new_validators_count_24h
        - active_validators_count
        - active_validators_percentage
      title: StabilityValidatorsCounters
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