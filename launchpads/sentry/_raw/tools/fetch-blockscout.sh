#!/bin/bash
# Fetch Blockscout v2 address, smart-contract and token records for a list of addresses.
# Usage: bash fetch-blockscout.sh <addr> [addr...]
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0 Safari/537.36"
B="https://robinhoodchain.blockscout.com/api/v2"
OUT="$(cd "$(dirname "$0")/../blockscout" && pwd)"
for a in "$@"; do
  la=$(echo "$a" | tr 'A-Z' 'a-z')
  for kind in addresses smart-contracts tokens; do
    f="$OUT/${kind}-${la}.json"
    [ -s "$f" ] && continue
    curl -s -A "$UA" "$B/${kind}/${a}" -o "$f"
    sleep 0.3
  done
  echo "$la $(wc -c < "$OUT/addresses-${la}.json") $(wc -c < "$OUT/smart-contracts-${la}.json")"
done
