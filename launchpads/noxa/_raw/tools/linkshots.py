# Adds a "> Screenshot:" line to the pages that have one. Idempotent; re-run after mkpages.py.
import re, os
BASE = "/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/noxa"
M = {
 "01-fun-home-trending": "01-fun-home.png",
 "03-fun-home-live": "02-fun-home-live.png",
 "04-fun-home-new": "02-fun-home-new.png",
 "05-fun-home-gainers": "02-fun-home-gainers.png",
 "06-fun-home-market-cap": "02-fun-home-market-cap.png",
 "07-fun-home-volume": "02-fun-home-volume.png",
 "08-fun-home-holders": "02-fun-home-holders.png",
 "09-fun-home-trades": "02-fun-home-trades.png",
 "10-fun-home-oldest": "02-fun-home-oldest.png",
 "11-fun-home-search-noxa": "03-fun-home-search-noxa.png",
 "13-fun-token-pcc": "04-fun-token-pcc.png",
 "15-fun-token-pcc-holders": "05-fun-token-pcc-holders.png",
 "18-fun-token-cashcat": "06-fun-token-cashcat.png",
 "19-fun-token-misshim": "07-fun-token-misshim.png",
 "20-fun-launch": "08-fun-launch.png",
 "22-fun-launch-filled": "09-fun-launch-filled.png",
 "23-fun-launch-jina": "14-fun-launch-2026-09-03.png",
 "24-fun-bridge": "10-fun-bridge.png",
 "25-fun-bridge-anywallet": "11-fun-bridge-anywallet.png",
 "27-fun-bridge-from": "12-fun-bridge-from.png",
 "28-fun-profile": "13-fun-profile.png",
 "29-fun-stats": "13-fun-stats.png",
 "30-fun-docs": "13-fun-docs.png",
 "71-noxa-io-robinhood-launch-today": "15-noxaio-launch-2026-09-03.png",
}
n = 0
for k, v in M.items():
    f = f"{BASE}/pages/{k}.md"
    if not os.path.exists(f):
        print("MISSING PAGE", k); continue
    if not os.path.exists(f"{BASE}/screenshots/{v}"):
        print("MISSING SHOT", v); continue
    s = open(f).read()
    if "> Screenshot:" in s:
        continue
    s = re.sub(r"(> Retrieved: [^\n]*\n)", r"\1> Screenshot: ../screenshots/" + v + "\n", s, count=1)
    open(f, "w").write(s); n += 1
print("linked", n)
