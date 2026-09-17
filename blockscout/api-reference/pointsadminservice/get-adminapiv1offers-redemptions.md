> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get adminapiv1offers redemptions



## OpenAPI

````yaml /openapi-specs/merits-admin-service.yaml get /admin/api/v1/offers/{offer_id}/redemptions
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
  /admin/api/v1/offers/{offer_id}/redemptions:
    get:
      tags:
        - PointsAdminService
      operationId: PointsAdminService_AdminGetOfferRedemptions
      parameters:
        - name: offer_id
          in: path
          required: true
          schema:
            type: string
        - name: page_size
          in: query
          schema:
            type: integer
            format: int64
        - name: page_token
          in: query
          schema:
            type: string
      responses:
        '200':
          description: A successful response.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1AdminGetOfferRedemptionsResponse'
        default:
          description: An unexpected error response.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/rpcStatus'
components:
  schemas:
    v1AdminGetOfferRedemptionsResponse:
      type: object
      properties:
        items:
          type: array
          items:
            $ref: '#/components/schemas/v1OfferRedemption'
        next_page_params:
          $ref: '#/components/schemas/v1Pagination'
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
    v1OfferRedemption:
      type: object
      properties:
        offer_id:
          type: string
        address:
          type: string
        redemption:
          type: string
          format: uint64
        price:
          type: string
        note:
          type: string
        redeemed_at:
          type: string
        secret:
          type: string
    v1Pagination:
      type: object
      properties:
        page_token:
          type: string
        page_size:
          type: integer
          format: int64
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