"""Minimal eth_call helper for the Flap archive.

Usage as a library:
    from rpc import call
    call("0x26605f...", "getFeeRate()", [], [], ["uint256","uint256"])
"""
import json, os, sys, urllib.request
from eth_abi import encode, decode
from eth_utils import keccak

RPC = os.environ.get("ALCHEMY_MAINNET_URL") or "https://app.doppler.lol/api/rpc/4663"


def raw_call(to, data):
    body = json.dumps({"jsonrpc": "2.0", "id": 1, "method": "eth_call",
                       "params": [{"to": to, "data": data}, "latest"]}).encode()
    req = urllib.request.Request(RPC, data=body, headers={"content-type": "application/json"})
    return json.loads(urllib.request.urlopen(req, timeout=60).read())


def call(to, sig, types_in, args, types_out):
    sel = keccak(text=sig)[:4]
    data = "0x" + (sel + encode(types_in, args)).hex()
    r = raw_call(to, data)
    if "error" in r:
        return {"error": r["error"]}
    blob = bytes.fromhex(r["result"][2:])
    if not blob:
        return None
    return decode(types_out, blob)


if __name__ == "__main__":
    print(call(*json.loads(sys.argv[1])))
