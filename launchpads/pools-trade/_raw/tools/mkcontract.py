import json, os, sys
BASE = "/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/pools-trade"

def build(role, addr, note=""):
    sc = json.load(open(f"{BASE}/_raw/blockscout/smart-contracts-{role}-{addr}.json"))
    ad = json.load(open(f"{BASE}/_raw/blockscout/addresses-{role}-{addr}.json"))
    if "message" in ad and "hash" not in ad:
        print("SKIP", role, addr, ad.get("message")); return
    name = sc.get("name") or ad.get("name") or role
    d = f"{BASE}/contracts/{role}-{addr}"
    os.makedirs(d, exist_ok=True)
    json.dump(sc, open(f"{d}/metadata.json","w"), indent=1)
    abi = sc.get("abi")
    if abi: json.dump(abi, open(f"{d}/abi.json","w"), indent=1)
    files = {}
    if sc.get("file_path") and sc.get("source_code"):
        files[sc["file_path"]] = sc["source_code"]
    for s in (sc.get("additional_sources") or []):
        files[s["file_path"]] = s["source_code"]
    for p, src in files.items():
        p = p.lstrip("/")
        fp = os.path.join(d, "sources", p)
        os.makedirs(os.path.dirname(fp), exist_ok=True)
        open(fp,"w").write(src)
    if not files:
        code = sc.get("creation_bytecode") or sc.get("deployed_bytecode") or ""
        if code: open(f"{d}/bytecode.hex","w").write(code)
    ctor = sc.get("decoded_constructor_args") or []
    evs, state, view = [], [], []
    for e in (abi or []):
        if e.get("type") == "event":
            evs.append(f"{e['name']}({','.join(i['type'] for i in e.get('inputs',[]))})")
        elif e.get("type") == "function":
            sig = f"{e['name']}({','.join(i['type'] for i in e.get('inputs',[]))})"
            (view if e.get("stateMutability") in ("view","pure") else state).append(sig)
    impls = [i.get("address_hash") for i in (ad.get("implementations") or [])]
    L = []
    L.append(f"# {role} - {addr}\n")
    L.append("Chain: Robinhood Chain (4663).")
    L.append(f"Blockscout: https://robinhoodchain.blockscout.com/address/{addr}")
    L.append(f"Role: {role}.")
    L.append(f"Contract name: {name}.")
    L.append(f"Verified: {ad.get('is_verified')} (sources from `smart-contracts`, flag from `addresses`).")
    L.append(f"Compiler: {sc.get('compiler_version')}, EVM {sc.get('evm_version')}, optimizer {sc.get('optimization_enabled')} runs {sc.get('optimization_runs')}.")
    L.append(f"Main file: {sc.get('file_path')}.")
    L.append(f"Source files written: {len(files)} under `sources/`.")
    L.append(f"Creator: {ad.get('creator_address_hash')}.")
    L.append(f"Creation tx: {ad.get('creation_transaction_hash')}.")
    L.append(f"Proxy type: {ad.get('proxy_type')}; implementations: {impls}.")
    if note:
        L.append("")
        L.append(note)
    L.append("\n## Constructor arguments\n")
    if ctor:
        for v, m in ctor:
            L.append(f"- `{m.get('name')}` ({m.get('type')}): `{v}`")
    else:
        L.append("None decoded.")
    L.append("\n## Events\n")
    L += [f"- `{e}`" for e in sorted(set(evs))] or ["None."]
    L.append("\n## State-changing functions\n")
    L += [f"- `{e}`" for e in sorted(set(state))] or ["None."]
    L.append("\n## View functions\n")
    L += [f"- `{e}`" for e in sorted(set(view))] or ["None."]
    open(f"{d}/README.md","w").write("\n".join(L) + "\n")
    print(role, addr, "verified", ad.get("is_verified"), "files", len(files))

if __name__ == "__main__":
    for line in sys.stdin:
        line = line.strip()
        if not line: continue
        parts = line.split("|")
        build(parts[0], parts[1], parts[2] if len(parts) > 2 else "")
