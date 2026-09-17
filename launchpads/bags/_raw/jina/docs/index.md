> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Bags API Documentation

> Build powerful applications with the Bags API - get started with authentication, rate limits, and your first API call

## Getting started

The Bags API allows you to integrate Bags functionality into your applications. Get up and running in minutes.

## Authentication

All API requests require authentication using an API key.

### Get your API key

1. Visit [dev.bags.fm](https://dev.bags.fm) and sign in to your account
2. Navigate to the API Keys section
3. Create a new API key

<Note>
  Each user can create up to 10 API keys. Keep your keys secure and never share them publicly.
</Note>

### Using your API key

Include your API key in the `x-api-key` header with every request:

```bash cURL theme={null}
curl -X GET 'https://public-api-v2.bags.fm/api/v1/endpoint' \
  -H 'x-api-key: YOUR_API_KEY'
```

<CodeGroup>
  ```javascript Node.js theme={null}
  const response = await fetch('https://public-api-v2.bags.fm/api/v1/endpoint', {
    headers: {
      'x-api-key': 'YOUR_API_KEY'
    }
  });
  ```

  ```python Python theme={null}
  import requests

  response = requests.get('https://public-api-v2.bags.fm/api/v1/endpoint', 
    headers={'x-api-key': 'YOUR_API_KEY'})
  ```
</CodeGroup>

### Managing API keys

You can revoke API keys at any time:

1. Go to [dev.bags.fm](https://dev.bags.fm)
2. Find the key you want to revoke
3. Click "Revoke" to permanently disable it

<Warning>
  Revoking an API key immediately stops all requests using that key. Update your applications before revoking keys that are in use.
</Warning>

## Rate limits

The Bags API implements rate limiting to ensure fair usage and system stability.

* **Rate limit**: 5,000 requests per hour per user and per ip
* **Scope**: Rate limits apply across all your API keys
* **Headers**: Check `X-RateLimit-Remaining` and `X-RateLimit-Reset` in response headers

<Tip>
  Distribute requests evenly throughout the hour to avoid hitting rate limits. Consider implementing exponential backoff for failed requests.
</Tip>

## Core Principles

Get familiar with key concepts and best practices:

<Columns cols={2}>
  <Card title="Base URL & Versioning" icon="link" href="/principles/base-url-versioning">
    API endpoint structure and versioning information.
  </Card>

  <Card title="Error Handling" icon="exclamation-triangle" href="/principles/error-handling">
    Understanding API error responses and status codes.
  </Card>

  <Card title="Rate Limits" icon="clock" href="/principles/rate-limits">
    Monitor usage and avoid hitting rate limits.
  </Card>

  <Card title="File Uploads" icon="upload" href="/principles/file-uploads">
    Upload images and files for token creation.
  </Card>

  <Card title="API Key Management" icon="key" href="/principles/api-key-management">
    Best practices for securing and organizing API keys.
  </Card>

  <Card title="Token Launch Workflow" icon="rocket" href="/principles/token-launch-workflow">
    Complete guide to creating Solana tokens.
  </Card>
</Columns>

## Explore the API

<Columns cols={2}>
  <Card title="API Reference" icon="terminal" href="/api-reference/introduction">
    Complete endpoint documentation with examples.
  </Card>

  <Card title="Bags CLI" icon="rectangle-terminal" href="/cli/install-and-setup">
    Install and use the Bags CLI for quick terminal-based workflows.
  </Card>
</Columns>
