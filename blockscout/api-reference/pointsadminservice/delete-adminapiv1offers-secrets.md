> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Delete adminapiv1offers secrets



## OpenAPI

````yaml /openapi-specs/merits-admin-service.yaml delete /admin/api/v1/offers/{offer_id}/secrets/{secret_id}
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
  /admin/api/v1/offers/{offer_id}/secrets/{secret_id}:
    delete:
      tags:
        - PointsAdminService
      operationId: PointsAdminService_AdminDeleteOfferSecret
      parameters:
        - name: offer_id
          in: path
          required: true
          schema:
            type: string
        - name: secret_id
          in: path
          required: true
          schema:
            type: integer
            format: int32
      responses:
        '200':
          description: A successful response.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1AdminDeleteOfferSecretResponse'
        default:
          description: An unexpected error response.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/rpcStatus'
components:
  schemas:
    v1AdminDeleteOfferSecretResponse:
      type: object
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