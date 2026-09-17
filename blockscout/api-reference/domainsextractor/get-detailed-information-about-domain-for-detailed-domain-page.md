> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Get detailed information about domain for Detailed domain page



## OpenAPI

````yaml /openapi-specs/Master-pro-api.json get /services/bens/api/v1/{chain_id}/domains/{name}
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
  /services/bens/api/v1/{chain_id}/domains/{name}:
    get:
      tags:
        - DomainsExtractor
      summary: Get detailed information about domain for Detailed domain page
      operationId: DomainsExtractor_GetDomain
      parameters:
        - description: The chain (network) where domain search should be done
          in: path
          name: chain_id
          required: true
          schema:
            format: int64
            type: string
        - description: Name of domain, for example vitalik.eth
          in: path
          name: name
          required: true
          schema:
            type: string
        - description: Filtering field to remove expired domains
          in: query
          name: only_active
          schema:
            type: boolean
        - description: >-
            Protocol id of domain, default is first priority protocol on that
            chain
          in: query
          name: protocol_id
          schema:
            type: string
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/v1DetailedDomain'
          description: A successful response.
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
        default:
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/googlerpcStatus'
          description: An unexpected error response.
components:
  schemas:
    v1DetailedDomain:
      properties:
        expiry_date:
          title: >-
            Optional. RFC 3339 datetime  of expiry date. None means never
            expires
          type: string
        id:
          title: Unique id for the domain, also known as nodehash
          type: string
        name:
          title: >-
            The human readable name, if known. Unknown portions replaced with
            hash in square brackets (eg, foo.[1234].eth)
          type: string
        other_addresses:
          additionalProperties:
            type: string
          title: >-
            Map chain -> resolved_address that contains other blockchain
            addresses.

            This map will contain `current_chain_id` -> `resovled_address` if
            `resovled_address` is not None
          type: object
        owner:
          $ref: '#/components/schemas/v1Address'
          title: The account that owns the domain
        protocol:
          $ref: '#/components/schemas/v1ProtocolInfo'
          title: Information about protocol that domain belongs to
        protocol_dapp_logo:
          description: |-
            Optional. Logo URL of the protocol's own dApp. Same value for every
            domain in the protocol, surfaced here for convenient rendering
            alongside `protocol_dapp_url`.
          type: string
        protocol_dapp_url:
          description: |-
            Optional. Deep link to this domain inside the protocol's own dApp,
            rendered from the protocol's `protocol_dapp_url_template` config.
          type: string
        registrant:
          $ref: '#/components/schemas/v1Address'
          title: Optional. The account that owns the ERC721 NFT for the domain
        registration_date:
          description: Optional. RFC 3339 datetime  of expiry date.
          type: string
        resolved_address:
          $ref: '#/components/schemas/v1Address'
          title: Optional. Resolved address of this domain
        resolved_with_wildcard:
          type: boolean
        resolver_address:
          $ref: '#/components/schemas/v1Address'
        stored_offchain:
          type: boolean
        tokens:
          items:
            $ref: '#/components/schemas/v1Token'
            type: object
          title: List of NFT tokens related to this domain
          type: array
        wrapped_owner:
          $ref: '#/components/schemas/v1Address'
          title: Optional. Owner of NameWrapper NFT
      type: object
    googlerpcStatus:
      properties:
        code:
          format: int32
          type: integer
        details:
          items:
            $ref: '#/components/schemas/protobufAny'
            type: object
          type: array
        message:
          type: string
      type: object
    v1Address:
      properties:
        chain_id:
          type: string
        contract_name:
          type: string
        domain_info:
          $ref: '#/components/schemas/v1DomainInfo'
        hash:
          type: string
        is_contract:
          type: boolean
        is_token:
          type: boolean
        is_verified_contract:
          type: boolean
        token_name:
          type: string
        token_type:
          $ref: '#/components/schemas/v1TokenType'
      type: object
    v1ProtocolInfo:
      properties:
        deployment_blockscout_base_url:
          type: string
        description:
          type: string
        docs_url:
          type: string
        icon_url:
          type: string
        id:
          type: string
        short_name:
          type: string
        title:
          type: string
        tld_list:
          items:
            type: string
          type: array
      type: object
    v1Token:
      properties:
        address:
          type: string
        chain_id:
          type: string
        icon_url:
          type: string
        is_verified_contract:
          type: boolean
        name:
          type: string
        symbol:
          type: string
      type: object
    protobufAny:
      additionalProperties:
        path: >-
          /{chain_id}/api/v2/tokens/{address_hash_param}/instances/{token_id_param}/refetch-metadata
      properties:
        '@type':
          type: string
      type: object
    v1DomainInfo:
      properties:
        address:
          type: string
        expiry_date:
          type: string
        name:
          type: string
        names_count:
          format: int64
          type: integer
      type: object
    v1TokenType:
      default: TOKEN_TYPE_UNSPECIFIED
      enum:
        - TOKEN_TYPE_UNSPECIFIED
        - TOKEN_TYPE_ERC_20
        - TOKEN_TYPE_ERC_721
        - TOKEN_TYPE_ERC_1155
        - TOKEN_TYPE_ERC_404
        - TOKEN_TYPE_ERC_7802
        - TOKEN_TYPE_ZRC_2
        - TOKEN_TYPE_NATIVE
        - TOKEN_TYPE_ERC_7984
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