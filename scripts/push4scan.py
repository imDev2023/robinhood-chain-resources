#!/usr/bin/env python3
"""Recover an unverified contract's function surface from its runtime bytecode.

PLAYBOOK.md section 4: "An unverified implementation is not a dead end." A PUSH4
scan over the runtime bytecode over-collects harmlessly, and resolving the
candidates in batches against openchain.xyz names roughly 60% of selectors with
no API key. The named 60% is always enough to identify the contract family.

Usage:
    python3 scripts/push4scan.py --addr 0xabc... [--slug raisehood] [--rpc <url>]
"""

import argparse
import json
import os
import re
import urllib.request

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# app.doppler.lol's proxy serves any chain-4663 read from anywhere (PLAYBOOK 6).
DEFAULT_RPC = "https://app.doppler.lol/api/rpc/4663"
LOOKUP = "https://api.openchain.xyz/signature-database/v1/lookup"


def get_code(addr, rpc):
    body = json.dumps(
        {"jsonrpc": "2.0", "id": 1, "method": "eth_getCode", "params": [addr, "latest"]}
    ).encode()
    req = urllib.request.Request(rpc, data=body, headers={"content-type": "application/json"})
    with urllib.request.urlopen(req, timeout=45) as resp:
        return json.load(resp).get("result") or ""


def scan(code):
    """PUSH4 is 0x63; the four bytes after it are a candidate selector."""
    return sorted({m.group(1) for m in re.finditer(r"63([0-9a-f]{8})", code.lower())})


def resolve(selectors):
    names = {}
    for i in range(0, len(selectors), 50):
        batch = selectors[i : i + 50]
        url = f"{LOOKUP}?function=" + ",".join("0x" + s for s in batch)
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "curl/8"})
            with urllib.request.urlopen(req, timeout=45) as resp:
                data = json.load(resp)
        except Exception:
            continue
        for sel, hits in (data.get("result", {}).get("function") or {}).items():
            if hits:
                names[sel.replace("0x", "")] = hits[0]["name"]
    return names


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--addr", required=True)
    ap.add_argument("--slug", help="write the report under launchpads/<slug>/_raw/rpc/")
    ap.add_argument("--rpc", default=DEFAULT_RPC)
    args = ap.parse_args()

    code = get_code(args.addr, args.rpc)
    if not code.startswith("0x") or len(code) < 4:
        print(f"no code at {args.addr}")
        return
    cands = scan(code)
    names = resolve(cands)

    lines = [
        f"# PUSH4 selector scan - {args.addr}",
        "",
        f"Runtime bytecode: {(len(code) - 2) // 2} bytes.",
        f"PUSH4 candidates: {len(cands)}. Resolved: {len(names)} "
        f"({100 * len(names) // max(len(cands), 1)}%).",
        "",
        "The scan over-collects: a PUSH4 can be any 4-byte constant, so an",
        "unresolved candidate is not necessarily a function. Resolved names are",
        "from openchain.xyz and are the first match per selector.",
        "",
        "## Resolved",
        "",
    ]
    lines += [f"- `0x{sel}`  `{name}`" for sel, name in sorted(names.items(), key=lambda kv: kv[1])]
    lines += ["", "## Unresolved candidates", ""]
    lines += ["- `0x" + s + "`" for s in cands if s not in names] or ["None."]
    report = "\n".join(lines) + "\n"

    if args.slug:
        out_dir = os.path.join(REPO, "launchpads", args.slug, "_raw", "rpc")
        os.makedirs(out_dir, exist_ok=True)
        out = os.path.join(out_dir, f"push4-{args.addr}.md")
        with open(out, "w") as fh:
            fh.write(report)
        code_path = os.path.join(out_dir, f"code-{args.addr}.hex")
        with open(code_path, "w") as fh:
            fh.write(code)
        print(f"wrote {out}")
    print(f"{args.addr}: {len(cands)} candidates, {len(names)} resolved")
    for sel, name in sorted(names.items(), key=lambda kv: kv[1]):
        print(f"  0x{sel}  {name}")


if __name__ == "__main__":
    main()
