# Bags - Error Handling

> Source: https://docs.bags.fm/principles/error-handling
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/principles/error-handling.md)

---

# Error Handling

> Understanding API error responses and status codes

The Bags API uses standardized error responses to help you handle issues in your applications.

## Error Response Format

All errors return JSON with a consistent structure:

```json theme={null}
{
  "success": false,
  "error": "Detailed error message"
}
```

Success responses use a different format:

```json theme={null}
{
  "success": true,
  "response": {
    // Response data here
  }
}
```

## Common Status Codes

| Status Code | Description           | When It Occurs                                    |
| ----------- | --------------------- | ------------------------------------------------- |
| 400         | Bad Request           | Invalid request parameters or validation errors   |
| 401         | Unauthorized          | Missing or invalid API key/authentication         |
| 403         | Forbidden             | Valid authentication but insufficient permissions |
| 404         | Not Found             | Resource not found                                |
| 413         | Payload Too Large     | File upload exceeds size limit                    |
| 429         | Too Many Requests     | Rate limit exceeded                               |
| 500         | Internal Server Error | Unexpected server error                           |

## Error Examples

### Validation Error (400)

```json theme={null}
{
  "success": false,
  "error": "Token name is required and must be between 1-32 characters"
}
```

### Authentication Error (401)

```json theme={null}
{
  "success": false,
  "error": "Invalid API key. Please check your x-api-key header."
}
```

### Permission Error (403)

```json theme={null}
{
  "success": false,
  "error": "API key does not have permission to access this resource"
}
```

### Rate Limit Error (429)

When you exceed rate limits, the API returns additional information:

```json theme={null}
{
  "success": false,
  "error": "Rate limit exceeded",
  "limit": 5000,
  "remaining": 0,
  "resetTime": 1672531200
}
```

### File Upload Error (413)

```json theme={null}
{
  "success": false,
  "error": "Image file must be under 15MB"
}
```

### Server Error (500)

```json theme={null}
{
  "success": false,
  "error": "An unexpected error occurred. Please try again later."
}
```

## SDK Error Handling

When using the Bags TypeScript SDK, errors are automatically handled and thrown as exceptions. The SDK wraps API responses and throws errors for failed requests:

```typescript theme={null}
import { BagsSDK } from "@bagsfm/bags-sdk";

try {
  const sdk = new BagsSDK(apiKey, connection);
  const result = await sdk.tokenLaunch.createTokenInfoAndMetadata({...});
  // Success - result contains the response data directly
} catch (error) {
  // The SDK automatically throws errors for API failures
  // Error messages contain details about what went wrong
  console.error('Error:', error.message);
  
  // You can check error properties if available
  if (error.status) {
    console.error('Status:', error.status);
  }
}
```

The SDK automatically handles the `success: false` responses and throws errors, so you don't need to manually check the `success` field. Successful responses return the data directly from the `response` field.

## Best Practices

### Error Handling in Code

<CodeGroup>
  ```javascript Node.js theme={null}
  try {
    const response = await fetch('https://public-api-v2.bags.fm/api/v1/endpoint', {
      headers: { 'x-api-key': 'YOUR_API_KEY' }
    });
    
    const data = await response.json();
    
    if (!data.success) {
      console.error('API Error:', data.error);
      // Handle specific error cases
      switch (response.status) {
        case 401:
          // Redirect to login or refresh API key
          break;
        case 429:
          // Implement exponential backoff
          break;
        default:
          // Generic error handling
      }
      return;
    }
    
    // Process successful response
    console.log(data.response);
  } catch (error) {
    console.error('Network error:', error);
  }
  ```

  ```python Python theme={null}
  import requests
  import time

  def handle_api_request(endpoint, headers):
      try:
          response = requests.get(endpoint, headers=headers)
          data = response.json()
          
          if not data.get('success', False):
              print(f"API Error: {data.get('error')}")
              
              if response.status_code == 401:
                  # Handle authentication error
                  pass
              elif response.status_code == 429:
                  # Implement retry with backoff
                  time.sleep(60)  # Wait 1 minute
                  return handle_api_request(endpoint, headers)
              
              return None
              
          return data['response']
          
      except requests.RequestException as e:
          print(f"Network error: {e}")
          return None
  ```
</CodeGroup>

### Retry Logic

Implement exponential backoff for rate limit and server errors:

1. **429 (Rate Limited)**: Wait based on `resetTime` or implement exponential backoff
2. **500/502/503**: Retry with exponential backoff (max 5 attempts)
3. **400/401/403/404**: Don't retry - fix the request first

<Tip>
  Check the `X-RateLimit-*` headers to proactively avoid rate limits rather than handling them reactively.
</Tip>
