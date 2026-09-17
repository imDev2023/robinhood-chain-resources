#!/bin/bash
RAW="$1"; C="$2"
while read a role; do
  [ -z "$a" ] && continue
  if [ ! -s "$RAW/blockscout-address-$a.json" ] || grep -q "Too many" "$RAW/blockscout-address-$a.json"; then "$RAW/bs.sh" "addresses/$a" "$RAW/blockscout-address-$a.json"; fi
  ver=$(python3 -c "import json;print(json.load(open('$RAW/blockscout-address-$a.json')).get('is_verified'))")
  if [ "$ver" = "True" ]; then
    if [ ! -s "$RAW/blockscout-sc-$a.json" ] || grep -q "Too many" "$RAW/blockscout-sc-$a.json"; then "$RAW/bs.sh" "smart-contracts/$a" "$RAW/blockscout-sc-$a.json"; fi
    python3 "$RAW/write_contract.py" "$RAW" "$C" "$a" "$role"
  else
    echo "unverified $a $role"
  fi
done <<'LIST'
0x8c529f0a77c07ce0e6796f153d292501ee6f66f6 HoodCustomLaunchpad-v2-default
0x6a63d96ef77ae569fcb85934cf1bd1ec7fe9b33d HoodLaunchpad-classic
0xd2a7c92fcb240c755919e9230c8db066e9ca1500 HoodBurnLocker
0xd71f61Ee12c9bb7Faf001267Af17e1118856fA29 HoodProfiles
0x6d188c21f99a7578d4E3fD449b67d740ff97eb4d HoodCommunityFactory
0x6b8Efd1713B020Ea0C01557Dc3fCFEa266cc048f HoodCommunityFactory-Implementation
0xed2d2a46E64Bc84355eE3CD6A02ab470EA42147E HoodCommunityGuarded
0x1811F54e2964758641AaC993cA91F9189a8BdA2d HoodStockFactory
0xECF1533F94EB3547FdFF9B50b6173529Aa4E0a33 HoodStockFactory-Implementation
0x86c6FAF889eBAC8621BBb6dd8CA86aa6d51c9e6C HoodV3MigratorV2-a
0x6d36DcD6fab842a2B29896c5c58f32304B824711 HoodV3MigratorV2-b
0x5790Ef23bE2E1543442C12F4550FaE147ba8eDBe HoodV3Migrator-a
0x88B4cde518272033F48862CEF728203aF219D02e HoodV3Migrator-b
0x52E31d7E2A3A71a55C4527bd5b5cA3FeE2975866 SwapRouter-hood
0xCaf681a66D020601342297493863E78C959E5cb2 UniswapSwapRouter02
0x1f7d7550B1b028f7571E69A784071F0205FD2EfA UniswapV3Factory
0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f UniswapV2Factory
0x72d74dAd7135d5e183A3d3FBE1E8358bBC143A9b UniswapV3Pool-FEATHER-WETH
0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73 WETH-Proxy
0xC6B81b429797E0f555440b70cD99e032D7AE947e WETH-Implementation-aeWETH
0x4783C67b63dE2B358Ac5951a7D41F47A38F3C046 StockFactory-Proxy-RobinhoodStocks
0xEe351E53BCe6AAF106428358838197C91e36EE0E StockFactory-Implementation-RobinhoodStocks
0xB3f3B54E11217F4F73e7a766B7CAA187390d700D ProtocolOwner-GnosisSafe
0x29fcB43b46531BcA003ddC8FCB67FFE91900C762 GnosisSafe-MasterCopy
0x90655172A3F8C73C2D664F372e1be0339702bFa7 Deployer-EOA-1
0x0F307b093dafB55B2a0C12D53d5640D00D9a7836 Deployer-EOA-2
0x4fc2c986e3dBA46D7Ce6B60919c78E48ae52188b Deployer-EOA-3
0x860C93251C121Bd3dF12c7B52aD522edE1AB99FF Deployer-EOA-4
0x78b531f1394863964978Dc57d21c07B89e1CEeBd Deployer-EOA-5
0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52 Uniswap-Deployer-EOA
0xc6a2941b962fb667786d7F4b97f7f965D6f0A4f8 CommunityLauncher-unverified
0xAF36aC404E9472f1dDBC3B36E348920F1E943c9E CommunityRewardsVault-Implementation-unverified
0x9Fe65C9a603B0C9975079fBFc510a62713031119 CommunityRewardsVault-FEATHER-clone
0xAb0B12005275cA53C649f360119b9C23F60faAb8 HoodCommunityGuarded-Implementation-unverified
0x67AF360b375DC86aE5Ad620693bfCD916A31600D HoodToken-Robin
LIST
echo FETCH_DONE
