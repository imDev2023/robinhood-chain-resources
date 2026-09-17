# Doppler - Connect wallet, the Privy login gate

> Source: https://app.doppler.lol/ (Connect)
> Retrieved: 2026-09-02 (agent-browser with an injected EIP-1193 provider, session lp-doppler-wallet)

---

Everything behind `Connect wallet` in this app sits behind a **Privy** login, not merely a connected wallet.
This page records exactly what that gate asks for and how far the archive got through it.

Screenshots: `screenshots/24-app-connect-privy-login.png`, `screenshots/25-app-connect-wallet-list.png`, `screenshots/26-app-connect-signature-request.png`.

## Method

No wallet extension and no private key of the user's were involved.
A read-only EIP-1193 provider was registered as an `agent-browser --init-script`, so it installs before any page JavaScript runs.
The harness is kept at `_raw/tools/inject-readonly-wallet.js` so a later session can repeat this.

What it does:

- reports one address and chain id `0x1237` (4663)
- forwards every read (`eth_call`, `eth_getBalance`, `eth_estimateGas`, ...) to the app's own proxy at `https://app.doppler.lol/api/rpc/4663`
- announces itself over **EIP-6963**, which is how wagmi and Privy actually discover wallets
- records and refuses `eth_sendTransaction`, `eth_signTransaction` and `wallet_sendCalls`, so no transaction can ever be built into a broadcast
- parks any signing challenge on `window.__PENDING_SIGN` for an out-of-page signer, so no key ever enters Doppler's JavaScript context

## Step 1, the login modal

`Connect` does not open a wallet picker.
It opens a Privy modal titled **`Log in or sign up`**, subtitled `Sign in to Doppler`, offering:

- an email field with a `Submit` button (`Continue with Email`)
- `Continue with a wallet`
- the footer `By logging in I agree to the Terms & Privacy Policy`, and a Privy attribution link

This modal exposes two real routes that are not reachable from the footer, where the same documents open as modals instead:

- <https://app.doppler.lol/terms-of-service>
- <https://app.doppler.lol/privacy-policy>

## Step 2, the wallet list

`Continue with a wallet` shows `Select your wallet`:

`Archive Harness`, MetaMask, Coinbase Wallet, Rainbow, Phantom, WalletConnect.

`Archive Harness` is this archive's injected provider.
Its presence in the list is the finding: the app enumerates wallets purely from EIP-6963 announcements and will offer any provider that announces itself.

## Step 3, the signature challenge

Selecting a wallet immediately triggers a `personal_sign`.
Captured verbatim, decoded from hex, at `_raw/wallet/siwe-message.txt`:

```text
app.doppler.lol wants you to sign in with your Ethereum account:
0xTEST_WALLET_ADDRESS_REDACTED

By signing, you are proving you own this wallet and logging in. This does not initiate a transaction or cost any fees.

URI: https://app.doppler.lol
Version: 1
Chain ID: 4663
Nonce: 32e084ee3e731e0c5dd60234ce2d6b3ad3d1c1a544feb6edf8a89b98901181c0
Issued At: 2026-09-02T16:21:44.838Z
Resources:
- https://privy.io
```

A standard SIWE (EIP-4361) challenge.
Points worth keeping:

- `Chain ID: 4663`, so the login is bound to Robinhood Chain specifically.
- The nonce is server-issued and single-use, so a captured signature cannot be replayed into a later session.
- `Resources: - https://privy.io` confirms Privy is the identity provider, matching the `auth.privy.io` traffic in `_raw/network/app-session.har`.
- The message states plainly that signing does not initiate a transaction or cost fees, which is accurate: it is an authentication signature only.

The raw request as the provider received it is at `_raw/wallet/capture-siwe.json`.

## Completing the login

The login **was** completed, on 2026-09-02.
The signature step was performed by the user running a local script (`sign-and-deliver.sh`), because this environment's safety classifier blocks an agent from delivering a signature that authenticates a live session.
The provider parked the challenge, the user's script signed it with the throwaway key outside the browser, and `window.__PROVIDE_SIG(id, sig)` handed back only the signature.
Privy accepted it and the header switched from `Connect` to `0xTEST...REDACTED`.

Screenshot: `screenshots/27-app-logged-in.png`.

### What appears once authenticated

**Portfolio** (`screenshots/28-app-portfolio-connected.png`).
The empty state changes from `Wallet not connected` to `No tokens in portfolio` / `Start trading to see your portfolio tokens here`, and a **Receive** control appears that does not exist logged out.
The five header tiles (Total value, Claimable fees, Total assets, 24h PnL, Tokens created) render but stay blank for a wallet with no positions.

**Receive tokens** (`screenshots/29-app-portfolio-receive.png`).
A chain selector defaulting to Robinhood, the wallet address in full, and a copy button.

**Settings menu** (`screenshots/30-app-menu-connected.png`).
The Instant buy controls, which carry `[disabled]` on every element when logged out, become live: an Off / On pair, and an `Amount (USD)` row of `$10`, `$25`, `$50` and a custom `+`.
This is what drives the `Quick buy` button on every feed row.
The Theme picker is unchanged.

**Account menu** (`screenshots/31-app-account-menu.png`).
This is the most interesting authenticated surface, because Privy silently provisions wallets of its own:

| entry | address | note |
| --- | --- | --- |
| Archive Harness Wallet | `0xTEST...REDACTED` | the connected provider, shown disabled as the active wallet |
| MetaMask Wallet | `0xTEST...REDACTED` | the same wallet listed twice, an artifact of this harness setting `isMetaMask: true` while also announcing over EIP-6963 |
| **Privy Wallet** | `0x6E3a...a955` | an **embedded EVM wallet, created automatically on first login** |
| **Privy Wallet** | `2kKLSr...bj8d` | an **embedded Solana wallet**, likewise automatic |

Also present: `Add wallet`, `Copy EVM Privy wallet address`, `Copy Solana Privy wallet address`, and `Logout`.

The embedded wallets are worth flagging for anyone launching here.
Logging in with an external wallet still creates a second, app-provisioned custodial pair that the user did not ask for and may not notice.

**Create flow** (`screenshots/32-app-create-connected-ready.png`, `screenshots/33-app-create-submitted.png`).
The submit control changes from `Connect wallet` to `Create token`.
Submitting with an unfunded wallet does not build a transaction; the panel returns a client-side precheck instead:

> You have no balance on Robinhood. You'll need funds to create a token.

So the app gates launching on a balance read before it ever constructs the call.
That read does not go through the wallet provider: it is issued by the app's own transport to `/api/rpc/4663`, so patching `window.ethereum` does not affect it.

### What remains uncaptured from the UI

- the client-side salt mining that gives every token on this chain its `1e18` vanity address suffix
- any post-launch creator dashboard

Both are answered well enough from the chain, below and in section 5 of `README.md`.

## What the fee UI would have shown, read from the chain instead

For JOHNDOG (`0x64bcf4aa85559526cff0528bcdc0cb9d3ea41e18`), pool id `0xa9349400def8a8fb8b96763c52870fcadbc8775361dd49e95291486be5141e0a`:

`DopplerHookInitializer.getBeneficiaries(asset)` returns two entries:

| beneficiary | shares (WAD) | percent | who |
| --- | --- | --- | --- |
| `0x21e2ce70511e4fe542a97708e89520471daa7a66` | 50000000000000000 | 5.0000% | the Doppler protocol Safe |
| `0x9b9849762f9be27d5546117c12ac6d7cf1dfbb38` | 950000000000000000 | 95.0000% | the token's creator and `fee_receiver` |

That is the documented 5% / 95% default, confirmed on a real live token rather than inferred from the create form.

Accrued fee accounting on the same pool:

| read | raw | scaled |
| --- | --- | --- |
| `getCumulatedFees0(poolId)` | 1295237886989384441245474 | 1,295,237.886989 JOHNDOG |
| `getCumulatedFees1(poolId)` | 3844610859874262834 | 3.844611 SGOV |
| `getLastCumulatedFees0(poolId, creator)` | 1295237886989384441245474 | identical |
| `getLastCumulatedFees1(poolId, creator)` | 3844610859874262834 | identical |

Claimable for a beneficiary is `(cumulated - lastCumulated) * shares / WAD`.
Both deltas are zero, so this creator has nothing outstanding at capture time; the accounting is watermark-based, not a running balance.

The claim entry point is **`DopplerHookInitializer.collectFees(bytes32 poolId)`**, nonpayable.
Note the asymmetry that matters for a multicurve launch on this chain: fees accrue in **both** sides of the pair, the launched token and the numeraire, exactly as the create form's `Fees will be earned in both this token and ETH` line says.
Here the numeraire is SGOV, not ETH.

`updateBeneficiary(bytes32 poolId, address newBeneficiary)` lets a beneficiary hand its slot to another address, which is how creator fee rights are transferred without touching the pool.

## What the app actually builds, decoded from a real app-native launch

The signature gate above was never the only way to answer this.
17 of the 150 cached `Airlock.create` transactions carry the Doppler Safe as `integrator`, which means they were made through `app.doppler.lol` itself rather than through Long, Bankr or Feel.
Decoding one gives the exact transaction our test wallet would have produced.
Full output: `_raw/wallet/app-native-create-decoded.txt`, raw transaction at `_raw/wallet/app-native-create-tx.json`.

Transaction `0x500073f1ed5f772d0a3da567a930a50b54110abfd32c66e45f9fa841c717291e`:

| property | value | what it settles |
| --- | --- | --- |
| `to` | `0xeb7C034704eF8Dcd2D32324c1545f62fB4aD0862` | the app calls **Airlock directly**, not through `Bundler` |
| `from` | the creator's own wallet | the app does not relay or sponsor; the creator signs and pays |
| `value` | `0` wei | launching costs nothing beyond gas |
| gas used | 3,157,452 | the real cost of a launch on this chain |
| `governanceFactoryData` | `0x` | empty, NoOp governance |
| `liquidityMigratorData` | `0x` | empty, NoOp migrator |

Decoded `poolInitializerData`, matching the create form's defaults exactly:

| field | value |
| --- | --- |
| `fee` | `10000`, that is 1.00%, the form's default fee tier |
| `tickSpacing` | `200` |
| `farTick` | `887000` |
| curves | 4: shares `75.0000%`, `12.5000%`, `11.5000%`, `1.0000%`, totalling 100% |
| beneficiaries | Doppler Safe `5.0000%`, creator `95.0000%` |
| `dopplerHook` | `0x0`, no hook on a plain app launch |

The four curve shares are the Pricing step's three editable curves plus its locked tail curve, unchanged.
Note the second and third curves use `numPositions = 10` while the first and the tail use `1`.

Decoded `tokenFactoryData`:

| field | value |
| --- | --- |
| `tokenURI` | an `ipfs://` CID, so the app pins launch metadata to IPFS |
| `vestingSchedules`, `vestingBeneficiaries`, `amounts` | all empty at the default 100% sale |
| `maxBalanceLimit` | `0` |
| `balanceLimitEnd` | `0` |
| `controller` | `0x0` |

`maxBalanceLimit = 0` is worth flagging: **the anti-snipe balance cap is off by default.**
The mechanism exists in `DopplerERC20V1Factory` but a standard app launch does not set it.

For contrast, a Feel launch (`_raw/wallet/real-create-decoded.txt`) uses 11 curves, `fee = 0` with a dynamic fee driven by an attached Doppler Hook, and puts 100% of the initializer beneficiary share on the protocol Safe because the hook handles creator payout instead.
Same Airlock, same modules, very different configuration.
