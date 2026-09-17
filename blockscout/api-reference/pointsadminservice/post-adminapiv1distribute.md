> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Post adminapiv1distribute



## OpenAPI

````yaml /openapi-specs/merits-admin-service.yaml post /admin/api/v1/distribute
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
  /admin/api/v1/distribute:
    post:
      tags:
        - PointsAdminService
      operationId: PointsAdminService_AdminDistribute
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/v1AdminDistributeRequest'
        required: true
      responses:
        '200':
          description: A successful response.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1AdminDistributeResponse'
        default:
          description: An unexpected error response.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/rpcStatus'
components:
  schemas:
    v1AdminDistributeRequest:
      type: object
      properties:
        id:
          type: string
        description:
          type: string
        distributions:
          type: array
          items:
            $ref: '#/components/schemas/v1Distribution'
        create_missing_accounts:
          type: boolean
        expected_total:
          type: string
    v1AdminDistributeResponse:
      type: object
      properties:
        accounts_distributed:
          type: string
          format: uint64
        accounts_created:
          type: string
          format: uint64
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