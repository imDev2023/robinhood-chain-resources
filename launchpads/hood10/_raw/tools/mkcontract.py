# Generates contracts/<dir>/README.md for the hood10 archive.
# Adapted from resources/launchpads/long/_raw/tools/mkcontract.py.
# Differences: the hood10 contract dirs already exist and their metadata.json is
# sometimes the Blockscout addresses response and sometimes the smart-contracts
# response, so both are located by address instead of by a fixed filename.
import json, os, re, sys

BASE = "/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/hood10"
RAW = f"{BASE}/_raw/blockscout"

def _find(prefixes, addr):
    low = addr.lower()
    for f in os.listdir(RAW):
        if not f.endswith(".json"):
            continue
        if low not in f.lower():
            continue
        if any(f.lower().startswith(p) for p in prefixes):
            return json.load(open(os.path.join(RAW, f)))
    return {}

def _looks_like_sc(d):
    return isinstance(d, dict) and ("abi" in d or "deployed_bytecode" in d or "compiler_version" in d)

def _looks_like_addr(d):
    return isinstance(d, dict) and "creator_address_hash" in d

def build(d):
    path = os.path.join(BASE, "contracts", d)
    m = re.search(r"(0x[0-9a-fA-F]{40})$", d)
    if not m:
        print("skip (no address in dir name)", d)
        return
    addr = m.group(1)
    role = d[: m.start()].rstrip("-")

    sc, ad = {}, {}
    for fn in os.listdir(path):
        if fn.endswith(".json") and fn.startswith("metadata"):
            try:
                j = json.load(open(os.path.join(path, fn)))
            except Exception:
                continue
            if _looks_like_sc(j) and not sc:
                sc = j
            elif _looks_like_addr(j) and not ad:
                ad = j
    if not sc:
        sc = _find(("sc-", "smart-contracts-"), addr)
    if not ad:
        ad = _find(("address-",), addr)

    abi = sc.get("abi") or []
    if not abi and os.path.exists(os.path.join(path, "abi.json")):
        try:
            abi = json.load(open(os.path.join(path, "abi.json"))) or []
        except Exception:
            abi = []
    if abi and not os.path.exists(os.path.join(path, "abi.json")):
        json.dump(abi, open(os.path.join(path, "abi.json"), "w"), indent=1)

    srcs = []
    sd = os.path.join(path, "sources")
    for root, _, files in os.walk(sd):
        for f in files:
            srcs.append(os.path.relpath(os.path.join(root, f), path))

    evs, state, view = [], [], []
    for e in abi:
        if e.get("type") == "event":
            evs.append(f"{e['name']}({','.join(i['type'] for i in e.get('inputs', []))})")
        elif e.get("type") == "function":
            sig = f"{e['name']}({','.join(i['type'] for i in e.get('inputs', []))})"
            (view if e.get("stateMutability") in ("view", "pure") else state).append(sig)

    impls = [i.get("address_hash") or i.get("address") for i in (ad.get("implementations") or sc.get("implementations") or [])]
    ctor = sc.get("decoded_constructor_args") or []
    libs = sc.get("external_libraries") or []
    note = ""
    np = os.path.join(path, "NOTE.md")
    if os.path.exists(np):
        note = open(np).read().strip()

    L = [
        f"# {role} - {addr}",
        "",
        "Chain: Robinhood Chain (4663).",
        f"Blockscout: https://robinhoodchain.blockscout.com/address/{addr}",
        f"Role: {role}.",
        f"Contract name: {sc.get('name') or ad.get('name') or 'unknown (unverified)'}.",
        f"Verified: {sc.get('is_verified')} (verified at {sc.get('verified_at')}).",
        f"Compiler: {sc.get('compiler_version')}, EVM {sc.get('evm_version')}, optimizer {sc.get('optimization_enabled')} runs {sc.get('optimization_runs')}.",
        f"Main file: {sc.get('file_path')}.",
        (f"Source files on disk: {len(srcs)} under `sources/`."
         if srcs else "Sources: none (unverified); `bytecode.hex` holds the deployed bytecode."),
        f"Creator: {ad.get('creator_address_hash')}.",
        f"Creation tx: {ad.get('creation_transaction_hash')}.",
        f"Proxy type: {ad.get('proxy_type') or sc.get('proxy_type')}; implementations: {impls}.",
        f"External libraries: {[l.get('name') + ' @ ' + (l.get('address_hash') or '') for l in libs]}." if libs else "External libraries: none.",
    ]
    if note:
        L += ["", note]
    L += ["", "## Constructor arguments", ""]
    L += [f"- `{mm.get('name')}` ({mm.get('type')}): `{v}`" for v, mm in ctor] or ["None decoded."]
    L += ["", "## Events", ""]
    L += [f"- `{e}`" for e in sorted(set(evs))] or ["None."]
    L += ["", "## State-changing functions", ""]
    L += [f"- `{e}`" for e in sorted(set(state))] or ["None."]
    L += ["", "## View functions", ""]
    L += [f"- `{e}`" for e in sorted(set(view))] or ["None."]
    open(os.path.join(path, "README.md"), "w").write("\n".join(L) + "\n")
    print("wrote", d, "verified", sc.get("is_verified"), "abi", len(abi), "sources", len(srcs))

if __name__ == "__main__":
    dirs = sys.argv[1:] or sorted(os.listdir(os.path.join(BASE, "contracts")))
    for d in dirs:
        if os.path.isdir(os.path.join(BASE, "contracts", d)):
            build(d)
