# LaunchTokenV2-PCC - 0xbf3e53713a53e9c3d5d1ddc25dd2c65669244663

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xbf3e53713a53e9c3d5d1ddc25dd2c65669244663
Role: LaunchTokenV2-PCC.
Contract name: LaunchToken.
Verified: True.
Compiler: v0.8.30+commit.73712a01, EVM cancun, optimizer True runs 200.
Main file: src/LaunchToken.sol.
Source files written: 6 under `sources/`.
Creator: 0xDd84fDdEA1206115B37dbBC0ba5721530E1bA9C5.
Creation tx: 0xa9edad9d3406bbce09b2d0b6944aabca81b90320e935b94580e2f439c08884f5.
Proxy type: None; implementations: [].

A V2 launch token, verified. Its constructor arguments are the clearest record of what the V2 factory passes into a token.

## Constructor arguments

- `config` (tuple): `['Pussy Cat Club', 'PCC', '1000000000000000000000000000', '0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73', '0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3', '0x1f7d7550B1b028f7571E69A784071F0205FD2EfA', '0x9A6931E371b62048C7543C7002C99D83685BD44d', '10000', '200', '200', '3600']`
- `info` (tuple): `['0x2AC7cac771DF87Fd33258F2c42840a6632820943', 'ipfs://Qmdzq7JkTf2fAZZTRjkAS1DEwfuShnmTdCmgqCgjx7nRFC', "The hottest door on Robinhood. If you have to ask what's inside, you're not on the list. Members only.", ['https://t.me/PussyCatClub', 'https://x.com/PussyCatClubRH', '', 'https://pussycatclubrh.com', '']]`

## Events

- `Approval(address,address,uint256)`
- `Transfer(address,address,uint256)`

## State-changing functions

- `approve(address,uint256)`
- `transfer(address,uint256)`
- `transferFrom(address,address,uint256)`

## View functions

- `allowance(address,address)`
- `balanceOf(address)`
- `decimals()`
- `deployer()`
- `description()`
- `dexFactory()`
- `getTokenInfo()`
- `launchFactory()`
- `launchTime()`
- `liquidityPool()`
- `locker()`
- `logo()`
- `maxTxAmount()`
- `maxTxBps()`
- `maxTxLimit()`
- `maxWalletAmount()`
- `maxWalletBps()`
- `maxWalletLimit()`
- `name()`
- `pairToken()`
- `poolFee()`
- `positionManager()`
- `restrictionEndTime()`
- `restrictionSeconds()`
- `socials()`
- `symbol()`
- `totalSupply()`
