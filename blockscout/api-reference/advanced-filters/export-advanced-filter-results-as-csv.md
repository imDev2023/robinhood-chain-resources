> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Export advanced-filter results as CSV

> Streams the items matching the advanced filter criteria as a CSV file. When asynchronous CSV export is enabled on the deployment, returns `202 Accepted` with a `request_id` that can be polled via `/api/v2/csv-exports/{request_id}`; otherwise the CSV body is streamed inline.



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /{chain_id}/api/v2/advanced-filters/csv
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
  /{chain_id}/api/v2/advanced-filters/csv:
    get:
      tags:
        - advanced-filters
      summary: Export advanced-filter results as CSV
      description: >-
        Streams the items matching the advanced filter criteria as a CSV file.
        When asynchronous CSV export is enabled on the deployment, returns `202
        Accepted` with a `request_id` that can be polled via
        `/api/v2/csv-exports/{request_id}`; otherwise the CSV body is streamed
        inline.
      operationId: BlockScoutWeb.API.V2.AdvancedFilterController.list_csv
      parameters:
        - description: >-
            Comma-separated list of transaction types to include. Allowed
            values: `COIN_TRANSFER`, `CONTRACT_INTERACTION`,
            `CONTRACT_CREATION`, `ERC-20`, `ERC-404`, `ERC-721`, `ERC-1155`,
            `ERC-7984` (plus `ZRC-2` on Zilliqa). Values are matched
            case-insensitively; unknown entries are silently dropped.
          example: COIN_TRANSFER,ERC-20
          in: query
          name: transaction_types
          schema:
            nullable: true
            type: string
        - description: >-
            Comma-separated list of 4-byte contract method selectors (lowercase,
            `0x`-prefixed). At most 20 unique entries are honored; invalid
            entries are dropped.
          example: 0xa9059cbb,0x095ea7b3
          in: query
          name: methods
          schema:
            nullable: true
            type: string
        - description: Inclusive lower bound on `timestamp` (ISO 8601).
          example: '2024-01-01T00:00:00Z'
          in: query
          name: age_from
          schema:
            nullable: true
            type: string
        - description: Inclusive upper bound on `timestamp` (ISO 8601).
          example: '2024-12-31T23:59:59Z'
          in: query
          name: age_to
          schema:
            nullable: true
            type: string
        - description: Comma-separated list of sender address hashes to include.
          example: >-
            0x5a52e96bacdabb82fd05763e25335261b270efcb,0x00000000219ab540356cbb839cbe05303d7705fa
          in: query
          name: from_address_hashes_to_include
          schema:
            nullable: true
            type: string
        - description: Comma-separated list of sender address hashes to exclude.
          example: >-
            0x5a52e96bacdabb82fd05763e25335261b270efcb,0x00000000219ab540356cbb839cbe05303d7705fa
          in: query
          name: from_address_hashes_to_exclude
          schema:
            nullable: true
            type: string
        - description: Comma-separated list of recipient address hashes to include.
          example: >-
            0x5a52e96bacdabb82fd05763e25335261b270efcb,0x00000000219ab540356cbb839cbe05303d7705fa
          in: query
          name: to_address_hashes_to_include
          schema:
            nullable: true
            type: string
        - description: Comma-separated list of recipient address hashes to exclude.
          example: >-
            0x5a52e96bacdabb82fd05763e25335261b270efcb,0x00000000219ab540356cbb839cbe05303d7705fa
          in: query
          name: to_address_hashes_to_exclude
          schema:
            nullable: true
            type: string
        - description: >-
            How to combine the `from_address_hashes_*` and `to_address_hashes_*`
            filters. Accepts `or` or `and` (case-insensitive). `or` (default)
            matches an item if either side matches; `and` requires both sides to
            match. Any other value is silently coerced to `nil` (no relation
            constraint).
          example: and
          in: query
          name: address_relation
          schema:
            nullable: true
            type: string
        - description: >-
            Inclusive lower bound on the item's transferred amount (decimal
            string in the token's base units).
          example: '0'
          in: query
          name: amount_from
          schema:
            nullable: true
            type: string
        - description: >-
            Inclusive upper bound on the item's transferred amount (decimal
            string in the token's base units).
          example: '1000000'
          in: query
          name: amount_to
          schema:
            nullable: true
            type: string
        - description: >-
            Comma-separated list of token contract address hashes to include.
            Use the literal `native` to also include native coin transfers. Each
            list (include and exclude) is capped to 20 entries separately.
          example: native,0xdac17f958d2ee523a2206206994597c13d831ec7
          in: query
          name: token_contract_address_hashes_to_include
          schema:
            nullable: true
            type: string
        - description: >-
            Comma-separated list of token contract address hashes to exclude.
            Use the literal `native` to also exclude native coin transfers. Each
            list (include and exclude) is capped to 20 entries separately.
          example: '0x0000000000000000000000000000000000000000'
          in: query
          name: token_contract_address_hashes_to_exclude
          schema:
            nullable: true
            type: string
        - description: >-
            Comma-separated list of human-readable method names corresponding to
            the `methods` selectors.
          example: transfer,approve
          in: query
          name: methods_names
          schema:
            nullable: true
            type: string
        - description: Comma-separated list of token symbols to include.
          example: USDT,USDC
          in: query
          name: token_contract_symbols_to_include
          schema:
            nullable: true
            type: string
        - description: Comma-separated list of token symbols to exclude.
          example: USDT,USDC
          in: query
          name: token_contract_symbols_to_exclude
          schema:
            nullable: true
            type: string
        - description: 'Keyset cursor: block number of the last item from the previous page.'
          example: '23532302'
          in: query
          name: block_number
          schema:
            pattern: ^([1-9][0-9]*|0)$
            type: string
        - description: >-
            Keyset cursor: transaction index within the block of the last item
            from the previous page.
          example: '1'
          in: query
          name: transaction_index
          schema:
            pattern: ^([1-9][0-9]*|0)$
            type: string
        - description: >-
            Keyset cursor: internal-transaction index of the last item from the
            previous page. Use an empty string or the literal `null` when the
            previous item was not an internal transaction.
          in: query
          name: internal_transaction_index
          schema:
            $ref: '#/components/schemas/IntegerStringOrEmptyOrNullLiteral'
        - description: >-
            Keyset cursor: token-transfer index of the last item from the
            previous page. Use an empty string or the literal `null` when the
            previous item was not a token transfer.
          in: query
          name: token_transfer_index
          schema:
            $ref: '#/components/schemas/IntegerStringOrEmptyOrNullLiteral'
        - description: >-
            Keyset cursor: index within an ERC-1155 batch token transfer. Use an
            empty string or the literal `null` when the previous item was not
            part of a batch.
          in: query
          name: token_transfer_batch_index
          schema:
            $ref: '#/components/schemas/IntegerStringOrEmptyOrNullLiteral'
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
          description: CSV file (sync export).
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
        '202':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/AdvancedFilterCsvExportAccepted'
          description: >-
            Async export queued; poll `/api/v2/csv-exports/{request_id}` with
            the returned `request_id`.
        '409':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/AdvancedFilterCsvExportError'
          description: Too many pending export requests for this client.
        '422':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/JsonErrorResponse'
          description: Unprocessable Entity
        '500':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/AdvancedFilterCsvExportError'
          description: Failed to create CSV export request.
components:
  schemas:
    IntegerStringOrEmptyOrNullLiteral:
      oneOf:
        - pattern: ^([1-9][0-9]*|0)$
          type: string
        - enum:
            - ''
            - 'null'
          type: string
      title: IntegerStringOrEmptyOrNullLiteral
    AdvancedFilterCsvExportAccepted:
      additionalProperties: false
      description: >-
        Body returned when an asynchronous CSV export job has been queued. Poll
        `/api/v2/csv-exports/{request_id}` with the returned `request_id` to
        check status.
      properties:
        request_id:
          description: UUID of the queued export request.
          format: uuid
          type: string
      required:
        - request_id
      title: AdvancedFilterCsvExportAccepted
      type: object
    AdvancedFilterCsvExportError:
      additionalProperties: false
      properties:
        error:
          description: Human-readable error description.
          type: string
      required:
        - error
      title: AdvancedFilterCsvExportError
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