<!-- source: https://developers.uniswap.org/docs/protocols/v4-hooks/dualpool/guides/deploy-hook | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/protocols/v4-hooks/dualpool/guides/deploy-hook.md (native markdown) -->
# Deploy a Hook (/docs/protocols/v4-hooks/dualpool/guides/deploy-hook)

Deploy a new DualPool hook through the factory and verify its provenance.

## Context
New DualPool hooks are deployed through the [`AllowlistedFactory`](https://github.com/Uniswap/v4-hooks-public), the family's canonical CREATE2 deployer and discovery registry:

| Network     | Address                                                                                                                 |
| ----------- | ----------------------------------------------------------------------------------------------------------------------- |
| Ethereum: 1 | [`0x0000000000077769C332e0D3ed8bC8E02A0cE108`](https://etherscan.io/address/0x0000000000077769C332e0D3ed8bC8E02A0cE108) |

Deploying through the factory is what makes a hook discoverable: the factory emits a [`Deployed`](https://github.com/Uniswap/v4-hooks-public) event, records the hook in its onchain registry (`allDeployments`, `isFromFactory`), and the hook's own `factory()` getter points back at the factory, so aggregators and routers can verify provenance from either side.

The factory only accepts creation code whose keccak256 hash is on an immutable allowlist fixed at its construction. A registered hook is therefore a bit-exact build of the audited DualPool bytecode. Deployment is permissionless: anyone can deploy a hook and choose its `owner`, so registration attests bytecode provenance, not operator trustworthiness.

> [!NOTE]
> **The bytecode is pinned**
>
> The allowlist pins exact compiler output. Build from the pinned toolchain in [v4-hooks-public](https://github.com/Uniswap/v4-hooks-public); any change to the source, compiler version, or settings changes the creation-code hash and the factory rejects it with `CreationCodeNotAllowed`. The deploy script checks your build against the factory before broadcasting, so drift fails fast.

## 1. Choose the Constructor Parameters
The hook's constructor takes four values, fixed for the hook's lifetime:

| Parameter             | Meaning                                                                                                                                                                                                                                                |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `poolManager`         | The canonical v4 `PoolManager` on the target chain, [`0x000000000004444c5dc75cB358380D2e3dE08A90`](https://etherscan.io/address/0x000000000004444c5dc75cB358380D2e3dE08A90) on Ethereum (all chains: [v4 deployments](/docs/protocols/v4/deployments)) |
| `maxGas`              | Gas budget the hook declares for `getIndicativeQuote` staticcalls; routers cap their calls at this (script default `800000`)                                                                                                                           |
| `owner`               | Initial hook owner, the operator trust principal; transferable via `Ownable2Step`, renounce disabled                                                                                                                                                   |
| `maxMinDepositBlocks` | Ceiling for the per-pool `minDepositBlocks` deposit lock (script default `3600`)                                                                                                                                                                       |

One hook instance serves many pools: if you already operate a DualPool hook, you usually want a [new pool](/docs/protocols/v4-hooks/dualpool/guides/create-pool) on it, not a new hook.

## 2. Mine a Salt
The factory deploys via CREATE2, and v4 requires a hook's address to encode its permission flags in the low 14 bits (`address & 0x3fff == 0x2ac0` for DualPool). The factory is the CREATE2 deployer, so salts must be mined against the factory address; a salt mined for any other deployer resolves to a different address and reverts.

From a checkout of `v4-hooks-public`:

```bash
FACTORY=0x0000000000077769C332e0D3ed8bC8E02A0cE108 \
POOL_MANAGER=0x000000000004444c5dc75cB358380D2e3dE08A90 \
HOOK_OWNER=<owner> \
./script/mine_dualpool_salt.sh
```

The miner computes the init-code hash from your current build and the exact constructor arguments, searches for the flag bits plus a leading-zero vanity prefix (`MIN_LEADING_ZERO_NIBBLES`, default 6), and independently re-verifies every match. Constructor arguments are part of the mined address: change any of them and the salt is invalid.

For testnets you can skip offchain mining entirely by setting `MIN_LEADING_ZERO_NIBBLES=0` at deploy time; the deploy script then mines a flags-only salt in-EVM.

## 3. Deploy
```bash
FACTORY=0x0000000000077769C332e0D3ed8bC8E02A0cE108 \
POOL_MANAGER=0x000000000004444c5dc75cB358380D2e3dE08A90 \
HOOK_OWNER=<owner> \
HOOK_SALT=<mined salt> \
forge script script/DeployDualPoolHook.s.sol --rpc-url $RPC_URL --broadcast --account <signer>
```

Before broadcasting, the script verifies that the factory allowlists your build's creation-code hash and that the salt resolves to an address with the correct flag bits and vanity prefix. After broadcasting, it confirms the deployed address, `hook.factory()`, and the factory registration.

Programmatic deployers can call the factory directly; constructor arguments are passed as ABI-encoded bytes:

```solidity
bytes memory constructorArgs = abi.encode(poolManager, maxGas, owner, maxMinDepositBlocks);

address hook = factory.deploy(type(DualPoolHook).creationCode, constructorArgs, salt);
```

`factory.computeAddress(creationCode, constructorArgs, salt)` predicts the address without deploying.

## 4. Verify
```bash
# The hook points back at the factory
cast call <hook> "factory()(address)" --rpc-url $RPC_URL

# The factory vouches for the hook
cast call 0x0000000000077769C332e0D3ed8bC8E02A0cE108 \
  "isFromFactory(address)(bool)" <hook> --rpc-url $RPC_URL
```

Both checks must pass. A hook deployed outside the factory reports its direct deployer from `factory()` and is not registered; routers that anchor trust on the factory will not pick it up.

## Where to Go Next
* [Create and operate a pool](/docs/protocols/v4-hooks/dualpool/guides/create-pool) on your new hook
* [Help routers discover and quote your pool](/docs/protocols/v4-hooks/dualpool/guides/router-integration)
