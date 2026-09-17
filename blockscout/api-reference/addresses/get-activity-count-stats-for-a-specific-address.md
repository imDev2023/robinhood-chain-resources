> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get activity count stats for a specific address

> Retrieves count statistics for an address, including transactions, token transfers, gas usage, and validations.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/addresses/{address_hash_param}/counters
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
  /{chain_id}/api/v2/addresses/{address_hash_param}/counters:
    get:
      tags:
        - addresses
      summary: Get activity count stats for a specific address
      description: >-
        Retrieves count statistics for an address, including transactions, token
        transfers, gas usage, and validations.
      operationId: BlockScoutWeb.API.V2.AddressController.counters
      parameters:
        - description: Address hash in the path
          in: path
          name: address_hash_param
          required: true
          schema:
            $ref: '#/components/schemas/AddressHash'
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
                $ref: '#/components/schemas/AddressCounters'
          description: Count statistics for the specified address.
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
        '403':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ForbiddenResponse'
          description: Forbidden
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
    AddressCounters:
      additionalProperties: false
      description: Address counters
      properties:
        gas_usage_count:
          $ref: '#/components/schemas/IntegerString'
        token_transfers_count:
          $ref: '#/components/schemas/IntegerString'
        transactions_count:
          $ref: '#/components/schemas/IntegerString'
        validations_count:
          $ref: '#/components/schemas/IntegerString'
      required:
        - transactions_count
        - token_transfers_count
        - gas_usage_count
        - validations_count
      title: AddressCounters
      type: object
    ForbiddenResponse:
      description: Response returned when the user is forbidden to access the resource
      properties:
        message:
          description: >-
            Error message indicating the user is forbidden to access the
            resource
          example: Unverified email
          type: string
      title: ForbiddenResponse
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