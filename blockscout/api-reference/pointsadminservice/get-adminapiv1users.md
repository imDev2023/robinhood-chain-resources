> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get adminapiv1users



## OpenAPI

````yaml /openapi-specs/merits-admin-service.yaml get /admin/api/v1/users
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
  /admin/api/v1/users:
    get:
      tags:
        - PointsAdminService
      operationId: PointsAdminService_AdminGetUsersBasicInfo
      parameters:
        - name: address
          in: query
          style: form
          explode: true
          schema:
            type: array
            items:
              type: string
      responses:
        '200':
          description: A successful response.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1AdminGetUsersBasicInfoResponse'
        default:
          description: An unexpected error response.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/rpcStatus'
components:
  schemas:
    v1AdminGetUsersBasicInfoResponse:
      type: object
      properties:
        items:
          type: array
          items:
            $ref: '#/components/schemas/v1UserBasicInfo'
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
    v1UserBasicInfo:
      type: object
      properties:
        address:
          type: string
        is_active:
          type: boolean
        balances:
          $ref: '#/components/schemas/v1GetUserBalancesResponse'
    protobufAny:
      type: object
      properties:
        '@type':
          type: string
      additionalProperties:
        type: object
    v1GetUserBalancesResponse:
      type: object
      properties:
        total:
          type: string
        staked:
          type: string
        unstaked:
          type: string
        total_staking_rewards:
          type: string
        total_referral_rewards:
          type: string
        pending_referral_rewards:
          type: string
  securitySchemes:
    AdminApiKey:
      type: apiKey
      description: 'Authentication token, prefixed by Bearer: Bearer <token>'
      name: Authorization
      in: header

````