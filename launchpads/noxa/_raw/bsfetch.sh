#!/bin/bash
# usage: bsfetch.sh <path> <outname>  (sequential, retries on 429)
O="/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/noxa/_raw"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0 Safari/537.36"
for i in 1 2 3 4 5 6; do
  curl -s -m 60 -A "$UA" "https://robinhoodchain.blockscout.com/api/v2/$1" > "$O/blockscout-$2.json"
  if grep -q '"Too many requests"' "$O/blockscout-$2.json" || grep -q 'error code: 5' "$O/blockscout-$2.json"; then sleep $((i*4)); else break; fi
done
sleep 0.7
