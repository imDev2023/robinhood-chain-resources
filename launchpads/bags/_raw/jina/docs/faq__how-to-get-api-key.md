> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# How do I get an API key?

> Step-by-step guide to obtaining your Bags API key

## How do I get an API key?

Getting an API key is simple and only takes a few minutes.

### Steps to Get Your API Key

1. Visit [dev.bags.fm](https://dev.bags.fm) and sign in to your account
2. Navigate to the **API Keys** section
3. Click **Generate new Key**
4. Give your key a descriptive name (e.g., "Production API", "Development API")
5. Copy and securely store your API key

<Warning>
  Keep your API keys secure and never share them publicly. Each user can create up to 10 API keys.
</Warning>

### Using Your API Key

Include your API key in the `x-api-key` header with every request:

```bash theme={null}
curl -X GET 'https://public-api-v2.bags.fm/api/v1/endpoint' \
  -H 'x-api-key: YOUR_API_KEY'
```

### Managing API Keys

You can revoke API keys at any time from the [Developer Portal](https://dev.bags.fm). Revoking a key immediately stops all requests using that key.
