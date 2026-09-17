# Bags - Rate Limits

> Source: https://docs.bags.fm/principles/rate-limits
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/principles/rate-limits.md)

---

# Rate Limits

> Understanding API rate limits and monitoring usage

The Bags API implements rate limiting to ensure fair usage and system stability.

## Rate Limit Overview

* **Rate limit**: 5,000 requests per hour per user and per ip
* **Scope**: Rate limits apply across all your API keys
* **System**: Sliding hourly windows (not fixed periods)

## Endpoint-Specific Limits

Certain endpoints may enforce additional, endpoint-specific rate limits. These limits are intentionally not publicly disclosed and apply only to the affected endpoints. Under normal usage patterns you should not encounter these limits. If you do get rate limited, please reach out to us so we can help.

## Response Headers

Monitor your API usage through response headers included with every request:

* **`X-RateLimit-Limit`**: Total requests allowed per hour (5,000)
* **`X-RateLimit-Remaining`**: Requests remaining in current window
* **`X-RateLimit-Reset`**: Unix timestamp when the limit resets

## Sliding Window System

Rate limits use sliding hourly windows rather than fixed periods:

* Window 1: 1:00 PM - 2:00 PM
* Window 2: 2:00 PM - 3:00 PM
* And so on...

This means your rate limit resets continuously rather than at fixed times.

## Monitoring Usage

<CodeGroup>
  ```bash cURL theme={null}
  curl -I -X GET 'https://public-api-v2.bags.fm/ping' \
    -H 'x-api-key: YOUR_API_KEY'

  # Response headers include:
  # X-RateLimit-Limit: 5000
  # X-RateLimit-Remaining: 4999
  # X-RateLimit-Reset: 1672531200
  ```

  ```javascript Node.js theme={null}
  const response = await fetch('https://public-api-v2.bags.fm/ping', {
    headers: { 'x-api-key': 'YOUR_API_KEY' }
  });

  console.log('Rate Limit:', response.headers.get('X-RateLimit-Limit'));
  console.log('Remaining:', response.headers.get('X-RateLimit-Remaining'));
  console.log('Reset Time:', response.headers.get('X-RateLimit-Reset'));

  // Convert reset time to readable format
  const resetTime = new Date(parseInt(response.headers.get('X-RateLimit-Reset')) * 1000);
  console.log('Resets at:', resetTime.toLocaleString());
  ```

  ```python Python theme={null}
  import requests
  from datetime import datetime

  response = requests.get(
    'https://public-api-v2.bags.fm/ping',
    headers={'x-api-key': 'YOUR_API_KEY'}
  )

  print(f"Rate Limit: {response.headers.get('X-RateLimit-Limit')}")
  print(f"Remaining: {response.headers.get('X-RateLimit-Remaining')}")
  print(f"Reset Time: {response.headers.get('X-RateLimit-Reset')}")

  # Convert reset time to readable format
  reset_timestamp = int(response.headers.get('X-RateLimit-Reset'))
  reset_time = datetime.fromtimestamp(reset_timestamp)
  print(f"Resets at: {reset_time}")
  ```
</CodeGroup>

## Rate Limit Exceeded

When you exceed your rate limit, the API returns a `429` status with additional information:

```json theme={null}
{
  "success": false,
  "error": "Rate limit exceeded",
  "limit": 5000,
  "remaining": 0,
  "resetTime": 1672531200
}
```

## Rate Limit Planning

### Calculate Request Budget

Plan your API usage based on your application's needs:

* **5,000 requests/hour** = \~83.3 requests/minute = \~1.39 requests/second
* **High-frequency apps**: Consider request batching or caching
* **Background jobs**: Spread requests across the hour

<Warning>
  Rate limits apply across all API keys for your account. Creating multiple API keys does not increase your rate limit.
</Warning>

<Tip>
  If you need to increase your rate limit, please contact us.
</Tip>
