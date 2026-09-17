#!/usr/bin/env python3
"""Re-run the 2026-09-02 Alchemy probes against Robinhood Chain (4663). Read-only."""
import json, os, urllib.request

URL = os.environ["ALCHEMY_MAINNET_URL"]
KEY = os.environ["ALCHEMY_API_KEY"]
NVDA = "0xd0601CE157Db5bdC3162BbaC2a2C8aF5320D9EEC"
HOLDER = "0x8366a39cc670b4001a1121b8f6a443a643e40951"

def post(url, body, hdrs=None):
    req = urllib.request.Request(url, data=json.dumps(body).encode(),
                                 headers={"content-type": "application/json", **(hdrs or {})})
    try:
        return urllib.request.urlopen(req, timeout=60).read().decode()
    except Exception as e:
        try:
            return e.read().decode()
        except Exception:
            return f"EXC {e}"

def get(url):
    try:
        return urllib.request.urlopen(urllib.request.Request(url), timeout=60).read().decode()
    except Exception as e:
        try:
            return e.read().decode()
        except Exception:
            return f"EXC {e}"

def rpc(method, params):
    return post(URL, {"jsonrpc": "2.0", "id": 1, "method": method, "params": params})

bn = json.loads(rpc("eth_blockNumber", []))["result"]
head = int(bn, 16)
out = []
def rec(label, text):
    out.append(f"{label}: {text[:400]}\n")
    print(f"{label}: {text[:220]}")

rec("eth_chainId", rpc("eth_chainId", []))
rec("web3_clientVersion", rpc("web3_clientVersion", []))
rec("eth_blockNumber", bn)
rec("alchemy_getTokenMetadata", rpc("alchemy_getTokenMetadata", [NVDA]))
rec("alchemy_getTokenBalances", rpc("alchemy_getTokenBalances", [HOLDER]))
rec("alchemy_getAssetTransfers", rpc("alchemy_getAssetTransfers", [{
    "fromBlock": "0x0", "toBlock": "latest", "category": ["erc20"],
    "contractAddresses": [NVDA], "maxCount": "0x3"}]))
rec("alchemy_getTransactionReceipts", rpc("alchemy_getTransactionReceipts", [{"blockNumber": hex(head - 100)}]))
rec("eth_getLogs 100k blocks", rpc("eth_getLogs", [{"fromBlock": hex(head - 100000), "toBlock": hex(head), "address": NVDA}]))
rec("eth_getLogs 10 blocks", rpc("eth_getLogs", [{"fromBlock": hex(head - 10), "toBlock": hex(head), "address": NVDA}]))
rec("trace_block", rpc("trace_block", [hex(head - 100)]))
rec("arbtrace_block", rpc("arbtrace_block", [hex(head - 100)]))
rec("debug_traceBlockByNumber", rpc("debug_traceBlockByNumber", [hex(head - 100), {"tracer": "callTracer"}]))
rec("debug_traceTransaction", rpc("debug_traceTransaction", ["0x6a064a091fe5b250ef56d55bcdf8ffdf373b95eef92c3c145ca876673f24f027", {"tracer": "callTracer"}]))
rec("alchemy_getTokenAllowance", rpc("alchemy_getTokenAllowance", [{"contract": NVDA, "owner": HOLDER, "spender": HOLDER}]))
rec("eth_feeHistory", rpc("eth_feeHistory", ["0x2", "latest", []]))

# Data API (REST) surfaces
rec("prices by-address", post(f"https://api.g.alchemy.com/prices/v1/{KEY}/tokens/by-address",
    {"addresses": [{"network": "robinhood-mainnet", "address": NVDA}]}))
rec("prices by-symbol", get(f"https://api.g.alchemy.com/prices/v1/{KEY}/tokens/by-symbol?symbols=ETH"))
rec("portfolio tokens by-address", post(f"https://api.g.alchemy.com/data/v1/{KEY}/assets/tokens/by-address",
    {"addresses": [{"address": HOLDER, "networks": ["robinhood-mainnet"]}]}))
rec("portfolio nfts by-address", post(f"https://api.g.alchemy.com/data/v1/{KEY}/assets/nfts/by-address",
    {"addresses": [{"address": HOLDER, "networks": ["robinhood-mainnet"]}]}))
rec("transactions history by-address", post(f"https://api.g.alchemy.com/data/v1/{KEY}/transactions/history/by-address",
    {"addresses": [{"address": HOLDER, "networks": ["robinhood-mainnet"]}], "limit": 2}))
rec("nft getNFTsForOwner", get(f"https://robinhood-mainnet.g.alchemy.com/nft/v3/{KEY}/getNFTsForOwner?owner={HOLDER}&pageSize=1"))
rec("nft getContractMetadata", get(f"https://robinhood-mainnet.g.alchemy.com/nft/v3/{KEY}/getContractMetadata?contractAddress=0x1292B64bEbF13eb7C34F3385Ab67fC64223d6332"))
rec("subgraphs endpoint", get("https://subgraph.satsuma-prod.com/status"))

open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "alchemy-tests.txt"), "w").writelines(out)
print("\nhead block:", head)
