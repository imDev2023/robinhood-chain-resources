# Bags - What are the rate limits?

> Source: https://docs.bags.fm/faq/what-are-rate-limits
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/faq/what-are-rate-limits.md)

---

# What are the rate limits?

> Understanding Bags API rate limits and how to monitor usage

## What are the rate limits?

The Bags API implements rate limiting to ensure fair usage and system stability.

### Rate Limit Details

* **Limit**: 5,000 requests per hour per user and per ip
* **Scope**: Rate limits apply across all your API keys (shared quota)
* **Headers**: Response headers include rate limit information

### Monitoring Your Usage

Check these response headers to monitor your API usage:

* `X-RateLimit-Limit`: Total requests allowed per hour (5,000)
* `X-RateLimit-Remaining`: Requests remaining in current window
* `X-RateLimit-Reset`: Unix timestamp when the limit resets

### Example

```javascript theme={null}
const response = await fetch('https://public-api-v2.bags.fm/api/v1/endpoint', {
  headers: { 'x-api-key': 'YOUR_API_KEY' }
});

console.log('Remaining:', response.headers.get('X-RateLimit-Remaining'));
console.log('Resets at:', new Date(
  parseInt(response.headers.get('X-RateLimit-Reset')) * 1000
));
```

<Tip>
  Distribute requests evenly throughout the hour to avoid hitting rate limits. Consider implementing exponential backoff for failed requests.
</Tip>

See the [Rate Limits guide](/principles/rate-limits) for more detailed information.
