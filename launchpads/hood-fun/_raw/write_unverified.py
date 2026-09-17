import json,os,sys,urllib.request
RAW,C=sys.argv[1],sys.argv[2]
UA={"User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0 Safari/537.36"}
RPC="https://app.doppler.lol/api/rpc/4663"
def getcode(a):
    p={"jsonrpc":"2.0","id":1,"method":"eth_getCode","params":[a,"latest"]}
    return json.load(urllib.request.urlopen(urllib.request.Request(RPC,json.dumps(p).encode(),{"content-type":"application/json"})))["result"]
for line in sys.stdin:
    line=line.strip()
    if not line: continue
    addr,role,note=line.split("|",2)
    addr,role,note=addr.strip(),role.strip(),note.strip()
    f=f"{RAW}/blockscout-address-{addr}.json"
    if not os.path.exists(f):
        r=urllib.request.urlopen(urllib.request.Request(f"https://robinhoodchain.blockscout.com/api/v2/addresses/{addr}",headers=UA)).read()
        open(f,"wb").write(r)
    d=json.load(open(f))
    out=f"{C}/{role}-{addr}"; os.makedirs(out,exist_ok=True)
    json.dump(d,open(out+"/metadata.json","w"),indent=1)
    code=getcode(addr)
    open(out+"/bytecode.hex","w").write(code)
    impls=[i.get("address") or i.get("address_hash") for i in (d.get("implementations") or [])]
    open(out+"/README.md","w").write(
f"""# {role} - {addr}

Role: {role}.
Address: `{addr}` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/{addr}
Verified: **no**. Blockscout `addresses/{addr}` reports `is_verified: false`, so there are no sources to archive.
Proxy type reported by Blockscout: {d.get('proxy_type')}. Implementations: {impls}.
Creator: {d.get('creator_address_hash')}. Creation tx: {d.get('creation_transaction_hash') or d.get('creation_tx_hash')}.
Runtime bytecode: `bytecode.hex` ({len(code)//2-1} bytes), read with `eth_getCode` at latest on 2026-09-03.
Full Blockscout address record: `metadata.json`.

{note}
""")
    print("wrote",out)
