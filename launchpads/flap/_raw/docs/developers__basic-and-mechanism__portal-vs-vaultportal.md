> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/basic-and-mechanism/portal-vs-vaultportal.md).

# Portal vs VaultPortal

## Overview

The `Portal` is the entry point of the Flap bonding curve protocol. It launches standard tokens and tax tokens and wires them to the bonding curve lifecycle. For each tax token launched, if the "funds recipient wallet" percentage is set to non-zero, a portion or all tax revenue is sent to that wallet. And when that wallet is a smart contract and implements Vault interface, it is called a `Vault`.

The `VaultPortal` builds on top of the `Portal` to add Vault functionality for tax tokens. It launches a tax token and sets up a Vault in one flow.

For Vault concepts and behavior, see [developers/vault-developers/flap-tax-vault.md](/flap/developers/vault-developers/flap-tax-vault.md).

## When to use which

* Use `Portal` when you only need to launch a standard token or a tax token without Vault features or your custom Vault implementation.
* Use `VaultPortal` when you want Vault-backed tax tokens and using a vault factory. (You can use any Vault Factory, this is permissionless.)

## Relationship diagram

![Vault vs VaultPortal relationship](/files/Votv94P9JAYdTWniksf2)
