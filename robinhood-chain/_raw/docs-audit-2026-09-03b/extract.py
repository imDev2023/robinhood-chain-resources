import re, sys, os, urllib.parse, json
src = sys.argv[1]; out = sys.argv[2]
d = open(src, encoding='utf-8', errors='replace').read()
os.makedirs(out, exist_ok=True)
pat = re.compile(r'path:"(?P<path>[^"]*)",type:"(?P<type>[^"]*)",filePath:"(?P<fp>[^"]*)",content:"(?P<c>(?:[^"\\]|\\.)*)"')
rows = []
for m in pat.finditer(d):
    path, fp, enc = m.group('path'), m.group('fp'), m.group('c')
    enc = enc.encode().decode('unicode_escape')
    try:
        txt = urllib.parse.unquote(enc)
    except Exception as e:
        txt = enc
    name = fp.replace('/', '_').replace('.mdx', '') + '.mdx'
    open(os.path.join(out, name), 'w', encoding='utf-8').write(txt)
    rows.append({'path': path, 'filePath': fp, 'file': name, 'bytes': len(txt.encode())})
rows.sort(key=lambda r: r['path'])
open(os.path.join(out, '..', 'routes-from-bundle.txt'), 'w').write('\n'.join(r['path'] for r in rows) + '\n')
open(os.path.join(out, '..', 'route-table.json'), 'w').write(json.dumps(rows, indent=2))
print(f'{len(rows)} routes extracted')
for r in rows: print(f"{r['bytes']:>7}  {r['path']}  -> {r['file']}")
