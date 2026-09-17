> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get adminapiv1networks



## OpenAPI

````yaml /openapi-specs/merits-admin-service.yaml get /admin/api/v1/networks
openapi: 3.0.1
info:
  title: Merits Admin service
  contact:
    name: Blockscout
    url: https://blockscout.com
    email: support@blockscout.com
  version: 0.1.1
servers:
  - url: https://merits.blockscout.com/
security:
  - AdminApiKey: []
tags:
  - name: PointsAdminService
externalDocs:
  description: More about merits microservice
  url: https://github.com/blockscout/points
paths:
  /admin/api/v1/networks:
    get:
      tags:
        - PointsAdminService
      operationId: PointsAdminService_AdminGetNetworks
      responses:
        '200':
          description: A successful response.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1AdminGetNetworksResponse'
        default:
          description: An unexpected error response.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/rpcStatus'
components:
  schemas:
    v1AdminGetNetworksResponse:
      type: object
      properties:
        items:
          type: array
          items:
            $ref: '#/components/schemas/v1AdminNetwork'
    rpcStatus:
      type: object
      properties:
        code:
          type: integer
          format: int32
        message:
          type: string
        details:
          type: array
          items:
            $ref: '#/components/schemas/protobufAny'
    v1AdminNetwork:
      type: object
      properties:
        chain_id:
          type: string
        name:
          type: string
        domain:
          type: string
        active:
          type: boolean
        rpc_url:
          type: string
        blockscout_api_key:
          type: string
        block_timestamp_skew:
          type: integer
          format: int32
        sent_transactions_activity_enabled:
          type: boolean
        verified_contracts_activity_enabled:
          type: boolean
        blockscout_usage_activity_enabled:
          type: boolean
    protobufAny:
      type: object
      properties:
        '@type':
          type: string
      additionalProperties:
        type: object
  securitySchemes:
    AdminApiKey:
      type: apiKey
      description: 'Authentication token, prefixed by Bearer: Bearer <token>'
      name: Authorization
      in: header

````