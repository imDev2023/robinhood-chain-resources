> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Export transactions as CSV

> Exports transactions for a specific address as a CSV file.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/addresses/{address_hash_param}/transactions/csv
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
  /{chain_id}/api/v2/addresses/{address_hash_param}/transactions/csv:
    get:
      tags:
        - addresses
      summary: Export transactions as CSV
      description: Exports transactions for a specific address as a CSV file.
      operationId: BlockScoutWeb.API.V2.CsvExportController.transactions_csv
      parameters:
        - description: Address hash in the path
          in: path
          name: address_hash_param
          required: true
          schema:
            $ref: '#/components/schemas/AddressHash'
        - description: Start of the time period (ISO 8601 format) in CSV export
          in: query
          name: from_period
          schema:
            anyOf:
              - pattern: >-
                  ^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])(?:T(?:[01]\d|2[0-3])(?:(?::|%3A)[0-5]\d(?:(?::|%3A)[0-5]\d(?:\.\d{1,9})?)?)?(?:Z|(?:\+|%2B|-)(?:[01]\d|2[0-3])(?:(?::|%3A)[0-5]\d)?)?)?$
                type: string
              - $ref: '#/components/schemas/NullString'
        - description: End of the time period (ISO 8601 format) In CSV export
          in: query
          name: to_period
          schema:
            anyOf:
              - pattern: >-
                  ^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])(?:T(?:[01]\d|2[0-3])(?:(?::|%3A)[0-5]\d(?:(?::|%3A)[0-5]\d(?:\.\d{1,9})?)?)?(?:Z|(?:\+|%2B|-)(?:[01]\d|2[0-3])(?:(?::|%3A)[0-5]\d)?)?)?$
                type: string
              - $ref: '#/components/schemas/NullString'
        - description: Filter type in CSV export
          in: query
          name: filter_type
          schema:
            anyOf:
              - enum:
                  - address
                nullable: true
                type: string
              - $ref: '#/components/schemas/NullString'
        - description: Filter value in CSV export
          in: query
          name: filter_value
          schema:
            anyOf:
              - enum:
                  - to
                  - from
                nullable: true
                type: string
              - $ref: '#/components/schemas/NullString'
        - description: The ID of the blockchain
          in: path
          name: chain_id
          required: true
          schema:
            type: string
      responses:
        '200':
          content:
            application/csv:
              path: >-
                /{chain_id}/api/v2/tokens/{address_hash_param}/instances/{token_id_param}/refetch-metadata
          description: CSV file of transactions.
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
    NullString:
      pattern: ^null$
      title: NullString
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