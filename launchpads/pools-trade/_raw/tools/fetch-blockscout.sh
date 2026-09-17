#!/bin/bash
# Idempotent Blockscout fetch for pools-trade. Skips files that already exist and are non-empty JSON.
cd "$(dirname "$0")/../.." || exit 1
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0 Safari/537.36"
B="https://robinhoodchain.blockscout.com/api/v2"
O="_raw/blockscout"
mkdir -p "$O"
while IFS='|' read -r role addr; do
  [ -z "$role" ] && continue
  for kind in addresses smart-contracts; do
    f="$O/$kind-$role-$addr.json"
    if [ -s "$f" ] && ! grep -q '"Too many requests"\|Just a moment' "$f" 2>/dev/null; then
      continue
    fi
    curl -s -A "$UA" "$B/$kind/$addr" -o "$f"
    sleep 1.2
    if grep -q 'Too many requests' "$f" 2>/dev/null; then
      sleep 8
      curl -s -A "$UA" "$B/$kind/$addr" -o "$f"
      sleep 1.2
    fi
    echo "$kind $role $(wc -c < "$f")"
  done
done < _raw/tools/addresses.txt
