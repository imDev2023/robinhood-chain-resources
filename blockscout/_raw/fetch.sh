#!/usr/bin/env bash
# Re-fetch docs.blockscout.com as source markdown.
# GitBook serves every page's own markdown at <page-url>.md, so no HTML conversion is involved.
# Usage: bash resources/blockscout/_raw/fetch.sh   (run from the long-launch root)
set -euo pipefail
ROOT="resources/blockscout"
RAW="$ROOT/_raw"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128 Safari/537.36"
mkdir -p "$RAW"
curl -s -A "$UA" https://docs.blockscout.com/sitemap.xml   -o "$RAW/sitemap.xml"
curl -s -A "$UA" https://docs.blockscout.com/llms.txt      -o "$RAW/llms.txt"
curl -s -A "$UA" https://docs.blockscout.com/llms-full.txt -o "$RAW/llms-full.txt"
grep -o "<loc>[^<]*</loc>" "$RAW/sitemap.xml" | sed 's/<[^>]*>//g' | sort -u > "$RAW/urls.txt"
# llms.txt links pages the sitemap may not; merge them in.
grep -o "https://docs.blockscout.com/[^) ]*" "$RAW/llms.txt" | sed 's/\.md$//' | sort -u >> "$RAW/urls.txt"
sort -u -o "$RAW/urls.txt" "$RAW/urls.txt"
fetch_one() {
  url="$1"; path="${url#https://docs.blockscout.com}"; path="${path#/}"; [ -z "$path" ] && path="index"
  out="$ROOT/$path.md"; mkdir -p "$(dirname "$out")"
  code=$(curl -s -A "$UA" -w "%{http_code}" -o "$out" "$url.md")
  [ "$code" = "200" ] || { echo "FAIL $code $url"; rm -f "$out"; }
}
export -f fetch_one; export ROOT UA
xargs -P 6 -I{} bash -c 'fetch_one "$@"' _ {} < "$RAW/urls.txt"
date -u +"captured %Y-%m-%dT%H:%M:%SZ" > "$RAW/CAPTURED.txt"
echo "pages: $(find "$ROOT" -name '*.md' -not -path '*/_raw/*' | wc -l)"
