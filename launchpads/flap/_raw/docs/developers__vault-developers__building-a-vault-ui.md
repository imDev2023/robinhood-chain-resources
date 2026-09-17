> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/vault-developers/building-a-vault-ui.md).

# Building a Vault UI

This page covers how to build a **custom UI** for your Vault using the [flap-vault-component-template](https://github.com/flap-sh/flap-vault-component-template). If you don't need a bespoke UI, Flap can render a generic interaction page automatically from your `vaultUISchema()` / `vaultDataSchema()` (see the [Vault & VaultFactory Specification](/flap/developers/vault-developers/vault-and-vaultfactory-specification.md)). Use this guide when you want full control over layout, copy, and business logic instead.

{% hint style="info" %}
This is Step 7 in the [Quick start for Vault Developers](/flap/developers/vault-developers/quick-start-vault-developers.md): build the bespoke UI **after** your Vault contract is written, tested, and (per your audit plan) submitted for review.
{% endhint %}

## Table of Contents

* [What the template is (and isn't)](#what-the-template-is-and-isnt)
* [The four-file package boundary](#the-four-file-package-boundary)
* [Quick start](#quick-start)
* [Scaffold your Vault package](#scaffold-your-vault-package)
* [manifest.json — declaring your binding](#manifestjson--declaring-your-binding)
* [The Flap SDK — what your component may call](#the-flap-sdk--what-your-component-may-call)
* [Mandatory: render the current risk status](#mandatory-render-the-current-risk-status)
* [Market-phase and wrong-network gating](#market-phase-and-wrong-network-gating)
* [A minimal Component.tsx walkthrough](#a-minimal-componenttsx-walkthrough)
* [Safety rules you must not violate](#safety-rules-you-must-not-violate)
* [Check, preview, and package](#check-preview-and-package)
* [Handoff to Flap Artifact Workbench](#handoff-to-flap-artifact-workbench)

## What the template is (and isn't)

`flap-vault-component-template` is **not** a free-form website container. A custom Vault UI is a controlled business component that runs inside Flap's runtime boundary:

* **Flap SDK** for chain reads/writes, wallet, oracle, i18n, notifications, formatting, and tx-error handling.
* **Flap-owned host context** (taxinfo/feeinfo) for token state, tax info, VaultPortal info, deployment binding, fee mode, and market phase — you consume this, you don't reimplement it.
* **Flap preview shell** with real wallet connect, chain switching, and language preference, so you can test against real chain data locally.
* **Packaged Vault artifacts** that contain only your Vault-specific business UI. The shell/header/frame around it is never part of your package.
* **A minimal manifest** declaring your deployment binding (chain + factory/vault/token), i18n locales, and any unavoidable non-oracle endpoints — nothing else.

The production flow, end to end:

```
private zip
  -> Flap Artifact Workbench validation
  -> Flap build
  -> component.mjs + manifest + i18n + metadata
  -> Flap static artifact storage
  -> Flap deployment binding
  -> flap.sh runtime loader
```

Your zip is never loaded by `flap.sh` directly — Flap builds the actual runtime artifact from it after validation.

## The four-file package boundary

Every Vault UI package lives at `src/vaults/{folder-name}/` and contains **exactly** these four files:

```
src/vaults/{folder-name}/
  Component.tsx     # the controlled React Vault UI component
  manifest.json      # artifactId, match.bindings, i18n
  VaultABI.ts        # minimal non-standard ABI fragments only
  i18n.json          # locale dictionaries for manifest.i18n
```

No `helpers/`, no nested components, no local asset files, no README, no extra docs. Any other file or subfolder is a blocking `vault:check` issue. The only exception is Mini App mode (`manifest.mode: "mini-app"`, for `8888`-suffix token-scoped artifacts only), which may also include reviewed top-level audio files (`.mp3`/`.wav`/`.ogg`/`.m4a`/`.aac`, ≤5 MiB each, ≤12 MiB total).

Folder naming is strict lowercase kebab-case: 3–64 characters, letters/numbers separated by single hyphens (e.g. `flap-nft-vault`). No spaces, underscores, uppercase, leading/trailing hyphens, or nested folders — the folder name is both your source directory and your local preview route (`/{folder-name}`).

## Quick start

```bash
git clone https://github.com/flap-sh/flap-vault-component-template
cd flap-vault-component-template
yarn
yarn dev
```

The template runs with no local `.env` file — it ships with a shared preview WalletConnect Project ID, BNB mainnet/testnet RPC fallbacks, and a host-presentation proxy target already wired up. Open the built-in examples:

```
http://localhost:3000/example                     # reward/oracle pattern: approve, simulate, write, claim, refetch
http://localhost:3000/dex-listed-example           # listed-only stage gate example
http://localhost:3000/action-gallery-example       # richer multi-state action button gallery
http://localhost:3000/community-buyback-example    # live example bound to a real BNB token/factory
http://localhost:3000/flapixel-example             # live NFT vault example
```

If you're unsure which example to start from, use `example` — it carries the default compact visual baseline that `vault:check` expects new Vault UIs to follow (a row-heavy dashboard with stacked metric cards is blocked by default).

## Scaffold your Vault package

Don't hand-create the four files — use `vault:scaffold`. Recommended for a factory-scoped mainnet launch:

```bash
yarn vault:scaffold my-vault --name "My Vault UI" \
  --chain 97 --factory 0xTestnetFactory --token 0xReal7777TestToken \
  --chain 56 --factory 0xMainnetFactory --locales en,zh
```

For a single Vault with no factory:

```bash
yarn vault:scaffold my-vault --name "My Vault UI" \
  --chain 56 --vault 0xVaultAddressRequired --token 0xReal7777TestToken --locales en,zh
```

This generates the strict four-file package, a stable `artifactId` (`vaultui_my-vault_<ULID>`), and registers `my-vault` in `src/vaults/index.ts` so `/my-vault` renders locally. Replace every placeholder address with a real deployed address before running the command — `vault:check` blocks zero addresses and reserved template placeholders.

If the four files already exist (e.g. an AI agent generated them from a manifest first), just register the local preview route:

```bash
yarn vault:register my-vault
```

## manifest.json — declaring your binding

`manifest.json` is intentionally small — it's a match/review declaration, not a place to configure runtime behavior. Minimal factory-scoped example:

```json
{
  "artifactId": "vaultui_my-vault_01HZY7J4S9D0W5XJ8H2Q3K4M5N",
  "name": "My Vault UI",
  "match": {
    "bindings": [
      {
        "chainId": 97,
        "factoryAddress": "0xTestnetFactoryRequired",
        "tokenAddresses": ["0xReal7777TestToken"]
      },
      { "chainId": 56, "factoryAddress": "0xMainnetFactoryRequired" }
    ]
  },
  "i18n": ["en", "zh"]
}
```

There are exactly three supported match modes, and you never bind by a "type" field:

| Mode                      | Shape                                                                        |
| ------------------------- | ---------------------------------------------------------------------------- |
| Factory-scoped            | `chainId` + non-zero `factoryAddress`                                        |
| Vault-scoped (no factory) | `chainId` + exactly one `vaultAddresses` entry (+ optional `tokenAddresses`) |
| Token-scoped (no factory) | `chainId` + one or more `tokenAddresses`                                     |

Every binding-scoped `tokenAddresses` entry — including proof tokens on factory bindings — must be a **real deployed** ERC20 token address ending in `7777` or `8888`. At least one binding in the manifest must include one of these, since it's what `vault:check`/E2E test against. In factory mode, `tokenAddresses` is package proof, **not** the production CA restriction — that's a Workbench/registry `caRestrictionMode` decision (`none` / `reserved` / `verified`), never a manifest field.

Do **not** declare in `manifest.json`: `id`, `owner`, `version`, `actions`, `oracles`, `media`, `fallback`, `contracts`, `chainIds`, or global `tokenAddresses`. Actions live in `Component.tsx` via SDK calls; oracle usage is auto-detected by `vault:check`, not declared.

Optional per-binding field: `externalContracts` — for a truly fixed contract address that isn't your runtime token/vault/factory:

```json
{
  "chainId": 56,
  "factoryAddress": "0xFactoryAddressRequired",
  "externalContracts": [
    { "address": "0xExternalContractIfNeeded", "label": "Reward distributor" }
  ]
}
```

See [`docs/manifest.md`](https://github.com/flap-sh/flap-vault-component-template/blob/main/docs/manifest.md) in the template repo for the full schema, including Mini App and fullscreen-layout variants.

## The Flap SDK — what your component may call

Import everything from the public aliases — never introduce another SDK-like wrapper:

```ts
import { useFlapSdk, useVaultContext, useFlapI18n, useFlapNotify, useFlapWallet } from "@/src/sdk";
import { Button, Card, CardHeader, CardTitle, CardContent, Metric, StatusBadge, Alert, TxButton } from "@/src/ui";
```

Common SDK methods:

```ts
sdk.readContract<T>(request)
sdk.simulateContract(request)
sdk.writeContract(request)
sdk.waitForTx(hash)
sdk.readOracle<T>(oracleId, params)
sdk.refetch(keys)
sdk.openExplorerTx(hash)
```

Contract calls should target `context.vaultAddress`, `context.tokenAddress`, `context.factoryAddress`, or a binding-scoped `tokenAddresses`/`vaultAddresses`/`externalContracts` entry — never a hardcoded address, and never an unrelated router/bridge/aggregator contract. `vault:check` blocks calls to undeclared fixed addresses.

For methods with multiple return values, type the read as a tuple array — not an object — even if the ABI names the outputs:

```ts
// function poolInfo() view returns (uint256 currentPool, uint256 totalReceived)
type PoolInfoTuple = readonly [currentPool: bigint, totalReceived: bigint];
```

Use the SDK's standard ERC20 ABI for normal token flows instead of copying it into `VaultABI.ts`:

```ts
import { erc20Abi, standardErc20Abi } from "@/src/sdk";
```

Only add fragments to `VaultABI.ts` for your Vault's own non-standard methods.

## Mandatory: render the current risk status

**Every default Vault UI must visibly render the current contract risk status.** This is a hard, checker-enforced requirement (the only exception is Mini App mode on `8888`-suffix tokens).

```ts
import { readTaxVaultHostContext, useFlapSdk } from "@/src/sdk";

const { context } = useFlapSdk();
const host = readTaxVaultHostContext(context.host);
const riskLevel = host.vaultInfo?.riskLevel ?? host.taxInfo?.vaultInfo?.riskLevel ?? null;
```

Rules:

* The risk status must appear within the **first three visible Vault-specific business rows/blocks**, and **before** any hero, banner, preview, chart, or large visual block. The safest placement is the first `CardHeader` badge row.
* If `riskLevel` is unavailable, render a prominent warning that risk-status integration is required — don't silently omit it. `vault:check` treats a missing risk-status integration as a blocking issue.
* Never hardcode or unconditionally render a "Low risk" badge or reassuring copy. A low-risk label may only appear when it's selected from the host-derived `riskLevel === 1` branch.

## Market-phase and wrong-network gating

Every action-bearing Vault must decide whether each button is available in `internal-market`, `dex-listed`, `both`, or `read-only` stage, and gate it at runtime:

```ts
import { isActionAvailableForPhase, readTaxVaultHostContext, useFlapSdk } from "@/src/sdk";

const { context, wallet } = useFlapSdk();
const host = readTaxVaultHostContext(context.host);
const actionsAvailable = isActionAvailableForPhase("both", host.marketPhase);
```

Show unavailable actions with a clear disabled state — don't hide them silently. Wrong-network handling is a separate, orthogonal concern:

```ts
if (sdk.wallet.isWrongNetwork) {
  await sdk.wallet.switchChain();
}
```

Keep write buttons visible but disabled when `sdk.wallet.isWrongNetwork` is true, and prompt a chain switch before sending any transaction.

## A minimal Component.tsx walkthrough

The built-in `example` package (`src/vaults/example/Component.tsx`) is the canonical reference: a reward vault with deposit/approve/claim actions, live oracle data, and full risk/phase gating. Its shape, condensed:

```tsx
"use client";

import { erc20Abi, formatTokenAmount, handleTxError, isActionAvailableForPhase, parseTokenAmount, readTaxVaultHostContext, useFlapSdk } from "@/src/sdk";
import { exampleVaultAbi } from "./VaultABI";
import { Alert, Button, Card, CardContent, CardHeader, CardTitle, Metric, StatusBadge, TxButton } from "@/src/ui";

export default function ExampleRewardVault() {
  const sdk = useFlapSdk();
  const { context, i18n } = sdk;
  const t = i18n.t;

  const host = readTaxVaultHostContext(context.host);
  const riskLevel = host.vaultInfo?.riskLevel ?? host.taxInfo?.vaultInfo?.riskLevel ?? null;
  const actionsAvailable = isActionAvailableForPhase("both", host.marketPhase);

  // ...read vaultInfo / myInfo / balance / allowance via sdk.readContract,
  // gate writes with actionsAvailable + sdk.wallet.isWrongNetwork,
  // route deposit() through approve() first when allowance is insufficient.

  return (
    <div className="w-full space-y-3">
      <Card>
        <CardHeader>
          <CardTitle>{t("title")}</CardTitle>
          {/* Risk badge must appear here — first CardHeader row, before any hero/preview */}
          <StatusBadge tone={riskLevel === 1 ? "success" : "warning"}>
            {riskLevel === 1 ? t("states.riskLow") : t("states.riskMissing")}
          </StatusBadge>
        </CardHeader>
        <CardContent>
          <Metric label={t("labels.totalDeposited")} value={formatTokenAmount(/* ... */)} />
          {/* deposit / approve / claim TxButton flow, gated by actionsAvailable + isWrongNetwork */}
        </CardContent>
      </Card>
    </div>
  );
}
```

Key habits this example demonstrates:

* Reads run on mount and on a polling interval; writes call `sdk.refetch()` (or reload data directly) after `sdk.waitForTx(...)` resolves.
* `needsApproval` is computed by comparing live `allowance` to the parsed input amount, and the deposit button transparently routes through `approve()` first when needed.
* Every user-facing string comes from `i18n.t(...)` — never hardcoded text — since `i18n.json` is validated against every locale declared in `manifest.i18n`.
* Errors from failed reads/writes are normalized through `handleTxError(...)` rather than ad hoc string matching.

For layout consistency, read [`docs/ui-pattern-snippets.md`](https://github.com/flap-sh/flap-vault-component-template/blob/main/docs/ui-pattern-snippets.md) in the template before building `Component.tsx` — it has sanitized card/action-panel/read-write-flow patterns. For icons, search [lucide-react](https://lucide.dev/icons/) before hand-writing SVG.

## Safety rules you must not violate

These are blocked by default and will fail `vault:check`:

* `window.ethereum.request`, `eval`/`new Function`, raw `<iframe>` or `srcDoc`
* dynamic imports, CommonJS `require(...)`, runtime remote imports
* undeclared external URLs/endpoints/frames, or any endpoint that isn't a static absolute HTTPS string covered by `manifest.endpoints`
* browser storage, navigation, workers, `postMessage`, permission APIs, clipboard access
* direct browser network/media APIs (`XMLHttpRequest`, `WebSocket`, `EventSource`, `new Image()`)
* hidden transaction targets or contract calls to addresses outside your declared bindings
* remote images (immutable Vault images must use `IpfsImage`/`IpfsBackground` from `@/src/ui` with a static CID)
* relative imports other than `./VaultABI`
* binding by a "type" field instead of `chainId` + factory/vault/token address

Prefer SDK/on-chain reads over external endpoints and frames whenever the same result is achievable that way. If a non-oracle endpoint really is unavoidable, predeclare it as a static HTTPS string in `manifest.endpoints` — declaring it doesn't guarantee approval, it just makes it reviewable. See [`docs/manifest.md`](https://github.com/flap-sh/flap-vault-component-template/blob/main/docs/manifest.md) for the full rule set, including the reviewed `ReviewedFrame` allowance for TradingView/DexScreener/GeckoTerminal charts.

## Check, preview, and package

```bash
yarn vault:check my-vault      # JSON: ok, summary, agent.verdict, issues — fix every blocking issue
yarn vault:e2e my-vault        # deterministic Playwright gate: PC/iPad/H5, real/internal-market/DEX-listed/wrong-network
yarn vault:package my-vault    # writes dist/my-vault.zip, only after check + a current E2E report pass
yarn vault:verify-package dist/my-vault.zip
```

Preview your route with real runtime params before packaging:

```
http://localhost:3000/my-vault?chainId=56&factoryAddress=0x...&tokenAddress=0x...&vaultAddress=0x...
```

`vault:check` also enforces that your local checkout is exactly up to date with `origin/main` and that your `package.json` version matches the latest published `@flapsdk/vault-runtime` — a stale template checkout fails with `template-freshness/*` errors before it even reaches your Vault-specific issues. `vault:e2e` requires Playwright's Chromium (`yarn playwright install chromium` on first run).

## Handoff to Flap Artifact Workbench

The only deliverable Flap accepts is the zip produced by `yarn vault:package <folder-name>` — not a hand-made zip, not a prompt-only result, and not a package without a passing E2E proof. The zip embeds a package marker, npm runtime provenance, source/schema/E2E file hashes, and the E2E report; Workbench rejects anything missing that proof.

Once you have a verified zip, follow [Step 6 (Audit and low-risk badge)](/flap/developers/vault-developers/quick-start-vault-developers.md) and [Step 8 (align on your launch plan)](/flap/developers/vault-developers/quick-start-vault-developers.md) from the Quick Start guide, then hand the zip to the Flap team.
