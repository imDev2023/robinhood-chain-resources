# Adapted from resources/launchpads/doppler/_raw/tools/mkcontract.py for the long archive.
# Accepts raw files named smart-contracts-<Role>-<addr>.json or smart-contracts-<addr>.json.
import json, os, sys
BASE = "/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/long"
def load(kind, role, addr):
    for p in (f"{BASE}/_raw/blockscout/{kind}-{role}-{addr}.json", f"{BASE}/_raw/blockscout/{kind}-{addr}.json"):
        if os.path.exists(p): return json.load(open(p))
    return {}
def build(role, addr, note=""):
    addr = addr.lower()
    sc = load("smart-contracts", role, addr); ad = load("addresses", role, addr)
    name = sc.get("name") or ad.get("name") or role
    d = f"{BASE}/contracts/{role}-{addr}"
    os.makedirs(d, exist_ok=True)
    json.dump(sc, open(f"{d}/metadata.json","w"), indent=1)
    abi = sc.get("abi")
    if abi: json.dump(abi, open(f"{d}/abi.json","w"), indent=1)
    files = {}
    if sc.get("file_path") and sc.get("source_code"): files[sc["file_path"]] = sc["source_code"]
    for s in (sc.get("additional_sources") or []): files[s["file_path"]] = s["source_code"]
    for p, src in files.items():
        fp = os.path.join(d, "sources", p.lstrip("/")); os.makedirs(os.path.dirname(fp), exist_ok=True); open(fp,"w").write(src)
    if not files and sc.get("deployed_bytecode"):
        open(f"{d}/bytecode.hex","w").write(sc["deployed_bytecode"])
    ctor = sc.get("decoded_constructor_args") or []
    evs, state, view = [], [], []
    for e in (abi or []):
        if e.get("type") == "event": evs.append(f"{e['name']}({','.join(i['type'] for i in e.get('inputs',[]))})")
        elif e.get("type") == "function":
            sig = f"{e['name']}({','.join(i['type'] for i in e.get('inputs',[]))})"
            (view if e.get("stateMutability") in ("view","pure") else state).append(sig)
    impls = [i.get("address_hash") or i.get("address") for i in (ad.get("implementations") or [])]
    L = [f"# {role} - {addr}\n", "Chain: Robinhood Chain (4663).", f"Blockscout: https://robinhoodchain.blockscout.com/address/{addr}", f"Role: {role}.", f"Contract name: {name}.",
         f"Verified: {sc.get('is_verified')} (verified at {sc.get('verified_at')}).",
         f"Compiler: {sc.get('compiler_version')}, EVM {sc.get('evm_version')}, optimizer {sc.get('optimization_enabled')} runs {sc.get('optimization_runs')}.",
         f"Main file: {sc.get('file_path')}.", f"Source files written: {len(files)} under `sources/`." if files else "Sources: none (unverified); `bytecode.hex` holds the deployed bytecode if Blockscout returned it.",
         f"Creator: {ad.get('creator_address_hash')}.", f"Creation tx: {ad.get('creation_transaction_hash')}.", f"Proxy type: {ad.get('proxy_type')}; implementations: {impls}."]
    if note: L += ["", note]
    L.append("\n## Constructor arguments\n")
    L += [f"- `{m.get('name')}` ({m.get('type')}): `{v}`" for v, m in ctor] or ["None decoded."]
    L.append("\n## Events\n"); L += [f"- `{e}`" for e in sorted(set(evs))] or ["None."]
    L.append("\n## State-changing functions\n"); L += [f"- `{e}`" for e in sorted(set(state))] or ["None."]
    L.append("\n## View functions\n"); L += [f"- `{e}`" for e in sorted(set(view))] or ["None."]
    open(f"{d}/README.md","w").write("\n".join(L) + "\n")
    print(role, addr, "verified", sc.get("is_verified"), "files", len(files))
if __name__ == "__main__":
    for line in sys.stdin:
        line = line.strip()
        if not line or line.startswith("#"): continue
        parts = line.split("|"); build(parts[0], parts[1], parts[2] if len(parts) > 2 else "")
