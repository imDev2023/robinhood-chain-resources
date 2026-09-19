#!/usr/bin/env python3
"""Build launchpads/<slug>/contracts/<Role>-<addr>/ from Blockscout, in one step.

Generalises launchpads/doppler/_raw/tools/mkcontract.py, which hardcoded a path
into the old long-launch working copy and required the two Blockscout responses
to be fetched by hand first.

Usage:
    echo 'LaunchFactory|0xabc...|optional note' | python3 scripts/mkarchive.py --slug unihood
    python3 scripts/mkarchive.py --slug unihood --role LaunchFactory --addr 0xabc...

Per PLAYBOOK.md section 4, the verification flag is taken from the addresses
endpoint and the sources from the smart-contracts endpoint, never both from one:
smart-contracts can return a name and an ABI for an address that addresses
reports as unverified, because it matched a verified twin by bytecode.
"""

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.request

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BLOCKSCOUT = "https://robinhoodchain.blockscout.com/api/v2"
UA = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/128.0 Safari/537.36"
)


def fetch(url, cache_path, force=False):
    """GET url as JSON, caching to cache_path. Cloudflare needs the browser UA."""
    if os.path.exists(cache_path) and not force:
        with open(cache_path) as fh:
            return json.load(fh)
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    for attempt in range(4):
        try:
            with urllib.request.urlopen(req, timeout=45) as resp:
                body = json.load(resp)
            break
        except urllib.error.HTTPError as exc:
            if exc.code == 404:
                return None
            if attempt == 3:
                raise
            time.sleep(2 * (attempt + 1))
        except Exception:
            if attempt == 3:
                raise
            time.sleep(2 * (attempt + 1))
    os.makedirs(os.path.dirname(cache_path), exist_ok=True)
    with open(cache_path, "w") as fh:
        json.dump(body, fh, indent=1)
    return body


def build(slug, role, addr, note="", force=False):
    base = os.path.join(REPO, "launchpads", slug)
    raw = os.path.join(base, "_raw", "blockscout")
    sc = fetch(f"{BLOCKSCOUT}/smart-contracts/{addr}", f"{raw}/smart-contracts-{role}-{addr}.json", force)
    ad = fetch(f"{BLOCKSCOUT}/addresses/{addr}", f"{raw}/addresses-{role}-{addr}.json", force)
    if ad is None:
        print(f"{role} {addr} NOT FOUND on chain")
        return False
    sc = sc or {}

    name = sc.get("name") or ad.get("name") or role
    out = os.path.join(base, "contracts", f"{role}-{addr}")
    os.makedirs(out, exist_ok=True)
    with open(os.path.join(out, "metadata.json"), "w") as fh:
        json.dump(sc, fh, indent=1)
    abi = sc.get("abi")
    if abi:
        with open(os.path.join(out, "abi.json"), "w") as fh:
            json.dump(abi, fh, indent=1)

    files = {}
    if sc.get("file_path") and sc.get("source_code"):
        files[sc["file_path"]] = sc["source_code"]
    for extra in sc.get("additional_sources") or []:
        files[extra["file_path"]] = extra["source_code"]
    for path, src in files.items():
        dest = os.path.join(out, "sources", path.lstrip("/"))
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with open(dest, "w") as fh:
            fh.write(src)

    events, state, view = [], [], []
    for entry in abi or []:
        if entry.get("type") == "event":
            sig = ",".join(i["type"] for i in entry.get("inputs", []))
            events.append(f"{entry['name']}({sig})")
        elif entry.get("type") == "function":
            sig = f"{entry['name']}({','.join(i['type'] for i in entry.get('inputs', []))})"
            target = view if entry.get("stateMutability") in ("view", "pure") else state
            target.append(sig)

    impls = [i.get("address_hash") for i in (ad.get("implementations") or [])]
    lines = [
        f"# {role} - {addr}\n",
        "Chain: Robinhood Chain (4663).",
        f"Blockscout: https://robinhoodchain.blockscout.com/address/{addr}",
        f"Role: {role}.",
        f"Contract name: {name}.",
        # Verification flag from `addresses`, sources from `smart-contracts`.
        f"Verified: {ad.get('is_verified')} (verified at {sc.get('verified_at')}).",
        f"Compiler: {sc.get('compiler_version')}, EVM {sc.get('evm_version')}, "
        f"optimizer {sc.get('optimization_enabled')} runs {sc.get('optimization_runs')}.",
        f"Main file: {sc.get('file_path')}.",
        f"Source files written: {len(files)} under `sources/`.",
        f"Creator: {ad.get('creator_address_hash')}.",
        f"Creation tx: {ad.get('creation_transaction_hash')}.",
        f"Proxy type: {ad.get('proxy_type')}; implementations: {impls}.",
    ]
    if note:
        lines += ["", note]
    lines.append("\n## Constructor arguments\n")
    ctor = sc.get("decoded_constructor_args") or []
    if ctor:
        lines += [f"- `{meta.get('name')}` ({meta.get('type')}): `{val}`" for val, meta in ctor]
    else:
        lines.append("None decoded.")
    for title, items in (
        ("Events", events),
        ("State-changing functions", state),
        ("View functions", view),
    ):
        lines.append(f"\n## {title}\n")
        lines += [f"- `{i}`" for i in sorted(set(items))] or ["None."]
    with open(os.path.join(out, "README.md"), "w") as fh:
        fh.write("\n".join(lines) + "\n")

    print(f"{role} {addr} verified={ad.get('is_verified')} files={len(files)} proxy={ad.get('proxy_type')}")
    return True


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--slug", required=True, help="launchpads/<slug> to write into")
    ap.add_argument("--role", help="role name; omit to read role|addr|note lines from stdin")
    ap.add_argument("--addr")
    ap.add_argument("--note", default="")
    ap.add_argument("--force", action="store_true", help="refetch even if cached")
    args = ap.parse_args()

    if args.role and args.addr:
        build(args.slug, args.role, args.addr, args.note, args.force)
        return
    for line in sys.stdin:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split("|")
        build(args.slug, parts[0], parts[1], parts[2] if len(parts) > 2 else "", args.force)


if __name__ == "__main__":
    main()
