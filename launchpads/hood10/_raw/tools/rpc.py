# Minimal eth_call helper for the hood10 archive.
# Adapted from resources/launchpads/long/_raw/tools/rpc.py.
# Default RPC is the open Doppler proxy for chain 4663; launch.hood10.xyz/api/rpc
# refuses direct calls ("this endpoint serves the app, not direct calls").
import json, os, sys, urllib.request
from eth_abi import encode, decode
from eth_utils import keccak

RPC = os.environ.get("HOOD10_RPC") or os.environ.get("ALCHEMY_MAINNET_URL") or "https://app.doppler.lol/api/rpc/4663"

def raw(method, params):
    body = json.dumps({"jsonrpc": "2.0", "id": 1, "method": method, "params": params}).encode()
    req = urllib.request.Request(RPC, data=body, headers={"content-type": "application/json"})
    return json.loads(urllib.request.urlopen(req, timeout=60).read())

def call(to, sig, types_in, args, types_out):
    sel = keccak(text=sig)[:4]
    data = "0x" + (sel + encode(types_in, args)).hex()
    r = raw("eth_call", [{"to": to, "data": data}, "latest"])
    if "error" in r:
        return {"error": r["error"]}
    blob = bytes.fromhex(r["result"][2:])
    if not blob:
        return None
    return decode(types_out, blob)

if __name__ == "__main__":
    print(call(*json.loads(sys.argv[1])))
