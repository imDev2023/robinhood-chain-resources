#!/usr/bin/env python3
"""Build a contracts/<Role>-<address>/ directory for the Flap archive.

Fetches Blockscout v2 `addresses/<a>` and `smart-contracts/<a>` (a browser
User-Agent is required or Cloudflare returns an interstitial), then writes:

  address.json          the addresses/ response
  metadata.json         the smart-contracts/ response
  abi.json, sources/    when verified
  bytecode.hex          when not verified
  selectors.txt         PUSH4 scan of the runtime bytecode
  selectors-openchain.json / selectors-decoded.txt  resolved names

Usage:  python3 mkcontract.py <Role> <address> [<Role> <address> ...]
"""
import json, os, re, sys, urllib.request

UA = ("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/128.0 Safari/537.36")
B = "https://robinhoodchain.blockscout.com/api/v2"
RPC = os.environ.get("ALCHEMY_MAINNET_URL") or "https://app.doppler.lol/api/rpc/4663"
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "contracts")


def get(url):
    r = urllib.request.Request(url, headers={"User-Agent": UA})
    return json.loads(urllib.request.urlopen(r, timeout=60).read())


def code(addr):
    body = json.dumps({"jsonrpc": "2.0", "id": 1, "method": "eth_getCode",
                       "params": [addr, "latest"]}).encode()
    r = urllib.request.Request(RPC, data=body, headers={"content-type": "application/json"})
    return json.loads(urllib.request.urlopen(r, timeout=60).read())["result"]


def selectors(hexcode):
    b = bytes.fromhex(hexcode[2:] if hexcode.startswith("0x") else hexcode)
    out, i = [], 0
    while i < len(b):
        op = b[i]
        if op == 0x63 and i + 5 <= len(b):
            out.append(b[i + 1:i + 5].hex())
            i += 5
            continue
        if 0x60 <= op <= 0x7f:
            i += 1 + (op - 0x5f)
            continue
        i += 1
    return sorted(set(out))


def openchain(sels):
    if not sels:
        return {}
    q = "&".join("function=0x" + s for s in sels)
    try:
        return get("https://api.openchain.xyz/signature-database/v1/lookup?" + q)
    except Exception as e:  # network or rate limit
        return {"error": str(e)}


def build(role, addr):
    d = os.path.join(ROOT, f"{role}-{addr}")
    os.makedirs(d, exist_ok=True)
    a = get(f"{B}/addresses/{addr}")
    json.dump(a, open(os.path.join(d, "address.json"), "w"), indent=1)
    try:
        sc = get(f"{B}/smart-contracts/{addr}")
    except Exception:
        sc = {"message": "Not found"}
    json.dump(sc, open(os.path.join(d, "metadata.json"), "w"), indent=1)
    if sc.get("abi"):
        json.dump(sc["abi"], open(os.path.join(d, "abi.json"), "w"), indent=1)
    files = {}
    if sc.get("file_path") and sc.get("source_code"):
        files[sc["file_path"]] = sc["source_code"]
    for s in sc.get("additional_sources") or []:
        files[s["file_path"]] = s["source_code"]
    for path, src in files.items():
        p = os.path.join(d, "sources", path.lstrip("/"))
        os.makedirs(os.path.dirname(p), exist_ok=True)
        open(p, "w").write(src)
    c = code(addr)
    if not files:
        open(os.path.join(d, "bytecode.hex"), "w").write(c)
    sels = selectors(c)
    open(os.path.join(d, "selectors.txt"), "w").write("\n".join(sels) + "\n")
    oc = openchain(sels)
    json.dump(oc, open(os.path.join(d, "selectors-openchain.json"), "w"), indent=1)
    res = (oc.get("result") or {}).get("function") or {}
    with open(os.path.join(d, "selectors-decoded.txt"), "w") as f:
        for s in sels:
            names = res.get("0x" + s) or []
            f.write(f"0x{s} " + " | ".join(n["name"] for n in names) + "\n")
    print(f"{role}-{addr}: verified={bool(files)} sources={len(files)} selectors={len(sels)}")


if __name__ == "__main__":
    args = sys.argv[1:]
    for i in range(0, len(args), 2):
        build(args[i], args[i + 1])
