import json,os,sys,re
RAW=sys.argv[1]; C=sys.argv[2]; addr=sys.argv[3]; role=sys.argv[4]
scf=f"{RAW}/blockscout-sc-{addr}.json"
d=json.load(open(scf))
if d.get('message') or not d.get('source_code'):
    print('no source for',addr,d.get('message')); sys.exit(0)
name=d.get('name') or 'Unknown'
out=f"{C}/{role}-{addr}"
os.makedirs(out+'/sources',exist_ok=True)
json.dump(d,open(out+'/metadata.json','w'),indent=1)
json.dump(d.get('abi'),open(out+'/abi.json','w'),indent=1)
def w(path,src):
    p=os.path.normpath(out+'/sources/'+path.lstrip('/'))
    if not p.startswith(os.path.normpath(out+'/sources')): p=out+'/sources/'+os.path.basename(path)
    os.makedirs(os.path.dirname(p),exist_ok=True); open(p,'w').write(src)
w(d.get('file_path') or f'{name}.sol', d['source_code'])
for s in d.get('additional_sources') or []: w(s['file_path'],s['source_code'])
n=1+len(d.get('additional_sources') or [])
abi=d.get('abi') or []
fns=[a for a in abi if a['type']=='function']; evs=[a for a in abi if a['type']=='event']
def sig(a): return a['name']+'('+', '.join(f"{i['type']} {i.get('name','')}".strip() for i in a.get('inputs',[]))+')'
ctor=d.get('decoded_constructor_args')
lines=[f"# {name} - {addr}","",f"Role: {role}.",f"Address: `{addr}` on Robinhood Chain (chain id 4663).",f"Blockscout: https://robinhoodchain.blockscout.com/address/{addr}",f"Verified: {d.get('is_verified')} (fully verified: {d.get('is_fully_verified')}, partially: {d.get('is_partially_verified')}).",f"Compiler: {d.get('compiler_version')}, EVM {d.get('evm_version')}, optimizer {d.get('optimization_enabled')} runs {d.get('optimization_runs')}.",f"Language: {d.get('language')}. License: {d.get('license_type')}.",f"Proxy type: {d.get('proxy_type')}. Implementations: {[i.get('address') or i.get('address_hash') for i in (d.get('implementations') or [])]}.",f"Main source file: `{d.get('file_path')}`. Source files written: {n} under `sources/`.",f"Raw constructor args: `{d.get('constructor_args')}`.",""]
if ctor:
    lines.append("Decoded constructor args:")
    for v,t in ctor: lines.append(f"- {t.get('name')} ({t.get('type')}): `{v}`")
    lines.append("")
lines.append("## Functions"); lines.append("")
for a in fns: lines.append(f"- `{sig(a)}` -> {', '.join(o['type'] for o in a.get('outputs',[]))} [{a.get('stateMutability')}]")
lines.append(""); lines.append("## Events"); lines.append("")
for a in evs: lines.append(f"- `{sig(a)}`")
lines.append(""); lines.append("Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.")
lines.append("See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.")
open(out+'/README.md','w').write('\n'.join(lines)+'\n')
print('wrote',out,'files',n)
