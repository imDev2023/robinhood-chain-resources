> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# API Key Management

> Best practices for creating, organizing, and securing your API keys

Manage your API keys efficiently to maintain security and organization across your applications.

## Getting Your First API Key

1. Visit [dev.bags.fm](https://dev.bags.fm) and sign in to your account
2. Navigate to the API Keys section
3. Create a new API key with a descriptive name
4. Copy and securely store your API key

<Note>
  Each user can create up to 10 API keys. Keep your keys secure and never share them publicly.
</Note>

## Key Limitations

* **Maximum keys**: 10 API keys per user account
* **Key naming**: Name your keys for easy organization and identification
* **Usage tracking**: Keys track last usage timestamp for monitoring
* **Immediate revocation**: Revoking a key instantly stops all requests using that key

## Best Practices

### 1. Descriptive Naming

Use clear, descriptive names that identify the key's purpose:

**Good examples:**

* `Production-Web-App`
* `Development-Environment`
* `Mobile-App-iOS`
* `Background-Jobs-Server`
* `Testing-Integration`

**Poor examples:**

* `Key1`
* `Test`
* `MyKey`
* `temp`

### 2. Environment Separation

Create separate keys for different environments:

```javascript theme={null}
// Environment-specific configurations
const config = {
  development: {
    apiKey: 'bags_test_dev123...',
    baseURL: 'https://public-api-v2.bags.fm/api/v1/'
  },
  staging: {
    apiKey: 'bags_test_staging456...',
    baseURL: 'https://public-api-v2.bags.fm/api/v1/'
  },
  production: {
    apiKey: 'bags_live_prod789...',
    baseURL: 'https://public-api-v2.bags.fm/api/v1/'
  }
};
```

### 3. Application-Specific Keys

Use different keys for different applications or services:

| Application       | Key Name             | Purpose              |
| ----------------- | -------------------- | -------------------- |
| Web Dashboard     | `Web-Dashboard-Prod` | Main web application |
| Mobile App        | `Mobile-App-v2`      | iOS/Android app      |
| Background Jobs   | `Cronjobs-Server`    | Scheduled tasks      |
| Analytics         | `Analytics-Service`  | Data collection      |
| Integration Tests | `CI-CD-Testing`      | Automated testing    |

## Emergency Procedures

### Compromised Key Response

If an API key is compromised:

1. **Immediately revoke** the compromised key
2. **Create a new key** with different name
3. **Update all applications** using the old key
4. **Review logs** for unauthorized usage
5. **Report the incident** if further assistance is required

<Warning>
  Always update your applications with new API keys before revoking old ones to prevent service interruptions.
</Warning>
