#!/usr/bin/env python3
"""Re-run the 2026-09-02 Uniswap Developer (Trading) API probes for chain 4663. Read-only, nothing broadcast."""
import json, os, urllib.request, urllib.error

BASE = "https://trade-api.gateway.uniswap.org/v1"
KEY = os.environ["UNISWAP_DEVELOPER_API_KEY"]
UA = ("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/128.0 Safari/537.36")
# Cloudflare in front of trade-api.gateway.uniswap.org rejects the default
# Python-urllib user agent with HTTP 403 "error code: 1010".
H = {"x-api-key": KEY, "content-type": "application/json", "User-Agent": UA}
DEAD = "0x000000000000000000000000000000000000dEaD"
NATIVE = "0x0000000000000000000000000000000000000000"
NVDA = "0xd0601CE157Db5bdC3162BbaC2a2C8aF5320D9EEC"
WETH = "0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73"
here = os.path.dirname(os.path.abspath(__file__))

def call(path, body=None, method=None, hdrs=None):
    url = BASE + path
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, headers={**H, **(hdrs or {})}, method=method)
    try:
        r = urllib.request.urlopen(req, timeout=60)
        return r.status, r.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()
    except Exception as e:
        return 0, str(e)

log = []
def rec(name, code, body, save=None):
    log.append(f"{name}: {code}\n")
    print(name, code, body[:200])
    if save:
        open(os.path.join(here, save), "w").write(body)

quote_body = {"type": "EXACT_INPUT", "tokenInChainId": 4663, "tokenOutChainId": 4663,
              "tokenIn": NATIVE, "tokenOut": NVDA, "amount": "1000000000000000",
              "swapper": DEAD, "urgency": "normal"}
c, b = call("/quote", quote_body); rec("POST /quote (native->NVDA, 4663)", c, b, "uni-quote.json")
quote = json.loads(b) if c == 200 else None

c, b = call("/check_approval", {"walletAddress": DEAD, "token": NVDA,
                                "amount": "1000000000000000000", "chainId": 4663})
rec("POST /check_approval (NVDA, 4663)", c, b, "uni-approval.json")

if quote:
    c, b = call("/swap", {"quote": quote["quote"], "simulateTransaction": False})
    rec("POST /swap (from the quote above)", c, b, "uni-swap.json")
    if c == 200:
        t = json.loads(b).get("swap", {})
        log.append(f"  swap.to={t.get('to')} chainId={t.get('chainId')}\n")
        print("  swap.to =", t.get("to"), "chainId =", t.get("chainId"))

c, b = call("/quote", {**quote_body, "tokenIn": WETH, "tokenOut": NVDA})
rec("POST /quote (WETH->NVDA, 4663)", c, b)

c, b = call("/quote", {**quote_body}, hdrs={"x-universal-router-version": "2.0"})
rec("POST /quote with x-universal-router-version: 2.0", c, b)
c, b = call("/quote", {**quote_body}, hdrs={"x-universal-router-version": "2.1.1"})
rec("POST /quote with x-universal-router-version: 2.1.1", c, b)

c, b = call("/quote", {**quote_body}, hdrs={"x-api-key": "bogus"})
rec("POST /quote with a bad x-api-key", c, b)

c, b = call("/api.json", method="GET"); rec("GET /api.json (OpenAPI spec)", c, b[:0] or b, "uni-api.json")
c, b = call("/swaps?txHashes=0x0000000000000000000000000000000000000000000000000000000000000000&chainId=4663", method="GET")
rec("GET /swaps", c, b)
c, b = call("/lp/approve", {"walletAddress": DEAD, "chainId": 4663, "protocol": "V4",
                            "token0": NATIVE, "token1": NVDA, "amount0": "1", "amount1": "1"})
rec("POST /lp/approve", c, b)
c, b = call("/indicative_quote", {"type": "EXACT_INPUT", "amount": "1000000000000000",
                                  "tokenInChainId": 4663, "tokenOutChainId": 4663,
                                  "tokenIn": NATIVE, "tokenOut": NVDA})
rec("POST /indicative_quote", c, b)

open(os.path.join(here, "uni-tests.txt"), "w").writelines(log)
