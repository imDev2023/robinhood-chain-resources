> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Batch by celestia blob.

> Retrieves batch detailed info by the given celestia blob metadata (height and commitment).



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/optimism/batches/da/celestia/{height}/{commitment}
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
  /{chain_id}/api/v2/optimism/batches/da/celestia/{height}/{commitment}:
    get:
      tags:
        - optimism
      summary: Batch by celestia blob.
      description: >-
        Retrieves batch detailed info by the given celestia blob metadata
        (height and commitment).
      operationId: BlockScoutWeb.API.V2.OptimismController.batch_by_celestia_blob
      parameters:
        - description: Celestia blob height in the path.
          in: path
          name: height
          required: true
          schema:
            $ref: '#/components/schemas/IntegerString'
        - description: Celestia blob commitment in the path.
          in: path
          name: commitment
          required: true
          schema:
            $ref: '#/components/schemas/HexData'
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
                $ref: '#/components/schemas/Optimism.Batch.Detailed'
          description: Batch detailed info.
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
    HexData:
      pattern: ^0x([A-Fa-f0-9]*)$
      title: HexData
      type: string
    Optimism.Batch.Detailed:
      additionalProperties: false
      description: Optimism Batch struct.
      nullable: true
      properties:
        batch_data_container:
          enum:
            - in_blob4844
            - in_celestia
            - in_eigenda
            - in_alt_da
            - in_calldata
          nullable: true
          type: string
        blobs:
          items:
            additionalProperties: false
            description: Blob struct bound with Optimism batch.
            properties:
              cert:
                description: EigenDA cert raw bytes.
                pattern: ^0x([A-Fa-f0-9]*)$
                type: string
              commitment:
                description: Celestia or Alt-DA blob commitment.
                pattern: ^0x([A-Fa-f0-9]*)$
                type: string
              hash:
                description: EIP-4844 blob hash.
                pattern: ^0x([A-Fa-f0-9]*)$
                type: string
              height:
                description: Celestia block height.
                type: integer
              l1_timestamp:
                description: L1 transaction timestamp bound with the blob.
                format: date-time
                type: string
              l1_transaction_hash:
                description: L1 transaction hash bound with the blob.
                pattern: ^0x([A-Fa-f0-9]{64})$
                type: string
              namespace:
                description: Celestia blob namespace.
                pattern: ^0x([A-Fa-f0-9]*)$
                type: string
            required:
              - l1_transaction_hash
              - l1_timestamp
            type: object
          type: array
        l1_timestamp:
          $ref: '#/components/schemas/Timestamp'
        l1_transaction_hashes:
          items:
            $ref: '#/components/schemas/FullHash'
          type: array
        l2_end_block_number:
          type: integer
        l2_start_block_number:
          type: integer
        number:
          type: integer
        transactions_count:
          type: integer
      required:
        - number
        - transactions_count
        - l1_timestamp
        - l1_transaction_hashes
        - batch_data_container
        - l2_end_block_number
        - l2_start_block_number
      title: Optimism.Batch.Detailed
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
    Timestamp:
      format: date-time
      title: Timestamp
      type: string
    FullHash:
      pattern: ^0x([A-Fa-f0-9]{64})$
      title: FullHash
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