# Flap - Gift Vault

> Source: https://docs.flap.sh/flap/developers/vault-developers/gift-vault
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/vault-developers/gift-vault.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/vault-developers/gift-vault.md).

# Gift Vault

## Overview

The **Gift Vault** lets you assign an X (Twitter) account as the **Gift Owner** for a token. The gift owner can prove control of that X account and direct the vault's fee flow to any EVM address of their choice - and change that address anytime by presenting a new proof.

You can use it as a way to give tax fee to an X user, or build more interesting use cases on top of it. It makes it easier for a web2 developer or an agent to manage tax fee routing through social proof. Some ideas:

* Create an X account for an agent and launch a tax token that assigns the agent as the gift owner. The agent routes the tax fee to any EVM address, accepting funding requests via tweets. This could work as charity funds or a VC that supports new projects.
* A social game where players tweet to a game X account and get the tax fee routed to their address based on social tasks or achievements.

This page documents the **current Gift Vault V2** product line, which is what new integrations should target. The legacy **Gift Vault V1 (FlapXVault)** is documented in the [Appendix: Gift Vault V1 (legacy)](#appendix-gift-vault-v1-legacy) at the end of this page - the API integration is identical between versions, so if you already support V1 you mainly need to read the "What's different in V2" section.

## Lifecycle

Gift Vault V2 has three states:

### 1. `ACCUMULATING`

* Initial state after deployment.
* Vault accepts native BNB fees from the token.
* Funds stay inside the vault while waiting for a valid X proof to assign the streaming recipient.

### 2. `STREAMING`

* Entered after a valid `manageByProof()` call.
* All accumulated BNB is flushed immediately to `streamingTarget`.
* Future BNB is forwarded to the same target on receipt.
* The target can be updated again by a newer valid proof.

### 3. `DIVIDEND`

* Entered after `createdAt + timeoutPeriod` if streaming was never activated. Default timeout is **7 days**, configurable at the factory level for future vaults.
* Sticky once entered.
* Vault wraps native BNB into the dividend token (normally WBNB) and deposits the wrapped balance into the token's Dividend contract for holders.

{% hint style="info" %}
This is a change from Gift Vault V1, whose grace-period fallback was buyback & burn instead of holder dividends. See the [Appendix](#appendix-gift-vault-v1-legacy) for the V1 lifecycle.
{% endhint %}

## Network Details

### BNB Smart Chain Mainnet

* `GiftV4VaultFactoryV2`: `0x6909aD1822Ece349CDDAb98E6F62EeeD9fAa2e10`
* `GiftTaxVaultFactoryV2`: `0xFb7ccc4Fd09Da5b7016A18d51e227Af4ABE53f44`

### BNB Smart Chain Testnet

* `GiftV4VaultFactoryV2`: `0xaa00b4CeFeE8b4BF7D2E23C21ae82cfC9AFC9D67`
* `GiftTaxVaultFactoryV2`: `0x2eDD880AB36b07bD030BDa28A13c3E9148C11622`

## Product matrix

Gift Vault V2 has two product options. The difference is mainly the launch constraints of the selected factory.

### `GiftV4VaultFactoryV2`

Use this factory for the zero-tax Gift V4 product.

Launch constraints:

* `tokenVersion == TOKEN_V3_PERMIT`
* `quoteToken == address(0)`
* `buyTaxRate == 0`
* `sellTaxRate == 0`
* `dividendBps == 0`
* `dividendToken == address(0)`

### `GiftTaxVaultFactoryV2`

Use this factory for the taxed Gift product.

Launch constraints:

* `tokenVersion == TOKEN_TAXED_V3`
* `quoteToken == address(0)`
* `buyTaxRate == sellTaxRate`
* `buyTaxRate` / `sellTaxRate` must both be one of: `100` (1%), `200` (2%), `300` (3%)
* `dividendBps == 0`
* `dividendToken == address(0)`

### Shared launch-time vault data

For both Gift Vault V2 product options, the only launch-time vault parameter is the gift owner's X handle.

## API integration guide

Gift Vault V2 uses the **exact same off-chain API** as the legacy Gift Vault V1 - the endpoints, request format, and response format are unchanged. If you already have a working V1 integration, you can reuse it as-is; the only thing that changes for V2 is the factory address and the on-chain launch constraints (product matrix above).

The mechanism, end to end:

1. **Assign Gift Owner** - the X account you specify becomes the gift owner who controls where fees go.
2. **7-Day Grace Period** - if the gift owner doesn't manage the fees at least once within the timeout, control is forfeited to the fallback (holder dividends for V2, buyback & burn for legacy V1).

### Step 1: Parse and validate tweet content

Integrators must fetch the tweet themselves. The tweet format is **strictly enforced**:

**Tweet Format:** `gift the fee from [tax_token_address] to [target_address] #FlapGift`

```typescript
interface ParsedTweet {
  targetAddress: string;
  taxTokenAddress: string;
}

interface Tweet {
  __typename: string;
  text?: string;
  user?: {
    screen_name?: string;
    legacy?: { screen_name?: string };
  };
}

function parseTweetText(text: string): ParsedTweet | null {
  const regex = /gift\s+the\s+fee\s+from\s+(0x[a-fA-F0-9]{40})\s+to\s+(0x[a-fA-F0-9]{40})\s+#FlapGift/i;
  const match = text.match(regex);
  if (!match) return null;
  return { taxTokenAddress: match[1], targetAddress: match[2] };
}

function validateTweetContent(
  tweet: Tweet,
  expectedXHandle: string,
  expectedTaxToken: string
): ParsedTweet {
  if (!tweet || tweet.__typename !== "Tweet") {
    throw new Error("Tweet is not valid (deleted, suspended, or not found)");
  }
  if (!tweet.text) {
    throw new Error("Tweet has no text content");
  }
  if (!tweet.user) {
    throw new Error("Tweet has no user data");
  }

  const tweetScreenName = tweet.user.screen_name || tweet.user.legacy?.screen_name;
  if (!tweetScreenName) {
    throw new Error("Tweet author screen_name not found");
  }
  if (tweetScreenName.toLowerCase() !== expectedXHandle.toLowerCase()) {
    throw new Error(`Tweet author mismatch. Expected: @${expectedXHandle}, Found: @${tweetScreenName}`);
  }

  const parsed = parseTweetText(tweet.text);
  if (!parsed) {
    throw new Error(
      "Tweet text does not match the required format. " +
      "Expected: 'gift the fee from [tax token address] to [EVM address] #FlapGift'"
    );
  }
  if (parsed.taxTokenAddress.toLowerCase() !== expectedTaxToken.toLowerCase()) {
    throw new Error(`Tax token mismatch. Expected: ${expectedTaxToken}, Found: ${parsed.taxTokenAddress}`);
  }

  return parsed;
}
```

### Step 2: ⚠️ MANDATORY PREFLIGHT CHECK

**Always call `canManageVault()` on-chain before submitting to the backend.** The backend is rate-limited to 1 request per minute per IP, and skipping this step risks an IP ban on rejected requests.

```typescript
import { Contract, JsonRpcProvider } from 'ethers';

const VAULT_FACTORY_ABI = [
  {
    "inputs": [
      {"internalType": "address", "name": "taxToken", "type": "address"},
      {"internalType": "string", "name": "xHandle", "type": "string"},
      {"internalType": "uint128", "name": "tweetId", "type": "uint128"}
    ],
    "name": "canManageVault",
    "outputs": [
      {"internalType": "bool", "name": "canManage", "type": "bool"},
      {"internalType": "string", "name": "errorMessage", "type": "string"}
    ],
    "stateMutability": "view",
    "type": "function"
  }
];

async function preflightCheck(
  provider: JsonRpcProvider,
  factoryAddress: string,
  taxToken: string,
  xHandle: string,
  tweetId: string
): Promise<void> {
  const contract = new Contract(factoryAddress, VAULT_FACTORY_ABI, provider);

  // xHandle MUST be lowercase for contract compatibility
  const result = await contract.canManageVault(taxToken, xHandle.toLowerCase(), BigInt(tweetId));
  const [canManage, errorMessage]: [boolean, string] = result;

  if (!canManage) {
    throw new Error(`PREFLIGHT CHECK FAILED: ${errorMessage} - DO NOT call backend API, request will be rejected!`);
  }
}
```

{% hint style="warning" %}

* `xHandle` must be **lowercase** when calling the contract.
* This is a **view function** - no gas required, instant response.
* Returns `[bool canManage, string errorMessage]`.
* **Always check this before calling the backend** to avoid rate-limit violations.
  {% endhint %}

### Step 3: Submit to backend API

**Only call if Step 2 passed.** Rate limit: 1 request per minute per IP; violating may result in an IP ban.

**Endpoint:** `POST {relayerEndpoint}/submit`

```typescript
interface SubmitRequest {
  tax_token: string;
  tweet_id: string;
}

interface SubmitResponse {
  message: string;
  x_proof: {
    target_address: string;
    tax_token: string;
    x_handle: string;
    x_id: string;
    tweet_id: string;
  };
  signature: string;
}

async function submitToBackend(
  relayerEndpoint: string,
  taxToken: string,
  tweetId: string
): Promise<SubmitResponse> {
  const response = await fetch(`${relayerEndpoint}submit`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ tax_token: taxToken, tweet_id: tweetId })
  });

  if (!response.ok) {
    const errorData = await response.json();
    throw new Error(`Backend error: ${errorData.error}`);
  }

  return response.json();
}
```

### Step 4: Poll for on-chain confirmation

The relayer processes transactions asynchronously and does not return a transaction hash - poll `canManageVault` to confirm success. Once processed, `canManageVault` returns `false` with error `"The tweet is outdated"`, which signals success.

```typescript
async function pollForConfirmation(
  provider: JsonRpcProvider,
  factoryAddress: string,
  taxToken: string,
  xHandle: string,
  tweetId: string
): Promise<boolean> {
  const TIMEOUT = 60000;      // 60 seconds
  const POLL_INTERVAL = 15000; // 15 seconds
  const startTime = Date.now();
  const contract = new Contract(factoryAddress, VAULT_FACTORY_ABI, provider);

  return new Promise((resolve, reject) => {
    const interval = setInterval(async () => {
      if (Date.now() - startTime >= TIMEOUT) {
        clearInterval(interval);
        reject(new Error("Polling timeout (60s) - transaction may still be processing"));
        return;
      }

      try {
        const [canManage, errorMessage] = await contract.canManageVault(taxToken, xHandle.toLowerCase(), BigInt(tweetId));
        if (!canManage && errorMessage === "The tweet is outdated") {
          clearInterval(interval);
          resolve(true);
        }
      } catch (error) {
        console.error("Polling error:", error);
      }
    }, POLL_INTERVAL);
  });
}
```

### Manual submission fallback

If the backend relayer times out after 60 seconds, you can submit the proof directly on-chain using the proof data returned from the backend:

```typescript
async function manualSubmit(
  factoryAddress: string,
  taxToken: string,
  proofData: SubmitResponse,
  signer: any
): Promise<void> {
  const MANUAL_SUBMIT_ABI = [
    {
      "inputs": [
        {"name": "taxToken", "type": "address"},
        {
          "name": "proof",
          "type": "tuple",
          "components": [
            {"name": "targetAddress", "type": "address"},
            {"name": "taxToken", "type": "address"},
            {"name": "xHandle", "type": "string"},
            {"name": "XId", "type": "uint256"},
            {"name": "tweetId", "type": "uint128"}
          ]
        },
        {"name": "signature", "type": "bytes"}
      ],
      "name": "manageByProof",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    }
  ];

  const contract = new Contract(factoryAddress, MANUAL_SUBMIT_ABI, signer);
  const tx = await contract.manageByProof(
    taxToken,
    {
      targetAddress: proofData.x_proof.target_address,
      taxToken: proofData.x_proof.tax_token,
      xHandle: proofData.x_proof.x_handle,
      XId: BigInt(proofData.x_proof.x_id),
      tweetId: BigInt(proofData.x_proof.tweet_id)
    },
    proofData.signature
  );
  await tx.wait();
}
```

### `canManageVault()` reference

**Parameters:** `taxToken` (address), `xHandle` (string, must be lowercase), `tweetId` (uint128)

**Returns:** `canManage` (bool), `errorMessage` (string)

**Possible error messages:**

| Error Message                              | Meaning                         |
| ------------------------------------------ | ------------------------------- |
| "GiftVaultV2 not found for this tax token" | No vault exists                 |
| "xHandle does not match"                   | Wrong X handle                  |
| "Vault is already in dividend mode"        | Vault cannot be managed anymore |
| "The tweet is outdated"                    | Tweet already used (success!)   |
| "" (empty string)                          | Can manage (success)            |

### Error handling summary

| Error                               | Cause                  | Solution                             |
| ----------------------------------- | ---------------------- | ------------------------------------ |
| "Tweet is not valid"                | Deleted/suspended      | Use valid, active tweet              |
| "Tweet has no text"                 | Media-only tweet       | Ensure text content                  |
| "Author mismatch"                   | Wrong X handle         | Verify correct user                  |
| "Format mismatch"                   | Incorrect format       | Use exact format                     |
| "Token mismatch"                    | Wrong address          | Verify addresses match               |
| "Vault not found"                   | No vault exists        | Check token has a vault              |
| "xHandle does not match"            | Wrong vault owner      | Use correct X handle                 |
| "Vault is already in dividend mode" | Timed out / locked     | Cannot manage anymore                |
| "Tweet is outdated"                 | Already used (success) | Use new tweet ID for the next update |
| Rate limit error                    | Too many requests      | Wait 60 seconds                      |
| Network timeout                     | Backend slow           | Retry later                          |

{% hint style="danger" %}
**Key points:**

* NEVER skip the preflight check - it prevents IP bans.
* The backend is rate-limited (1/min) - no exceptions.
* `xHandle` must be lowercase for contract calls.
* Polling confirms success - the relayer is asynchronous.
* Consider showing the manual submission option to users after \~30 seconds of polling, while continuing to poll up to 60 seconds in the background.
  {% endhint %}

## Summary checklist

1. Fetch the tweet yourself.
2. Validate tweet content (author, format, tax token match).
3. ⚠️ MANDATORY: call `canManageVault()`. If `false`, **stop** - do not call the backend.
4. Submit to backend (only if preflight passed; rate limited to 1/min).
5. Poll `canManageVault()` every 15s for up to 60s. Success = error `"The tweet is outdated"`.
6. Implement timeouts and the manual submission fallback.

## Appendix: Gift Vault V1 (legacy)

This section documents the original Gift Vault (`FlapXVault`), kept for integrators who still support the legacy factory. **New integrations should use Gift Vault V2** (documented above) - the API integration mechanics above apply unchanged to V1; only the factory address, states, and fallback differ.

### V1 vs V2 summary

| Topic                 | Gift Vault V1                                    | Gift Vault V2                                                           |
| --------------------- | ------------------------------------------------ | ----------------------------------------------------------------------- |
| Product options       | one legacy Gift Vault flow                       | two product options: `GiftV4VaultFactoryV2` and `GiftTaxVaultFactoryV2` |
| API integration       | same API as V2                                   | same API, request format, and response format as V1                     |
| Fee routing lifecycle | `ACCUMULATING -> STREAMING -> FALLBACK_SNOWBALL` | `ACCUMULATING -> STREAMING -> DIVIDEND`                                 |
| Timeout fallback      | buyback & burn                                   | holder dividends                                                        |

### V1 lifecycle

1. **Assign Gift Owner** - the X account you specify becomes the gift owner who controls where fees go.
2. **Flexible Beneficiary** - the gift owner can assign fees to any EVM address and change it anytime.
3. **7-Day Grace Period** - if the gift owner doesn't manage the fees at least once in the first 7 days, control is forfeited.
4. **Fallback: Buyback & Burn** - if control is forfeited, fees are automatically used for buyback and burn.

### V1 Network Details

**BNB Smart Chain Mainnet**

* Gift Vault Factory: `0x025549F52B03cF36f9e1a337c02d3AA7Af66ab32`
* Relayer API Endpoint: `https://bnb-x-relayer.taxed.fun/submit`

**BNB Smart Chain Testnet**

* Gift Vault Factory: `0xa02DA44D67DB6D692efa7f751b5952bd670d5326`
* Relayer API Endpoint: `https://bnbtest-x-relayer.taxed.fun/submit`

### V1 Gift Vault interface (`IFlapXVault`)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title IFlapXVault
/// @notice Interface for the legacy Gift Vault (FlapXVault) implementation.
interface IFlapXVault {
    enum State {
        ACCUMULATING,
        STREAMING,
        FALLBACK_SNOWBALL
    }

    enum BalanceUpdateType {
        ACCUMULATION,
        SNOWBALL
    }

    struct VaultStats {
        uint128 totalBNBSpent;
        uint128 totalTokenBurn;
    }

    struct ProofRecord {
        uint128 XId;
        uint128 tweetId;
        address targetAddress;
    }

    struct XProof {
        address targetAddress;
        address taxToken;
        string xHandle;
        uint128 XId;
        uint128 tweetId;
    }

    event FlapTaxVaultStateChanged(address token, uint8 newState);
    event FlapTaxVaultStreamingTargetUpdated(address token, address newTarget);
    event FlapSnowballBalanceUpdated(address token, address vault, uint256 newBalance, BalanceUpdateType updateType);
    event FlapStreamingForwardFailed(address token, address target, uint256 amount);

    error OutdatedProof(uint128 providedTweetId, uint128 lastTweetId);
    error InvalidState(State currentState);
    error EmptyXHandle();
    error InvalidProof();
    error MismatchedTaxToken();
    error MismatchedXHandle();
    error CannotRevokeGuardianRole();

    function SNOWBALL_ROLE() external view returns (bytes32);
    function DEAD_ADDRESS() external view returns (address);

    function initialize(address _taxToken, address _quoteToken, string calldata _xHandle, uint256 _timeoutPeriod)
        external;

    function state() external view returns (State);
    function transitState() external;
    function manageByProof(XProof calldata proof, bytes calldata signature) external;
    function snowball(uint256 quoteAmt) external;

    function getHistoricalProofs(uint256 offset, uint256 limit)
        external
        view
        returns (ProofRecord[] memory records, uint256 total);

    function description() external view returns (string memory);
    function revokeRole(bytes32 role, address account) external;
    function stats() external view returns (uint128 totalBNBSpent, uint128 totalTokenBurn);
    function taxToken() external view returns (address);
    function quoteToken() external view returns (address);
    function xHandle() external view returns (string memory);
    function timeoutPeriod() external view returns (uint256);
    function createdAt() external view returns (uint256);
    function factory() external view returns (address);
    function streamingTarget() external view returns (address);
    function streamedAmount(address beneficiary) external view returns (uint256);
    function lastTweetId() external view returns (uint128);
}
```
