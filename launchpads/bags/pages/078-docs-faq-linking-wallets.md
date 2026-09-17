# Bags - How to display social profile on token page?

> Source: https://docs.bags.fm/faq/linking-wallets
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/faq/linking-wallets.md)

---

# How to display social profile on token page?

> Learn how to link your wallet to Bags to display your identity when creating tokens via API

## How to display social profile on token page?

When launching your token via API, you can choose any wallet address.\
However, the **creator identity shown on the token page** depends on the wallet you use:

<Columns cols={2}>
  <Card title="🔒 Option 1 — External Wallet (via API)" icon="wallet">
    If you use **any external wallet address**, your token page will display only the wallet address.

    <img src="https://mintcdn.com/bags/z9nfTwOFkd0qq8LF/images/token-page-external.png?fit=max&auto=format&n=z9nfTwOFkd0qq8LF&q=85&s=11fcbe58a7fd31523b882b8321407f30" alt="External Wallet Example" style={{ width: '100%', maxWidth: '600px', borderRadius: '0.5rem', marginTop: '1rem' }} width="720" height="267" data-path="images/token-page-external.png" />
  </Card>

  <Card title="🌐 Option 2 — Bags Wallet (via Bags Login)" icon="check-circle">
    Use your **Bags wallet** (export the private key from [Bags.fm](https://bags.fm)) when creating tokens via API. Your token page will display your **social profiles** (X, GitHub, Kick, TikTok) instead of just a wallet address.

    <img src="https://mintcdn.com/bags/z9nfTwOFkd0qq8LF/images/token-page-bags.png?fit=max&auto=format&n=z9nfTwOFkd0qq8LF&q=85&s=c5825105e88febb61ac0ddb25aef654b" alt="Bags Wallet Example" style={{ width: '100%', maxWidth: '600px', borderRadius: '0.5rem', marginTop: '1rem' }} width="1142" height="366" data-path="images/token-page-bags.png" />
  </Card>
</Columns>

## How to Export Your Bags Wallet to Phantom

Follow these simple steps to use your Bags wallet externally (e.g., with the API or Phantom):

1. Visit [bags.fm](https://bags.fm)
2. Log in with your credentials
3. Tap your **username / profile picture** in the top-right corner
4. Select **My Wallets** → **Export Private Key** for the wallet you want to export\
   *(Do this only in a safe, private environment)*
5. Tap **Copy Key** to copy the private key to your clipboard
6. You can now import your private key into any wallet app (such as Phantom), or use it in your API scripts to launch a token.<br />
     - To launch a token with your exported wallet, follow our [Token Launch Guide](/how-to-guides/launch-token).

<Warning>
  Keep your private key safe — store it offline (e.g., written on paper or in a password manager).\
  Never share it publicly or in untrusted apps.
</Warning>

If you encounter any issues, please contact the Bags team via support or your Bags dashboard.
