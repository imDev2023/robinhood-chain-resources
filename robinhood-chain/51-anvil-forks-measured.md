# Anvil forks of chain 4663, measured

> Original writing. Measured 2026-09-24 with anvil 1.8.3 and viem 2.56.8, forking mainnet near block 71,012,000, during the meme-factory launch rehearsal (ticket T41, `mf rehearse`).
> Useful to anyone who rehearses launches, claims or trades on a local fork of Robinhood Chain before sending them live.

## Anvil's dev account #0 is delegated on mainnet

The well-known development key #0 (`0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`) carries an EIP-7702 delegation on Robinhood Chain mainnet (code `0xef0100` followed by a delegate address), and the delegate changed between runs minutes apart: `0x8a67b502...` in one run, `0x2e623468...` in the next.
Its nonce also climbed from 1374 to 1385 within about twenty minutes, so something is actively using the public key on mainnet.
A fork inherits that code, and the delegate runs on every ETH transfer into the account (a sell, a fee claim), so a rehearsal that uses dev account #0 must clear it first with `anvil_setCode(address, "0x")`.
Never send real funds to any of anvil's public development accounts on this chain.

## Fork gas costs about 20 times mainnet

Mainnet answers `eth_maxPriorityFeePerGas` with 0 and `eth_gasPrice` with the base fee (about 0.05 gwei at the time): Nitro charges the base fee only.
An anvil fork suggests and charges a 1 gwei tip on top, so `eth_gasPrice` reads about 1.04 gwei and every fork transaction pays about 20 times what it would live.
Anything that compares fees against gas on a fork (a fee claim refused when it costs more than it collects, for example) needs more volume on the fork than it would on mainnet.
`anvil --disable-min-priority-fee` brings `eth_gasPrice` down to the base fee, but `eth_maxPriorityFeePerGas` still answers 1 gwei, and viem 2.56 (which fills transactions through anvil's `eth_fillTransaction`) then builds a tip above the fee cap and refuses to send: do not use that flag with a local-key viem signer.
The fork's base fee also falls by 12.5% a block, because anvil applies the EIP-1559 update against Nitro's huge block gas limit.

## A local key does not pin the chain in viem

viem checks the RPC's chain id against the wallet's chain only for JSON-RPC accounts.
With a local private key it signs for the configured chain id (4663) and sends the raw transaction to whatever node the URL points at; an anvil fork started with `--chain-id 4664` accepted and mined a transaction signed for 4663.
A signer that must stay on chain 4663 should call `eth_chainId` itself before every send.
