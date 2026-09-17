# Flap - Quick start for token launcher developers

> Source: https://docs.flap.sh/flap/developers/token-launcher-developers/quick-start-token-launcher-developers
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/token-launcher-developers/quick-start-token-launcher-developers.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/token-launcher-developers/quick-start-token-launcher-developers.md).

# Quick start for token launcher developers

This page outlines the minimal steps to integrate with Flap for token launcher developers. Each step links to the detailed documentation.

1. **Find the `Portal` entrypoint.** Use the deployed addresses listed in [Deployed Contract Addresses](/flap/developers/token-launcher-developers/deployed-contract-addresses.md).
2. **Launch a token through `Portal`.** `Portal` is the core protocol for launching standard tokens and tax tokens. See [Portal vs VaultPortal](/flap/developers/basic-and-mechanism/portal-vs-vaultportal.md) for the conceptual difference, then follow [Launch token through Portal](/flap/developers/token-launcher-developers/launch-token-through-portal.md) for the implementation details.
3. **Launch a token through `VaultPortal` (tax tokens with vaults).** `VaultPortal` builds on top of `Portal` to add Vault functionality for tax tokens. Follow [Launch token through VaultPortal](/flap/developers/token-launcher-developers/launch-token-through-vaultportal.md). Each vault factory defines its own vault data schema-see [Registered vaults](/flap/developers/token-launcher-developers/registered-vaults.md) before encoding `vaultData`.
