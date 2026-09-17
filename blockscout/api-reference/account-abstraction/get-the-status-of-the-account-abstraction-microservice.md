> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get the status of the account abstraction microservice

> Retrieves the status of the account abstraction microservice.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/proxy/account-abstraction/status
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
  /{chain_id}/api/v2/proxy/account-abstraction/status:
    get:
      tags:
        - account-abstraction
      summary: Get the status of the account abstraction microservice
      description: Retrieves the status of the account abstraction microservice.
      operationId: BlockScoutWeb.API.V2.Proxy.AccountAbstractionController.status
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
                $ref: '#/components/schemas/AccountAbstractionStatus'
          description: Status
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
        '501':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/NotImplementedResponse'
          description: Not Implemented
components:
  schemas:
    AccountAbstractionStatus:
      additionalProperties:
        additionalProperties: false
        properties:
          enabled:
            type: boolean
          live:
            type: boolean
          past_db_logs_indexing_finished:
            type: boolean
          past_rpc_logs_indexing_finished:
            type: boolean
        type: object
      description: Status struct.
      properties:
        finished_past_indexing:
          type: boolean
      required:
        - finished_past_indexing
      title: AccountAbstractionStatus
      type: object
    NotImplementedResponse:
      description: Response returned when the feature is not implemented
      properties:
        message:
          description: Error message indicating the feature is not implemented
          example: Feature not implemented
          type: string
      title: NotImplementedResponse
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