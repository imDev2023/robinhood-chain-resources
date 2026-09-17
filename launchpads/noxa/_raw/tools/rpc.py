#!/usr/bin/env python3
"""Minimal eth_call helper for chain 4663. Usage: rpc.py <to> <sig> [args...]
Prints the raw hex result and, when the signature has a return spec after '->',
the decoded values. Written for the Noxa archive, 2026-09-03."""
import json, sys, urllib.request
try:
    from eth_utils import keccak
except Exception:
    from Crypto.Hash import keccak as _k
    def keccak(b):
        h = _k.new(digest_bits=256); h.update(b); return h.digest()
from eth_abi import encode as abienc, decode as abidec

RPC = "https://app.doppler.lol/api/rpc/4663"

def call(to, data, block="latest"):
    body = {"jsonrpc": "2.0", "id": 1, "method": "eth_call",
            "params": [{"to": to, "data": data}, block]}
    req = urllib.request.Request(RPC, json.dumps(body).encode(),
                                 {"content-type": "application/json"})
    return json.load(urllib.request.urlopen(req, timeout=30))

def selector(sig):
    return "0x" + keccak(sig.encode()).hex()[:8]

def main():
    to, sig = sys.argv[1], sys.argv[2]
    fn, _, rets = sig.partition("->")
    fn = fn.strip(); rets = rets.strip()
    argtypes = [t for t in fn[fn.index("(") + 1:fn.rindex(")")].split(",") if t]
    args = []
    for t, raw in zip(argtypes, sys.argv[3:]):
        args.append(int(raw, 0) if t.startswith(("uint", "int")) else raw)
    data = selector(fn)
    if args:
        data += abienc(argtypes, args).hex()
    out = call(to, data)
    if "error" in out:
        print("ERR", out["error"]); return
    res = out["result"]
    print(res)
    if rets:
        print(abidec([t for t in rets.strip("()").split(",") if t],
                     bytes.fromhex(res[2:])))

if __name__ == "__main__":
    main()
