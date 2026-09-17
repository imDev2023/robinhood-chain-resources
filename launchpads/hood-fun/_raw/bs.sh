#!/bin/bash
# usage: bs.sh <path> <outfile>
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0 Safari/537.36"
for i in 1 2 3 4 5 6; do
  curl -s -m 40 -A "$UA" "https://robinhoodchain.blockscout.com/api/v2/$1" -o "$2"
  if ! grep -q "Too many requests" "$2" 2>/dev/null && [ -s "$2" ]; then break; fi
  sleep $((i*3))
done
sleep 1.2
