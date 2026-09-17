> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Create a Launch Intent URL

> Build shareable launch intent URLs that pre-fill the Bags /launch form and embed them as buttons on any webpage

A **launch intent** is a shareable URL that pre-fills the `/launch` form on Bags. You build the URL once (with a token name, ticker, description, image, fee sharing, partner overrides, and more), share it anywhere, and the recipient lands on the launch form with everything filled in. They review and click launch.

In this guide you'll learn how to build a launch intent URL from scratch, how to embed it as a button on your own webpage, and how to attach your partner key so every launch routed through your link earns you a share of the trading fees.

## How it works

When a user opens a launch intent URL, the Bags `/launch` page:

1. Parses every supported query param.
2. Hydrates the form fields, toggles (fee sharing, tokenize equity), the admin wallet, partner overrides, and optionally fetches the image URL into the upload slot.
3. Replaces the URL with `/launch` so the share link stays reusable and the user sees a clean URL.
4. Shows a toast confirming the prefill (plus a separate warning toast if any individual field failed validation).

The trigger param `intent=true` is the **only required** value. Any other param is optional, and the page ignores all params if `intent=true` is missing.

```
https://bags.fm/launch?intent=true&name=MyCoin&ticker=MC&description=...
```

## Prerequisites

No API key is required to build a launch intent URL — it is purely client-side.

<Note>
  **Optional — earn fees from launches via your link.** If you create a partner key and include it as the `partner` and `partnerConfig` params, every launch routed through your intent URL will credit the partner share to your key. See [Create a Partner Key](/how-to-guides/create-partner-key) before continuing if you want this behaviour.
</Note>

## Encoding rules

* Each param value must be passed through `encodeURIComponent`. Using `URLSearchParams` or `URL.searchParams.set` handles this for you automatically.
* For complex values (arrays and objects), serialize them with `JSON.stringify` first, then set them on the search params.
* All basis-point values use the convention `2500 = 25%`, `10000 = 100%`. The sum of `allocationBps` across all `feeShare` entries must be `<= 10000`.

Minimal pattern:

```ts theme={null}
const url = new URL("https://bags.fm/launch");
url.searchParams.set("intent", "true");
url.searchParams.set("name", "My Coin");
url.searchParams.set(
  "feeShare",
  JSON.stringify([
    { allocationBps: 5000, platform: "twitter", username: "bagsapp" },
  ])
);

const shareUrl = url.toString();
```

## Supported parameters

### Basic text fields

* `name` — token name, max 32 characters.
* `ticker` — alphanumeric, max 10 characters. Auto-uppercased by the form.
* `description` — free-form token description.
* `website` — any valid URL. Automatically expands the "Social links" section on the form.
* `twitter` — `https://twitter.com/...` or `https://x.com/...` URL. Also auto-expands social links.

### Image

* `image` — absolute `http://` or `https://` URL to an image.
  * The page fetches the URL client-side, so the host must allow CORS. If CORS fails the user sees a "Could not load image from link" toast and must upload the image manually.
  * The response `Content-Type` header is used as the file mime type. A non-image mime is rejected.
  * The filename is derived from the URL pathname, falling back to `intent-image.<ext>`.

### Initial buy

* `initialBuy` — numeric string representing a USD amount, for example `"100"`. Negative or non-finite values are silently ignored.

### Fee mode

* `feeMode` — one of the following `METEORA_CONFIG_TYPE` keys:
  * `DEFAULT` — Founder Mode, 1% of trading volume.
  * `BPS100PRE_BPS25POST_5000_COMPOUNDING` — \~0% mode.
  * `BPS1000PRE_BPS1000POST` — Paper Hand Tax mode.
  * `BPS25PRE_BPS100POST_5000_COMPOUNDING` — advanced.
  * `BPS1000PRE_BPS1000POST_5000_COMPOUNDING` — advanced.
* Unknown keys are ignored and produce a warning toast.

<Note>
  Some fee modes disable fee sharing in the UI (for example `BPS100PRE_BPS25POST_5000_COMPOUNDING`). If you set both `feeMode` and fee-sharing params, the mode wins: `feeShareEnabled`, `feeShareType`, and `feeShare` are dropped at parse time and a warning toast is shown.
</Note>

### Fee sharing

* `feeShareEnabled` — `"true"` toggles the fee-sharing section on. Also auto-enabled when a non-empty `feeShare` array is provided.
* `feeShareType` — `"multi"` (default) or `"csv"`. Controls which tab is shown.
* `feeShare` — JSON array. Each entry has this shape:

```json theme={null}
{
  "allocationBps": 2500,
  "platform": "twitter",
  "username": "bagsapp"
}
```

Rules:

* `allocationBps`: positive integer, basis points (`2500 = 25%`). The sum across all entries must be `<= 10000`. The floor of each value is applied.
* `platform`: one of the enabled platforms: `twitter`, `tiktok`, `github`, `moltbook`, `solana`, `kick`. Disabled platforms (`instagram`, `twitch`, `onlyfans`) are rejected.
* `username`: non-empty string. When `platform` is `"solana"`, this must be a base58 Solana public key.
* At most 100 entries. Extras are truncated with a warning.

### Admin wallet

* `admin` — base58 Solana public key. Sets the admin wallet when fee sharing is enabled.
  * Invalid pubkeys are ignored with a warning.
  * The admin field is only editable in the UI when fee sharing is on, but the intent still applies the value.

### Tokenize equity

* `tokenizeEquity` — `"true"` toggles the tokenize-equity section on. Auto-enabled if `equity` is provided.
* `equity` — JSON object. Full shape:

```json theme={null}
{
  "projectName": "Acme Corp",
  "bedrockShareBasisPoint": 2500,
  "category": "DEFI",
  "twitterHandle": "acme",
  "preferredCompanyNames": ["Acme Inc", "Acme Labs Inc", "Acme Holdings Inc"],
  "founders": [
    {
      "firstName": "Alice",
      "lastName": "Anderson",
      "email": "alice@acme.co",
      "nationalityCountry": "USA",
      "taxResidencyCountry": "USA",
      "residentialAddress": "123 Main St, NY",
      "shareBasisPoint": 7500
    }
  ]
}
```

Field notes:

* `projectName`: string, required by the form at submit time.
* `bedrockShareBasisPoint`: integer bps. Defaults to `2500` (25%) if missing. The sum of all `founders[].shareBasisPoint` plus `bedrockShareBasisPoint` must equal exactly `10000` at submit time.
* `category`: one of `RWA`, `AI`, `DEFI`, `INFRA`, `DEPIN`, `LEGAL`, `GAMING`, `NFT`, `MEME`, or the empty string `""`. Unknown values are dropped with a warning.
* `twitterHandle`: 1–15 alphanumeric/underscore characters, no `@` prefix. Validated at submit time.
* `preferredCompanyNames`: array of exactly 3 unique strings (the form enforces uniqueness at submit time).
* `founders`: array of founder objects. All string fields default to empty, `shareBasisPoint` defaults to `0`.

### Partner override

These two params are not editable in the UI. They override the ref-code partner lookup that would otherwise come from the browser cookie.

* `partner` — base58 Solana public key.
* `partnerConfig` — base58 Solana public key.

Both values are passed directly to the launch transaction at submit time. Invalid pubkeys are ignored with a warning.

<Note>
  **These keys are a matched on-chain pair.** If you supply one, you must supply the other — the launch uses the override pair exclusively and will not fall back to the ref-code pair for the missing half. Always emit both together, or omit both. See [Create a Partner Key](/how-to-guides/create-partner-key) for how to obtain these values.
</Note>

### UI state

* `showSocial` — `"true"` pre-expands the "Social links (optional)" collapsible. Automatically `true` when `website` or `twitter` is present.

### Boolean values

Any param documented as boolean accepts:

* `"true"` or `"1"` → true
* `"false"` or `"0"` → false
* missing → undefined (no change to the default)

## Error handling

The launch page never fails the whole intent for a single bad field. Instead, it ignores the offending value and surfaces a warning:

* Invalid JSON for `feeShare` or `equity` → the param is ignored, the rest of the intent still applies, warning toast.
* Invalid Solana pubkey (`admin`, `partner`, `partnerConfig`) → ignored, warning toast.
* Unknown `feeMode` key → ignored, warning toast.
* Image fetch failure (CORS, 404, non-image mime) → error toast, user must upload manually.

If any warnings occur, a consolidated "Some intent fields were ignored" toast is shown with a `(+N more)` counter, and every warning is also logged to `console.warn`. Since nothing is validated server-side, your builder UI should enforce the same rules before producing the link.

## Build an intent URL in TypeScript

Here is a reusable helper that serializes a typed input into a launch intent URL. Drop it into your builder UI or a server that returns share links:

```ts theme={null}
type FeeSharePlatform =
  | "twitter"
  | "tiktok"
  | "github"
  | "moltbook"
  | "solana"
  | "kick";

interface FeeShareEntry {
  allocationBps: number;
  platform: FeeSharePlatform;
  username: string;
}

interface BedrockFounder {
  firstName: string;
  lastName: string;
  email: string;
  nationalityCountry: string;
  taxResidencyCountry: string;
  residentialAddress: string;
  shareBasisPoint: number;
}

interface EquityIntent {
  projectName: string;
  bedrockShareBasisPoint?: number;
  category?:
    | "RWA"
    | "AI"
    | "DEFI"
    | "INFRA"
    | "DEPIN"
    | "LEGAL"
    | "GAMING"
    | "NFT"
    | "MEME"
    | "";
  twitterHandle?: string;
  preferredCompanyNames?: [string, string, string];
  founders?: BedrockFounder[];
}

interface LaunchIntent {
  name?: string;
  ticker?: string;
  description?: string;
  website?: string;
  twitter?: string;
  image?: string;
  initialBuy?: string | number;
  feeMode?:
    | "DEFAULT"
    | "BPS100PRE_BPS25POST_5000_COMPOUNDING"
    | "BPS1000PRE_BPS1000POST"
    | "BPS25PRE_BPS100POST_5000_COMPOUNDING"
    | "BPS1000PRE_BPS1000POST_5000_COMPOUNDING";
  feeShareEnabled?: boolean;
  feeShareType?: "multi" | "csv";
  feeShare?: FeeShareEntry[];
  admin?: string;
  tokenizeEquity?: boolean;
  equity?: EquityIntent;
  partner?: string;
  partnerConfig?: string;
  showSocial?: boolean;
}

export function buildLaunchIntentUrl(
  intent: LaunchIntent,
  origin = "https://bags.fm"
): string {
  const url = new URL("/launch", origin);
  const params = url.searchParams;
  params.set("intent", "true");

  const setIf = (key: string, value: string | number | undefined) => {
    if (value === undefined || value === null || value === "") return;
    params.set(key, String(value));
  };
  const setBool = (key: string, value: boolean | undefined) => {
    if (value === undefined) return;
    params.set(key, value ? "true" : "false");
  };
  const setJson = (key: string, value: unknown) => {
    if (value === undefined) return;
    params.set(key, JSON.stringify(value));
  };

  setIf("name", intent.name);
  setIf("ticker", intent.ticker);
  setIf("description", intent.description);
  setIf("website", intent.website);
  setIf("twitter", intent.twitter);
  setIf("image", intent.image);
  setIf("initialBuy", intent.initialBuy);
  setIf("feeMode", intent.feeMode);

  setBool("feeShareEnabled", intent.feeShareEnabled);
  setIf("feeShareType", intent.feeShareType);
  if (intent.feeShare && intent.feeShare.length > 0) {
    setJson("feeShare", intent.feeShare);
  }

  setIf("admin", intent.admin);

  setBool("tokenizeEquity", intent.tokenizeEquity);
  if (intent.equity) {
    setJson("equity", intent.equity);
  }

  if (intent.partner && intent.partnerConfig) {
    params.set("partner", intent.partner);
    params.set("partnerConfig", intent.partnerConfig);
  }

  setBool("showSocial", intent.showSocial);

  return url.toString();
}
```

Use it:

```ts theme={null}
const shareUrl = buildLaunchIntentUrl({
  name: "BagsCoin",
  ticker: "BAGS",
  description: "The launchpad token.",
  website: "https://bags.fm",
  twitter: "https://twitter.com/bagsapp",
  image: "https://cdn.example.com/bags-logo.png",
  initialBuy: 250,
  feeMode: "DEFAULT",
  feeShareEnabled: true,
  feeShareType: "multi",
  feeShare: [
    { allocationBps: 5000, platform: "twitter", username: "bagsapp" },
    {
      allocationBps: 2500,
      platform: "solana",
      username: "So11111111111111111111111111111111111111112",
    },
  ],
  admin: "BAGSB9TpGrZxQbEsrEznv5jXXdwyP6AXerN8aVRiAmcv",
  partner: "YourPartnerWalletPubkeyHere",
  partnerConfig: "YourPartnerConfigPdaHere",
});

console.log(shareUrl);
```

<Note>
  Always emit `partner` and `partnerConfig` together. The helper above enforces this by only setting them when both are present.
</Note>

## Embed a launch button on your webpage

Once you have a share URL, dropping a "Launch on Bags" button onto any webpage is straightforward. Pick whichever flavour matches your stack.

### Plain HTML

If your intent is static (for example, a marketing page for a single token you want to promote), paste the URL into an anchor styled as a button:

```html theme={null}
<a
  href="https://bags.fm/launch?intent=true&name=BagsCoin&ticker=BAGS&partner=...&partnerConfig=..."
  target="_blank"
  rel="noopener noreferrer"
  style="
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 12px 20px;
    border-radius: 9999px;
    background: #02FF40;
    color: #000;
    font-weight: 600;
    text-decoration: none;
    font-family: system-ui, sans-serif;
  "
>
  Launch on Bags
</a>
```

### Vanilla JavaScript

If the intent depends on page state (for example, a form the user is filling in), build the URL at click time:

```html theme={null}
<button id="launch-on-bags" type="button">Launch on Bags</button>

<script type="module">
  function buildLaunchIntentUrl(intent, origin = "https://bags.fm") {
    const url = new URL("/launch", origin);
    url.searchParams.set("intent", "true");
    if (intent.name) url.searchParams.set("name", intent.name);
    if (intent.ticker) url.searchParams.set("ticker", intent.ticker);
    if (intent.description)
      url.searchParams.set("description", intent.description);
    if (intent.image) url.searchParams.set("image", intent.image);
    if (intent.feeShare?.length)
      url.searchParams.set("feeShare", JSON.stringify(intent.feeShare));
    if (intent.partner && intent.partnerConfig) {
      url.searchParams.set("partner", intent.partner);
      url.searchParams.set("partnerConfig", intent.partnerConfig);
    }
    return url.toString();
  }

  document.getElementById("launch-on-bags").addEventListener("click", () => {
    const url = buildLaunchIntentUrl({
      name: "BagsCoin",
      ticker: "BAGS",
      description: "The launchpad token.",
      image: "https://cdn.example.com/bags-logo.png",
      feeShare: [
        { allocationBps: 2500, platform: "twitter", username: "bagsapp" },
      ],
      partner: "YourPartnerWalletPubkeyHere",
      partnerConfig: "YourPartnerConfigPdaHere",
    });

    window.open(url, "_blank", "noopener,noreferrer");
  });
</script>
```

### React component

If you're already on React, wrap the builder in a component:

```tsx theme={null}
import { buildLaunchIntentUrl, type LaunchIntent } from "./launch-intent";

interface LaunchIntentButtonProps {
  intent: LaunchIntent;
  label?: string;
  className?: string;
}

export function LaunchIntentButton({
  intent,
  label = "Launch on Bags",
  className,
}: LaunchIntentButtonProps) {
  const href = buildLaunchIntentUrl(intent);

  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      className={
        className ??
        "inline-flex items-center gap-2 rounded-full bg-[#02FF40] px-5 py-3 font-semibold text-black transition hover:brightness-110"
      }
    >
      {label}
    </a>
  );
}
```

Usage:

```tsx theme={null}
<LaunchIntentButton
  intent={{
    name: "BagsCoin",
    ticker: "BAGS",
    image: "https://cdn.example.com/bags-logo.png",
    partner: process.env.NEXT_PUBLIC_BAGS_PARTNER,
    partnerConfig: process.env.NEXT_PUBLIC_BAGS_PARTNER_CONFIG,
  }}
/>
```

<Note>
  The `image` param must be a **public URL**. Local `File` uploads from a file input cannot be encoded into a URL — if you need a custom image, upload it to your CDN first and pass the resulting URL.
</Note>

## Earn fees from launches via your link

Attaching your partner key turns every share into a revenue stream: when a user completes a launch through your intent URL, the partner share of trading fees is routed to your key instead of to the ref-code partner that would otherwise be looked up from the cookie.

To enable this:

1. Create a partner key by following [Create a Partner Key](/how-to-guides/create-partner-key). You end up with:
   * a **partner wallet pubkey** (your wallet) → becomes the `partner` param
   * a **partner config PDA** → becomes the `partnerConfig` param
2. Pass both values to `buildLaunchIntentUrl` (or whichever builder you use).
3. Periodically claim the accumulated fees — see [Claim Partner Fees](/how-to-guides/claim-partner-fees).

<Note>
  The `partner` and `partnerConfig` values are a matched on-chain pair. If you set one without the other, the launch page ignores both and shows a warning toast. Always include the pair together.
</Note>

## Notes and caveats

* **No server-side validation.** The launch page parses params on the client only. Your builder UI should enforce the same rules (bps sum ≤ 10000, valid Solana pubkeys, image URL reachable, exactly 3 unique `preferredCompanyNames`, etc.) before producing the link so the recipient never sees warning toasts.
* **The URL is cleaned after hydration.** Once the form is populated, the recipient's browser replaces the URL with `/launch`. Do not rely on hashes or anchors persisting.
* **Image files cannot be encoded.** A `File` object from an `<input type="file">` cannot be put into a URL. Upload the image to a CDN first and pass the resulting public URL as the `image` param.
* **Keep links short.** Only emit params that differ from the form defaults. For example, skip `feeMode=DEFAULT` and skip `showSocial` when `website` or `twitter` is already present (both auto-expand the social links section).
* **Keep your partner pair together.** Emitting `partner` without `partnerConfig` (or vice versa) drops both values at parse time.
