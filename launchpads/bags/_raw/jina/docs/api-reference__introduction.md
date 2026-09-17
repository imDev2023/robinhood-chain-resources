> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# API Reference

> Complete documentation for all Bags API endpoints

## Welcome

The Bags API provides comprehensive functionality for managing API keys and launching tokens on the Solana blockchain. This reference documents all available endpoints with detailed examples.

## Base URL

All API endpoints use the following base URL:

```
https://public-api-v2.bags.fm/api/v1/
```

## Authentication

The Bags API uses API key authentication. Include your API key in the `x-api-key` header:

```bash theme={null}
curl -H "x-api-key: YOUR_API_KEY" \
  https://public-api-v2.bags.fm/api/v1/endpoint
```

**Required for all endpoints except public analytics endpoints.**

Get your API key from the [Bags Developer Dashboard](https://dev.bags.fm).

## Public Key Format

Throughout this documentation, when we refer to "public key" we always mean **Base58 encoded public keys**. This is the standard format used by Solana for representing wallet addresses, token mints, and other on-chain accounts.

## Response Format

All API responses follow a consistent format:

**Success Response:**

```json theme={null}
{
  "success": true,
  "response": {
    // Response data here
  }
}
```

**Error Response:**

```json theme={null}
{
  "success": false,
  "error": "Error message description"
}
```

## Available Endpoints

The API provides the following functionality:

* **Token Launch**: Create and manage token launches with metadata and initial purchases
* **Fee Sharing**: Configure custom fee sharing between wallets
* **Analytics**: Retrieve token lifetime fees and creator information
* **Fee Claiming**: Generate transactions to claim fees from various sources

All endpoints are documented below with request/response schemas, parameters, and examples.
