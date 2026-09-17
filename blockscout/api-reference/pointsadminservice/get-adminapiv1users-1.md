> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get adminapiv1users 1



## OpenAPI

````yaml /openapi-specs/merits-admin-service.yaml get /admin/api/v1/users/{address_or_code}
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
  /admin/api/v1/users/{address_or_code}:
    get:
      tags:
        - PointsAdminService
      operationId: PointsAdminService_AdminGetUserInfo
      parameters:
        - name: address_or_code
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
                $ref: '#/components/schemas/v1AdminGetUserInfoResponse'
        default:
          description: An unexpected error response.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/rpcStatus'
components:
  schemas:
    v1AdminGetUserInfoResponse:
      type: object
      properties:
        address:
          type: string
        balances:
          $ref: '#/components/schemas/v1GetUserBalancesResponse'
        logs:
          type: array
          items:
            $ref: '#/components/schemas/v1UserLog'
        code:
          type: string
        invited_users:
          type: array
          items:
            type: string
        passport_score:
          $ref: '#/components/schemas/v1PassportScore'
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
    v1UserLog:
      type: object
      properties:
        id:
          type: string
          format: uint64
        action:
          type: string
        details:
          type: object
          properties: {}
        timestamp:
          type: string
    v1PassportScore:
      type: object
      properties:
        score:
          type: string
        expiry_at:
          type: string
        details:
          type: object
          properties: {}
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