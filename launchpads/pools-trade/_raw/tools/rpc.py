import json, sys, os, urllib.request
from eth_utils import keccak
from eth_abi import decode as abidec
RPC = os.environ.get("ALCHEMY_MAINNET_URL")
def call(to, sig, argtypes=(), args=(), outtypes=()):
    from eth_abi import encode as abienc
    sel = keccak(text=sig)[:4].hex()
    data = "0x" + sel + (abienc(list(argtypes), list(args)).hex() if argtypes else "")
    req = {"jsonrpc":"2.0","id":1,"method":"eth_call","params":[{"to":to,"data":data},"latest"]}
    r = urllib.request.urlopen(urllib.request.Request(RPC, json.dumps(req).encode(), {"content-type":"application/json"}))
    res = json.load(r)
    if "error" in res: return ("ERROR", res["error"].get("message"))
    raw = bytes.fromhex(res["result"][2:])
    if not outtypes: return res["result"]
    return abidec(list(outtypes), raw)
