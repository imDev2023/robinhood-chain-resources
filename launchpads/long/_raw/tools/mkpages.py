import os, re, json, glob
BASE="/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/long"
R=BASE+"/_raw"; P=BASE+"/pages"
os.makedirs(P, exist_ok=True)
for f in glob.glob(P+"/*.md"): os.remove(f)
manifest=[]
def jina_body(path):
    s=open(path,encoding="utf-8",errors="replace").read()
    i=s.find("Markdown Content:")
    body=s[i+len("Markdown Content:"):].strip() if i>=0 else s.strip()
    warn=[l for l in s[:i].splitlines() if l.startswith("Warning:")] if i>=0 else []
    return body, warn
def write(n, slug, title, url, method, body, note="", warnings=None, raw=None):
    fn=f"{n:02d}-{slug}.md"
    L=[f"# Long - {title}","",f"> Source: {url}",f"> Retrieved: 2026-09-02 ({method})"]
    if raw: L.append(f"> Raw capture: `{raw}`")
    L+=["","---",""]
    if note: L+=[note,""]
    if warnings: L+=["Capture warnings from the tool: "+"; ".join(w.replace('Warning: ','') for w in warnings),""]
    L.append(body)
    open(f"{P}/{fn}","w").write("\n".join(L).rstrip()+"\n")
    manifest.append((fn,title,url))
    return fn
n=0
def nxt():
    global n; n+=1; return n
# 1 app home
b,w=jina_body(R+"/jina/app-root.md")
snap=open(R+"/network/snapshot-01-home.txt").read().strip()
write(nxt(),"app-home","App home, app.long.xyz","https://app.long.xyz/","Jina Reader; agent-browser accessibility snapshot appended",b+"\n\n## Accessibility snapshot of the same view (agent-browser, before Cloudflare blocked the session)\n\n```text\n"+snap+"\n```\n\nScreenshot: `screenshots/01-app-home.png`.",warnings=w,raw="_raw/jina/app-root.md, _raw/network/snapshot-01-home.txt")
# 2 tokens
b,w=jina_body(R+"/jina/app-tokens.md")
write(nxt(),"app-tokens","Tokens list, the Robinhood Chain leaderboard","https://app.long.xyz/tokens","Jina Reader",b+"\n\nScreenshot: `screenshots/02-tokens.png`.\nEvery token address on this page is listed in `_raw/api/token-addresses-from-tokens-page.txt` and each has its own page below.",warnings=w,raw="_raw/jina/app-tokens.md")
# 3 create
b,w=jina_body(R+"/jina/app-create.md")
bd=open(R+"/bdata/app-create.md").read().strip()
write(nxt(),"app-create-wallet-gate","Create, the wallet gate","https://app.long.xyz/create","Jina Reader and Bright Data",b+"\n\n## Bright Data rendering of the same route\n\n```text\n"+bd+"\n```\n\nScreenshot: `screenshots/03-create.png`.\nThe create form renders nothing before a Privy wallet login (Privy app id `cmppfotax00ql0clcbz4vvt4b`, seen in `_raw/network/requests-01-home.json`).\nWhat the form submits is documented from the application bundle and from decoded production launches in `README.md` section 3, not from this view.",warnings=w,raw="_raw/jina/app-create.md, _raw/bdata/app-create.md")
# 4 longx
b,w=jina_body(R+"/jina/app-longx.md")
bd=open(R+"/bdata/app-longx.md").read().strip()
write(nxt(),"app-longx","LongX Vaults","https://app.long.xyz/longx","Jina Reader and Bright Data",b+"\n\n## Bright Data rendering, which also shows the 3x and 5x selector\n\n```text\n"+bd+"\n```\n\nScreenshot: `screenshots/04-longx.png`.",warnings=w,raw="_raw/jina/app-longx.md, _raw/bdata/app-longx.md")
# 5,6 base
b,w=jina_body(R+"/jina/app-base.md")
write(nxt(),"app-base-home","App home, Base chain variant","https://app.long.xyz/base","Jina Reader",b+"\n\nThe `/base` prefix switches the app to Long's original Base deployment (chain id 8453) per the chain config in `_raw/js/1d2db5e62a5a89a1.js`.\nThe landing view is identical to the Robinhood one.",warnings=w,raw="_raw/jina/app-base.md")
b,w=jina_body(R+"/jina/app-base-tokens.md")
write(nxt(),"app-base-tokens","Tokens list, Base chain variant","https://app.long.xyz/base/tokens","Jina Reader",b+"\n\nOut of scope for a Robinhood Chain launch; captured to show that the same app serves Long's earlier Base product, where launches pair against any Base token rather than a stock token.",warnings=w,raw="_raw/jina/app-base-tokens.md")
# token pages
def token_meta(body):
    m=re.search(r"\n\$([A-Z0-9]+)\n",body); sym=m.group(1) if m else "?"
    m2=re.search(r"Anchored to.*?\*\*([A-Za-z0-9]+)\*\*",body); num=m2.group(1) if m2 else "?"
    return sym,num
order=[("app-token-0x2e8c31162b855a2ffa90f6f8634643ad6f111e18.md","0x2e8c31162b855a2ffa90f6f8634643ad6f111e18"),("app-token-boner.md","0x98096d17e191b3da1d5f99a6d7b3584351b11e18"),("app-token-hiai.md","0x9d65690e811dbf4d269f53e522b4771dfe8e1e18"),("app-token-demothree.md","0xcc3dc6fc9918b9846d1ad5aaea740f8bed9a1e18")]
seen={a for _,a in order}
for f in sorted(glob.glob(R+"/jina/app-token-0x*.md")):
    a=os.path.basename(f)[len("app-token-"):-3]
    if a not in seen: order.append((os.path.basename(f),a)); seen.add(a)
shots={"0x2e8c31162b855a2ffa90f6f8634643ad6f111e18":"06-token-ai.png","0x98096d17e191b3da1d5f99a6d7b3584351b11e18":"05-token-boner.png"}
for fn,a in order:
    b,w=jina_body(R+"/jina/"+fn)
    sym,num=token_meta(b)
    extra=""
    if a in shots: extra+=f"\n\nScreenshot: `screenshots/{shots[a]}`."
    if a=="0x98096d17e191b3da1d5f99a6d7b3584351b11e18":
        extra+="\n\nTwo more Jina passes of this page (`_raw/jina/app-token2-boner.md`, `_raw/jina/app-token3-boner.md`) came back as loading stubs; the capture above is the complete one."
    write(nxt(),f"app-token-{sym.lower()}",f"Token page, ${sym} anchored to {num}",f"https://app.long.xyz/tokens/{a}","Jina Reader",b+extra,warnings=w,raw=f"_raw/jina/{fn}")
b,w=jina_body(R+"/jina/app-token-nvdax3l.md")
write(nxt(),"app-token-nvdax3l-loading","Token page for the NVDAx3L vault token, loading stub","https://app.long.xyz/tokens/0xF51fb54DE60f6e16252E852A5Ed0E60B8307606A","Jina Reader",b+"\n\nThe route accepts the LongX vault token address but never resolves it: NVDAx3L is not a Long launch, it is a vault share minted by `LongXVaultFactory`, so the token page has no launch to show.\nRecorded so nobody re-tries it.",warnings=w,raw="_raw/jina/app-token-nvdax3l.md")
# catch-all routes
routes=["docs","faq","leaderboard","portfolio","privacy","profile","rewards","settings","terms"]
parts=[]
for r in routes:
    b,w=jina_body(R+f"/jina/app-{r}.md")
    parts.append(f"## /{r}\n\nSize {os.path.getsize(R+f'/jina/app-{r}.md')} bytes; identical to the home view except for the URL.\n\n"+b)
b,w=jina_body(R+"/jina/app-llms.md")
parts.append("## /llms.txt\n\nReturns the Next.js 404 page.\n\n"+b)
write(nxt(),"app-catch-all-routes","Routes that render the home page, and llms.txt","https://app.long.xyz/{docs,faq,leaderboard,portfolio,privacy,profile,rewards,settings,terms,llms.txt}","Jina Reader, ten passes","The app has no docs, FAQ, leaderboard, portfolio, rewards, settings, terms or privacy route.\nEvery one of these paths renders the landing page, which means the app has a catch-all route rather than a 404 for unknown paths.\nThe real routes found are `/`, `/tokens`, `/tokens/<address>`, `/create`, `/longx`, and the `/base` prefix versions of `/`, `/tokens` and `/create`.\n\n"+"\n\n".join(parts),raw="_raw/jina/app-*.md")
# long.xyz
b,w=jina_body(R+"/jina/long-xyz-root.md")
write(nxt(),"long-xyz-home","long.xyz apex domain","https://long.xyz/","Jina Reader",b+"\n\nThe apex domain serves the same Next.js app as app.long.xyz; the only link on the page points at app.long.xyz.\nScreenshot: `screenshots/07-long-xyz-root.png`.",warnings=w,raw="_raw/jina/long-xyz-root.md")
parts=[]
for label,f in [("long.xyz/docs","long-xyz-docs.md"),("long.xyz/llms.txt","long-llms.md"),("www.long.xyz","www-long-xyz.md"),("docs.long.xyz","docs-root.md"),("docs.long.xyz/llms.txt","docs-llms.md")]:
    b,w=jina_body(R+"/jina/"+f); parts.append(f"## {label}\n\n"+(("Capture warnings: "+"; ".join(x.replace('Warning: ','') for x in w)+"\n\n") if w else "")+b)
parts.append("## join.long.xyz\n\n```text\n"+open(R+"/jina/join-long-xyz.md").read().strip()+"\n```")
write(nxt(),"long-xyz-other-domains","Other long.xyz hosts and paths: docs, www, join","https://long.xyz/docs, https://long.xyz/llms.txt, https://www.long.xyz/, https://docs.long.xyz/, https://join.long.xyz/","Jina Reader","Summary: `long.xyz/docs` and `long.xyz/llms.txt` fall into the app's catch-all and render the landing page; `www.long.xyz` is an unconfigured Framer site (404); `docs.long.xyz` is a deleted Vercel deployment (404 `DEPLOYMENT_NOT_FOUND`); `join.long.xyz` does not resolve in DNS.\nLong has no public documentation site as of 2026-09-02.\n\n"+"\n\n".join(parts),raw="_raw/jina/long-xyz-docs.md, _raw/jina/long-llms.md, _raw/jina/www-long-xyz.md, _raw/jina/docs-root.md, _raw/jina/docs-llms.md, _raw/jina/join-long-xyz.md")
# dune
b,w=jina_body(R+"/jina/dune-dashboard.md")
write(nxt(),"dune-dashboard-long-on-robinhood-chain","Dune dashboard, LONG on Robinhood Chain, by natan_benish2001","https://dune.com/natan_benish2001/long-on-robinhood-chain","Jina Reader",b+"\n\nScreenshot: `screenshots/08-dune-dashboard.png`.\nThe dashboard's counters are rendered client-side and did not come through; the `Stock Token Leaderboard` table did, and the queries behind every widget are captured as the following pages.",warnings=w,raw="_raw/jina/dune-dashboard.md")
qtitles={}
for f in sorted(glob.glob(R+"/dune/query-*.md")):
    qid=os.path.basename(f)[6:-3]
    s=open(f).read(); t=re.search(r"^Title: (.*?) \| Dune",s,re.M); title=t.group(1) if t else f"query {qid}"
    b,w=jina_body(f)
    slug=re.sub(r"[^a-z0-9]+","-",title.lower()).strip("-")[:50]
    write(nxt(),f"dune-query-{qid}-{slug}",f"Dune query {qid}, {title}",f"https://dune.com/queries/{qid}","Jina Reader",b,warnings=w,raw=f"_raw/dune/query-{qid}.md")
# x launch thread
b,w=jina_body(R+"/jina/x-status-launch-thread.md")
write(nxt(),"x-longdotxyz-launch-thread","X post, the Robinhood Chain launch announcement of 2026-07-14","https://x.com/longdotxyz/status/2077073135233609923","Jina Reader",b,warnings=w,raw="_raw/jina/x-status-launch-thread.md")
# rootdata
b,w=jina_body(R+"/jina/rootdata-long.md")
write(nxt(),"rootdata-long","RootData project page, blocked by a CAPTCHA","https://www.rootdata.com/projects/detail/Long?k=MTgwMDQ%3D","Jina Reader, Bright Data and Tavily all tried",b+"\n\nBright Data returned the same `Refreshing too often` interstitial (`_raw/bdata/rootdata-long.md`) and Tavily extract failed (`_raw/search/tvly-rootdata-long.json`).\nNothing from RootData is recoverable without a browser session that can pass its verification page.",warnings=w,raw="_raw/jina/rootdata-long.md, _raw/bdata/rootdata-long.md, _raw/search/tvly-rootdata-long.json")
# press
b,w=jina_body(R+"/jina/mexc-what-is-long-xyz.md")
write(nxt(),"mexc-what-is-long-xyz","MEXC Learn, What Is Long.xyz? How Stock-Paired Memecoins Are Reshaping Robinhood Chain","https://www.mexc.com/learn/article/what-is-long-xyz-how-stock-paired-memecoins-are-reshaping-robinhood-chain/1","Jina Reader",b,warnings=w,raw="_raw/jina/mexc-what-is-long-xyz.md")
b,w=jina_body(R+"/jina/htx-longx-expansion.md")
write(nxt(),"htx-blockbeats-longx-expansion","HTX feed, BlockBeats note on the LongX Expansion","https://www.htx.com/feed/community/21758366/?back=1","Jina Reader",b,warnings=w,raw="_raw/jina/htx-longx-expansion.md")
b,w=jina_body(R+"/jina/matcha-meta-ai.md")
write(nxt(),"matcha-meta-trade-ai","Matcha Meta DEX, the Trade link from every token page","https://meta.matcha.xyz/?chainId=4663&sellToken=0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee&buyToken=0x2e8c31162b855a2ffa90f6f8634643ad6f111e18","Jina Reader",b+"\n\nLong's token pages do not embed a swap; the `Trade on Matcha Meta DEX` button hands off to 0x's Matcha Meta aggregator with chain id 4663 preselected.",warnings=w,raw="_raw/jina/matcha-meta-ai.md")
b,w=jina_body(R+"/jina/defined-ai-chart.md")
write(nxt(),"defined-fi-chart-blocked","Defined.fi chart, the View chart link from every token page","https://www.defined.fi/robinhood/0xcbdfea90430a30ee4469c9902e120a77e7c7e4711d5643671c1d1957f2f1ce27","Jina Reader",b+"\n\nDefined.fi sits behind a Vercel security checkpoint that headless fetches cannot pass.\nThe app itself reads Defined's data through the Codex API key embedded in its bundle (`_raw/js/760859da30817643.js`, `CODEX_API_KEY`).",warnings=w,raw="_raw/jina/defined-ai-chart.md")
json.dump(manifest,open(R+"/pages-manifest.json","w"),indent=1)
print(len(manifest),"pages")
for m in manifest: print(m[0])
