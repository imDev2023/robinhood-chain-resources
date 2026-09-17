#!/bin/bash
# Second pass, 2026-09-03: contracts found by reading pointers off the live
# consumers (launchpad.migrator(), migrator.locker(), migrator.launchpad(),
# migrator.nfpm()) rather than off the frontend config block.
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
0x3d1c455f81ec131cc91b000b42fccbf45a132026 HoodCustomLaunchpad-c
0xad69d8a00564f4a2365cc74594925f95281706aa HoodBurnLocker-customV1
0x86083371c51654816518c35cc589871c24018a54 HoodLiquidityLocker-classic
0x5e27754b2cdf4fe3715451d2d3d267801e0f4934 HoodBurnLocker-c
0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3 UniswapNonfungiblePositionManager
0x8E96a84AdC54d04869ded92661a01f75e283741B ProtocolOwner-GnosisSafe-current
LIST
