> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get adminapiv1distributions



## OpenAPI

````yaml /openapi-specs/merits-admin-service.yaml get /admin/api/v1/distributions/{distribution_id}
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
  /admin/api/v1/distributions/{distribution_id}:
    get:
      tags:
        - PointsAdminService
      operationId: PointsAdminService_AdminGetDistribution
      parameters:
        - name: distribution_id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: A successful response.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1AdminGetDistributionResponse'
        default:
          description: An unexpected error response.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/rpcStatus'
components:
  schemas:
    v1AdminGetDistributionResponse:
      type: object
      properties:
        id:
          type: string
        description:
          type: string
        total_receivers:
          type: string
          format: uint64
        total_accounts_created:
          type: string
          format: uint64
        total_distributed:
          type: string
        distributions:
          type: array
          items:
            $ref: '#/components/schemas/v1Distribution'
        distributed_at:
          type: string
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
    v1Distribution:
      type: object
      properties:
        address:
          type: string
        amount:
          type: string
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