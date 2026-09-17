## Context, not part of the HOOD10 Launchpad

The letscash.fun v4 hook, and the contract that actually charges the HOOD10 index token's 5% tax.
`currentFeeRate(HOOD10 poolId, 0x0)` returns 50000 pips (5%) and `poolConfigs(poolId)` names the fee recipient as the EOA 0x639D6Faa4DAf85d4ccc4291D1134C83867df5d82 (`_raw/rpc/hood10-token-state.txt`).
`owner` 0xd2DEfBd13aFF22d6989e8C14b4517eC308079e91, `treasury` 0x67cCBFb238047d62736265B3093a5989836794b0, `MAX_FEE_RATE` 100000.
