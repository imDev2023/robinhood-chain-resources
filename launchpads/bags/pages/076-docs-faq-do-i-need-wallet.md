# Bags - Do I need a Solana wallet to use the API?

> Source: https://docs.bags.fm/faq/do-i-need-wallet
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/faq/do-i-need-wallet.md)

---

# Do I need a Solana wallet to use the API?

> Learn about wallet requirements for using the Bags API

## Do I need a Solana wallet to use the API?

For operations that require on-chain transactions like creating a token or claiming fees you'll need a Solana wallet with enough SOL to cover transaction costs, but you don't necessarily need SOL for non-transactional usage.

### Wallet Requirements

* **Token Launch**: Requires a wallet with SOL for transaction fees
* **Fee Sharing**: Needs wallet access for configuring and claiming fees
* **Transactions**: Any blockchain operations require wallet signing

### Getting Started

1. Export your wallet's private key (base58 encoded)
2. Add it to your environment variables: `PRIVATE_KEY=your_base58_encoded_private_key`
3. Use it in your scripts to sign transactions

<Note>
  You can export your private key from wallets like Bags, Phantom, or Backpack. See our [Token Launch Guide](/how-to-guides/launch-token) for examples.
</Note>

### Security Best Practices

* Never commit private keys to version control
* Use environment variables or secure secret management
* Consider using a dedicated development wallet
