> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Base URL & Versioning

> API endpoint structure and versioning information

The Bags API uses a consistent base URL structure for all endpoints:

* **Base URL**: `https://public-api-v2.bags.fm/api/v1/`
* **Current version**: v1
* **Health check**: GET `/ping` returns `{message: "pong"}`

All endpoints are prefixed with the base URL. Future API versions will be released with updated version numbers in the path.

## Health Check

Test API connectivity:

<CodeGroup>
  ```bash cURL theme={null}
  curl https://public-api-v2.bags.fm/ping
  ```

  ```javascript Node.js theme={null}
  const response = await fetch('https://public-api-v2.bags.fm/ping');
  const data = await response.json();
  console.log(data); // { message: "pong" }
  ```

  ```python Python theme={null}
  import requests

  response = requests.get('https://public-api-v2.bags.fm/ping')
  print(response.json())  # { "message": "pong" }
  ```
</CodeGroup>

**Response:**

```json theme={null}
{
  "message": "pong"
}
```

## Version History

| Version | Release Date | Status  | Breaking Changes      |
| ------- | ------------ | ------- | --------------------- |
| v1      | 2025-08-02   | Current | N/A (Initial release) |

<Note>
  Future API versions will maintain backward compatibility where possible. Breaking changes will be clearly documented and communicated in advance.
</Note>
