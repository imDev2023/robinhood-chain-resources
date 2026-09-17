Title: Reference | DEX Screener - Docs

URL Source: https://docs.dexscreener.com/api/reference

Markdown Content:
⌘Ctrl k

1.   [🤖API](https://docs.dexscreener.com/api)

## Reference

DEX Screener API reference

### Get the latest token profiles (rate-limit 60 requests per minute)[](https://docs.dexscreener.com/api/reference#get-token-profiles-latest-v1)

get

200

Ok

application/json

url string · uri Optional

chainId string Optional

tokenAddress string Optional

icon string · uri Optional

header string · uri · nullable Optional

description string · nullable Optional

get/token-profiles/latest/v1

```
GET /token-profiles/latest/v1 HTTP/1.1
Host: api.dexscreener.com
Accept: */*
```

200

Ok

```
{
  "url": "https://example.com",
  "chainId": "text",
  "tokenAddress": "text",
  "icon": "https://example.com",
  "header": "https://example.com",
  "description": "text",
  "links": [
    {
      "type": "text",
      "label": "text",
      "url": "https://example.com"
    }
  ]
}
```

### Get recently updated token profiles (rate-limit 60 requests per minute)[](https://docs.dexscreener.com/api/reference#get-token-profiles-recent-updates-v1)

get

200

Ok

application/json

url string · uri Optional

chainId string Optional

tokenAddress string Optional

icon string · uri Optional

header string · uri · nullable Optional

description string · nullable Optional

get/token-profiles/recent-updates/v1

```
GET /token-profiles/recent-updates/v1 HTTP/1.1
Host: api.dexscreener.com
Accept: */*
```

200

Ok

```
{
  "url": "https://example.com",
  "chainId": "text",
  "tokenAddress": "text",
  "icon": "https://example.com",
  "header": "https://example.com",
  "description": "text",
  "links": [
    {
      "type": "text",
      "label": "text",
      "url": "https://example.com"
    }
  ]
}
```

### Get the latest token community takeovers (rate-limit 60 requests per minute)[](https://docs.dexscreener.com/api/reference#get-community-takeovers-latest-v1)

get

200

Ok

application/json

url string · uri Optional

chainId string Optional

tokenAddress string Optional

icon string · uri Optional

header string · uri · nullable Optional

description string · nullable Optional

claimDate string · date-time Optional

get/community-takeovers/latest/v1

```
GET /community-takeovers/latest/v1 HTTP/1.1
Host: api.dexscreener.com
Accept: */*
```

200

Ok

```
[
  {
    "url": "https://example.com",
    "chainId": "text",
    "tokenAddress": "text",
    "icon": "https://example.com",
    "header": "https://example.com",
    "description": "text",
    "links": [
      {
        "type": "text",
        "label": "text",
        "url": "https://example.com"
      }
    ],
    "claimDate": "2026-01-01T00:00:00.000Z"
  }
]
```

### Get the latest ads (rate-limit 60 requests per minute)[](https://docs.dexscreener.com/api/reference#get-a-ds-latest-v1)

get

200

Ok

application/json

url string · uri Optional

chainId string Optional

tokenAddress string Optional

date string · date-time Optional

type string Optional

durationHours number · nullable Optional

impressions number · nullable Optional

get/ads/latest/v1

```
GET /ads/latest/v1 HTTP/1.1
Host: api.dexscreener.com
Accept: */*
```

200

Ok

```
[
  {
    "url": "https://example.com",
    "chainId": "text",
    "tokenAddress": "text",
    "date": "2026-01-01T00:00:00.000Z",
    "type": "text",
    "durationHours": 1,
    "impressions": 1
  }
]
```

### Get the latest boosted tokens (rate-limit 60 requests per minute)[](https://docs.dexscreener.com/api/reference#get-token-boosts-latest-v1)

get

200

Ok

application/json

url string · uri Optional

chainId string Optional

tokenAddress string Optional

amount number Optional

totalAmount number Optional

icon string · uri · nullable Optional

header string · uri · nullable Optional

description string · nullable Optional

get/token-boosts/latest/v1

```
GET /token-boosts/latest/v1 HTTP/1.1
Host: api.dexscreener.com
Accept: */*
```

200

Ok

```
{
  "url": "https://example.com",
  "chainId": "text",
  "tokenAddress": "text",
  "amount": 1,
  "totalAmount": 1,
  "icon": "https://example.com",
  "header": "https://example.com",
  "description": "text",
  "links": [
    {
      "type": "text",
      "label": "text",
      "url": "https://example.com"
    }
  ]
}
```

### Get the tokens with most active boosts (rate-limit 60 requests per minute)[](https://docs.dexscreener.com/api/reference#get-token-boosts-top-v1)

get

200

Ok

application/json

url string · uri Optional

chainId string Optional

tokenAddress string Optional

amount number Optional

totalAmount number Optional

icon string · uri · nullable Optional

header string · uri · nullable Optional

description string · nullable Optional

get/token-boosts/top/v1

```
GET /token-boosts/top/v1 HTTP/1.1
Host: api.dexscreener.com
Accept: */*
```

200

Ok

```
{
  "url": "https://example.com",
  "chainId": "text",
  "tokenAddress": "text",
  "amount": 1,
  "totalAmount": 1,
  "icon": "https://example.com",
  "header": "https://example.com",
  "description": "text",
  "links": [
    {
      "type": "text",
      "label": "text",
      "url": "https://example.com"
    }
  ]
}
```

### Check paid orders for a token (rate-limit 60 requests per minute)[](https://docs.dexscreener.com/api/reference#get-orders-v1-chainid-tokenaddress)

get

chainId string Required Example: `solana`

tokenAddress string Required Example: `A55XjvzRU4KtR3Lrys8PpLZQvPojPqvnv5bJVHMYy3Jv`

200

Ok

application/json

type string · enum Optional Possible values:

status string · enum Optional Possible values:

paymentTimestamp number Optional

get/orders/v1/{chainId}/{tokenAddress}

```
GET /orders/v1/{chainId}/{tokenAddress} HTTP/1.1
Host: api.dexscreener.com
Accept: */*
```

200

Ok

```
[
  {
    "type": "tokenProfile",
    "status": "processing",
    "paymentTimestamp": 1
  }
]
```

### Get one or multiple pairs by chain and pair address (rate-limit 300 requests per minute)[](https://docs.dexscreener.com/api/reference#get-latest-dex-pairs-chainid-pairid)

get

chainId string Required Example: `solana`

pairId string Required Example: `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN`

200

Ok

application/json

schemaVersion string Optional

get/latest/dex/pairs/{chainId}/{pairId}

```
GET /latest/dex/pairs/{chainId}/{pairId} HTTP/1.1
Host: api.dexscreener.com
Accept: */*
```

200

Ok

```
{
  "schemaVersion": "text",
  "pairs": [
    {
      "chainId": "text",
      "dexId": "text",
      "url": "https://example.com",
      "pairAddress": "text",
      "labels": [
        "text"
      ],
      "baseToken": {
        "address": "text",
        "name": "text",
        "symbol": "text"
      },
      "quoteToken": {
        "address": "text",
        "name": "text",
        "symbol": "text"
      },
      "priceNative": "text",
      "priceUsd": "text",
      "txns": {
        "ANY_ADDITIONAL_PROPERTY": {
          "buys": 1,
          "sells": 1
        }
      },
      "volume": {
        "ANY_ADDITIONAL_PROPERTY": 1
      },
      "priceChange": {
        "ANY_ADDITIONAL_PROPERTY": 1
      },
      "liquidity": {
        "usd": 1,
        "base": 1,
        "quote": 1
      },
      "fdv": 1,
      "marketCap": 1,
      "pairCreatedAt": 1,
      "info": {
        "imageUrl": "https://example.com",
        "websites": [
          {
            "url": "https://example.com"
          }
        ],
        "socials": [
          {
            "platform": "text",
            "handle": "text"
          }
        ]
      },
      "boosts": {
        "active": 1
      }
    }
  ]
}
```

### Search for pairs matching query (rate-limit 300 requests per minute)[](https://docs.dexscreener.com/api/reference#get-latest-dex-search)

get

q string Required Example: `SOL/USDC`

200

Ok

application/json

schemaVersion string Optional

get/latest/dex/search

```
GET /latest/dex/search?q=text HTTP/1.1
Host: api.dexscreener.com
Accept: */*
```

200

Ok

```
{
  "schemaVersion": "text",
  "pairs": [
    {
      "chainId": "text",
      "dexId": "text",
      "url": "https://example.com",
      "pairAddress": "text",
      "labels": [
        "text"
      ],
      "baseToken": {
        "address": "text",
        "name": "text",
        "symbol": "text"
      },
      "quoteToken": {
        "address": "text",
        "name": "text",
        "symbol": "text"
      },
      "priceNative": "text",
      "priceUsd": "text",
      "txns": {
        "ANY_ADDITIONAL_PROPERTY": {
          "buys": 1,
          "sells": 1
        }
      },
      "volume": {
        "ANY_ADDITIONAL_PROPERTY": 1
      },
      "priceChange": {
        "ANY_ADDITIONAL_PROPERTY": 1
      },
      "liquidity": {
        "usd": 1,
        "base": 1,
        "quote": 1
      },
      "fdv": 1,
      "marketCap": 1,
      "pairCreatedAt": 1,
      "info": {
        "imageUrl": "https://example.com",
        "websites": [
          {
            "url": "https://example.com"
          }
        ],
        "socials": [
          {
            "platform": "text",
            "handle": "text"
          }
        ]
      },
      "boosts": {
        "active": 1
      }
    }
  ]
}
```

### Get the pools of a given token address (rate-limit 300 requests per minute)[](https://docs.dexscreener.com/api/reference#get-token-pairs-v1-chainid-tokenaddress)

get

chainId string Required Example: `solana`

tokenAddress string Required

A token addresses

Example: `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN`

200

Ok

application/json

chainId string Optional

dexId string Optional

url string · uri Optional

pairAddress string Optional

labels string[] · nullable Optional

priceNative string Optional

priceUsd string · nullable Optional

fdv number · nullable Optional

marketCap number · nullable Optional

pairCreatedAt integer · nullable Optional

get/token-pairs/v1/{chainId}/{tokenAddress}

```
GET /token-pairs/v1/{chainId}/{tokenAddress} HTTP/1.1
Host: api.dexscreener.com
Accept: */*
```

200

Ok

```
[
  {
    "chainId": "text",
    "dexId": "text",
    "url": "https://example.com",
    "pairAddress": "text",
    "labels": [
      "text"
    ],
    "baseToken": {
      "address": "text",
      "name": "text",
      "symbol": "text"
    },
    "quoteToken": {
      "address": "text",
      "name": "text",
      "symbol": "text"
    },
    "priceNative": "text",
    "priceUsd": "text",
    "txns": {
      "ANY_ADDITIONAL_PROPERTY": {
        "buys": 1,
        "sells": 1
      }
    },
    "volume": {
      "ANY_ADDITIONAL_PROPERTY": 1
    },
    "priceChange": {
      "ANY_ADDITIONAL_PROPERTY": 1
    },
    "liquidity": {
      "usd": 1,
      "base": 1,
      "quote": 1
    },
    "fdv": 1,
    "marketCap": 1,
    "pairCreatedAt": 1,
    "info": {
      "imageUrl": "https://example.com",
      "websites": [
        {
          "url": "https://example.com"
        }
      ],
      "socials": [
        {
          "platform": "text",
          "handle": "text"
        }
      ]
    },
    "boosts": {
      "active": 1
    }
  }
]
```

### Get one or multiple pairs by token address (rate-limit 300 requests per minute)[](https://docs.dexscreener.com/api/reference#get-tokens-v1-chainid-tokenaddresses)

get

chainId string Required Example: `solana`

tokenAddresses string Required

One or multiple, comma-separated token addresses (up to 30 addresses)

Example: `So11111111111111111111111111111111111111112,EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v`

200

Ok

application/json

chainId string Optional

dexId string Optional

url string · uri Optional

pairAddress string Optional

labels string[] · nullable Optional

priceNative string Optional

priceUsd string · nullable Optional

fdv number · nullable Optional

marketCap number · nullable Optional

pairCreatedAt integer · nullable Optional

get/tokens/v1/{chainId}/{tokenAddresses}

```
GET /tokens/v1/{chainId}/{tokenAddresses} HTTP/1.1
Host: api.dexscreener.com
Accept: */*
```

200

Ok

```
[
  {
    "chainId": "text",
    "dexId": "text",
    "url": "https://example.com",
    "pairAddress": "text",
    "labels": [
      "text"
    ],
    "baseToken": {
      "address": "text",
      "name": "text",
      "symbol": "text"
    },
    "quoteToken": {
      "address": "text",
      "name": "text",
      "symbol": "text"
    },
    "priceNative": "text",
    "priceUsd": "text",
    "txns": {
      "ANY_ADDITIONAL_PROPERTY": {
        "buys": 1,
        "sells": 1
      }
    },
    "volume": {
      "ANY_ADDITIONAL_PROPERTY": 1
    },
    "priceChange": {
      "ANY_ADDITIONAL_PROPERTY": 1
    },
    "liquidity": {
      "usd": 1,
      "base": 1,
      "quote": 1
    },
    "fdv": 1,
    "marketCap": 1,
    "pairCreatedAt": 1,
    "info": {
      "imageUrl": "https://example.com",
      "websites": [
        {
          "url": "https://example.com"
        }
      ],
      "socials": [
        {
          "platform": "text",
          "handle": "text"
        }
      ]
    },
    "boosts": {
      "active": 1
    }
  }
]
```

### Get trending metas (rate-limit 60 requests per minute)[](https://docs.dexscreener.com/api/reference#get-metas-trending-v1)

get

200

Ok

application/json

description string Optional

name string Optional

slug string Optional

marketCap number · double Optional

liquidity number · double Optional

volume number · double Optional

tokenCount integer Optional

get/metas/trending/v1

```
GET /metas/trending/v1 HTTP/1.1
Host: api.dexscreener.com
Accept: */*
```

200

Ok

```
[
  {
    "description": "text",
    "icon": {
      "type": "text",
      "value": "text"
    },
    "name": "text",
    "slug": "text",
    "marketCap": 1,
    "liquidity": 1,
    "volume": 1,
    "tokenCount": 1,
    "marketCapChange": {
      "m5": 1,
      "h1": 1,
      "h6": 1,
      "h24": 1
    },
    "marketCapDelta": {
      "m5": 1,
      "h1": 1,
      "h6": 1,
      "h24": 1
    }
  }
]
```

### Get meta information for a given slug (rate-limit 60 requests per minute)[](https://docs.dexscreener.com/api/reference#get-metas-meta-v1-slug)

get

slug string Required Example: `ai`

200

Ok

application/json

description string Optional

name string Optional

slug string Optional

marketCap number · double Optional

liquidity number · double Optional

volume number · double Optional

tokenCount integer Optional

get/metas/meta/v1/{slug}

```
GET /metas/meta/v1/{slug} HTTP/1.1
Host: api.dexscreener.com
Accept: */*
```

200

Ok

```
{
  "description": "Artificial intelligence and agents",
  "icon": {
    "type": "emoji",
    "value": "🤖"
  },
  "name": "AI",
  "slug": "ai",
  "marketCap": 100000,
  "liquidity": 100000,
  "volume": 100000,
  "tokenCount": 0,
  "marketCapChange": {
    "m5": 0,
    "h1": 0,
    "h6": 0,
    "h24": 0
  },
  "marketCapDelta": {
    "m5": 100000,
    "h1": 100000,
    "h6": 100000,
    "h24": 100000
  },
  "pairs": []
}
```

Last updated 4 months ago

*   [get Get the latest token profiles (rate-limit 60 requests per minute)](https://docs.dexscreener.com/api/reference#get-token-profiles-latest-v1)
*   [get Get recently updated token profiles (rate-limit 60 requests per minute)](https://docs.dexscreener.com/api/reference#get-token-profiles-recent-updates-v1)
*   [get Get the latest token community takeovers (rate-limit 60 requests per minute)](https://docs.dexscreener.com/api/reference#get-community-takeovers-latest-v1)
*   [get Get the latest ads (rate-limit 60 requests per minute)](https://docs.dexscreener.com/api/reference#get-a-ds-latest-v1)
*   [get Get the latest boosted tokens (rate-limit 60 requests per minute)](https://docs.dexscreener.com/api/reference#get-token-boosts-latest-v1)
*   [get Get the tokens with most active boosts (rate-limit 60 requests per minute)](https://docs.dexscreener.com/api/reference#get-token-boosts-top-v1)
*   [get Check paid orders for a token (rate-limit 60 requests per minute)](https://docs.dexscreener.com/api/reference#get-orders-v1-chainid-tokenaddress)
*   [get Get one or multiple pairs by chain and pair address (rate-limit 300 requests per minute)](https://docs.dexscreener.com/api/reference#get-latest-dex-pairs-chainid-pairid)
*   [get Search for pairs matching query (rate-limit 300 requests per minute)](https://docs.dexscreener.com/api/reference#get-latest-dex-search)
*   [get Get the pools of a given token address (rate-limit 300 requests per minute)](https://docs.dexscreener.com/api/reference#get-token-pairs-v1-chainid-tokenaddress)
*   [get Get one or multiple pairs by token address (rate-limit 300 requests per minute)](https://docs.dexscreener.com/api/reference#get-tokens-v1-chainid-tokenaddresses)
*   [get Get trending metas (rate-limit 60 requests per minute)](https://docs.dexscreener.com/api/reference#get-metas-trending-v1)
*   [get Get meta information for a given slug (rate-limit 60 requests per minute)](https://docs.dexscreener.com/api/reference#get-metas-meta-v1-slug)
