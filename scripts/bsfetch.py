#!/usr/bin/env python3
"""Populate launchpads/<slug>/_raw/blockscout/ through a real browser session.

Cloudflare began challenging robinhoodchain.blockscout.com/api/v2 some time after
2026-09-03, so the browser User-Agent trick in PLAYBOOK.md section 4 now returns a
"Just a moment..." interstitial, and a Blockscout API key does not clear it either.

A real browser clears the challenge once; thereafter a `fetch` issued from inside
the page carries the clearance cookie, so the whole archive can be pulled through
one `agent-browser` session. That is what this does. It writes the two responses
mkarchive.py expects, so the pair compose:

    python3 scripts/bsfetch.py --slug unihood < addrs.txt
    python3 scripts/bsfetch.py --slug unihood --build

where addrs.txt holds `Role|0xaddr` lines.
"""

import argparse
import json
import os
import subprocess
import sys
import time

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HOST = "https://robinhoodchain.blockscout.com"
SESSION = "tl-scrape"

EVAL = """(async () => {
  const a = "%s";
  const out = {};
  for (const [key, path] of [["sc", "smart-contracts"], ["ad", "addresses"]]) {
    try {
      const r = await fetch(`/api/v2/${path}/${a}`);
      out[key] = r.status === 200 ? await r.json() : {__status: r.status};
    } catch (e) {
      out[key] = {__error: String(e)};
    }
  }
  return JSON.stringify(out);
})()"""


def ensure_session():
    """Open the host once so the Cloudflare clearance cookie exists."""
    subprocess.run(
        ["agent-browser", "open", f"{HOST}/api/v2/stats", "--session", SESSION],
        capture_output=True, text=True, timeout=180,
    )


def unwrap(raw):
    """agent-browser returns the eval result as a JSON-encoded string."""
    obj = json.loads(raw.strip())
    return json.loads(obj) if isinstance(obj, str) else obj


def fetch_one(slug, role, addr, force=False):
    raw_dir = os.path.join(REPO, "launchpads", slug, "_raw", "blockscout")
    os.makedirs(raw_dir, exist_ok=True)
    sc_path = os.path.join(raw_dir, f"smart-contracts-{role}-{addr}.json")
    ad_path = os.path.join(raw_dir, f"addresses-{role}-{addr}.json")
    if os.path.exists(sc_path) and os.path.exists(ad_path) and not force:
        print(f"  cached  {role} {addr}")
        return True

    for attempt in range(3):
        try:
            proc = subprocess.run(
                ["agent-browser", "eval", "--session", SESSION, EVAL % addr],
                capture_output=True, text=True, timeout=180,
            )
            data = unwrap(proc.stdout)
            break
        except Exception as exc:
            if attempt == 2:
                print(f"  FAIL    {role} {addr}: {exc}")
                return False
            time.sleep(3 * (attempt + 1))
            ensure_session()

    sc, ad = data.get("sc") or {}, data.get("ad") or {}
    if "__status" in ad or "__error" in ad:
        print(f"  FAIL    {role} {addr}: addresses -> {ad}")
        return False
    with open(sc_path, "w") as fh:
        json.dump(sc, fh, indent=1)
    with open(ad_path, "w") as fh:
        json.dump(ad, fh, indent=1)
    print(
        f"  ok      {role} {addr} verified={ad.get('is_verified')} "
        f"name={sc.get('name') or ad.get('name')} "
        f"sources={len(sc.get('additional_sources') or [])} proxy={ad.get('proxy_type')}"
    )
    return True


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--slug", required=True)
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--build", action="store_true", help="run mkarchive.py over the cache afterwards")
    args = ap.parse_args()

    targets = []
    for line in sys.stdin:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split("|")
        targets.append((parts[0], parts[1], parts[2] if len(parts) > 2 else ""))

    if targets:
        ensure_session()
        print(f"fetching {len(targets)} contracts for {args.slug}")
        ok = sum(fetch_one(args.slug, role, addr, args.force) for role, addr, _ in targets)
        print(f"fetched {ok}/{len(targets)}")

    if args.build and targets:
        feed = "\n".join(f"{r}|{a}|{n}" for r, a, n in targets)
        subprocess.run(
            [sys.executable, os.path.join(REPO, "scripts", "mkarchive.py"), "--slug", args.slug],
            input=feed, text=True,
        )


if __name__ == "__main__":
    main()
