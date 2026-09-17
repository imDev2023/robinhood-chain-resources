"""Generate pages/NN-<slug>.md for the Virtuals archive from the raw captures.

Order: whitepaper (English, llms.txt order), whitepaper translations (zh, ko),
marketing pages (Jina), app views (agent-browser read text), external pages (Jina), PDFs.
The header format is the one required by SCRAPING-PLAN.md part 4.1.
GitBook pages: the leading llms.txt hint line and the trailing "# Agent Instructions"
GitBook footer are removed because they are wrapper boilerplate, not page content.
"""
import os, re, json, glob, shutil

BASE = "/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/virtuals"
RAW = f"{BASE}/_raw"
OUT = f"{BASE}/pages"
DATE = "2026-09-02"
PLATFORM = "Virtuals Protocol"

if os.path.isdir(OUT):
    shutil.rmtree(OUT)
os.makedirs(OUT)

index = []  # (file, url, title, method, raw)
n = 0


def slugify(s):
    s = re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")
    return s[:70] or "page"


def write(title, url, method, body, raw, slug=None):
    global n
    n += 1
    slug = slug or slugify(title)
    fn = f"{n:03d}-{slug}.md"
    with open(f"{OUT}/{fn}", "w") as f:
        f.write(f"# {PLATFORM} - {title}\n\n> Source: {url}\n> Retrieved: {DATE} ({method})\n\n---\n\n{body.rstrip()}\n")
    index.append((fn, url, title, method, raw))
    return fn


def gitbook_body(text):
    lines = text.split("\n")
    if lines and lines[0].startswith("> For the complete documentation index"):
        lines = lines[1:]
    text = "\n".join(lines)
    text = re.split(r"\n---\n# Agent Instructions\n", text)[0]
    return text.strip()


def first_heading(text, default):
    m = re.search(r"^# (.+)$", text, re.M)
    return m.group(1).strip() if m else default


# 1. whitepaper English pages in llms.txt order
llms = open(f"{RAW}/jina/whitepaper-llms.txt").read()
order = re.findall(r"\[([^\]]+)\]\((https://whitepaper\.virtuals\.io/[^)]*?)\.md\)", llms)
seen = set()
sitemap = re.findall(r"<loc>([^<]*)", open(f"{RAW}/jina/whitepaper-sitemap-pages.xml").read())
wpdir = f"{RAW}/jina/whitepaper"


def wp_file(url):
    p = url.replace("https://whitepaper.virtuals.io", "").strip("/")
    return (p.replace("/", "__") if p else "index") + ".md"


def add_wp(url, fallback_title):
    fn = wp_file(url)
    path = f"{wpdir}/{fn}"
    if fn in seen or not os.path.exists(path):
        return
    seen.add(fn)
    text = open(path).read()
    body = gitbook_body(text)
    title = first_heading(body, fallback_title)
    slug = slugify(url.replace("https://whitepaper.virtuals.io", "").strip("/") or "whitepaper-home")
    write(title, url, "GitBook .md endpoint via curl", body, f"_raw/jina/whitepaper/{fn}", "wp-" + slug)


add_wp("https://whitepaper.virtuals.io/", "Virtuals Protocol Whitepaper")
add_wp("https://whitepaper.virtuals.io/about-virtuals", "About Virtuals")
for title, url in order:
    add_wp(url, title)
for url in sitemap:
    add_wp(url, url.rsplit("/", 1)[-1])

# 2. translations (zh, ko) that exist on disk but are not in the sitemap
for fn in sorted(os.listdir(wpdir)):
    if fn in seen or "?" in fn or not fn.endswith(".md"):
        continue
    if fn.startswith(("virtuals-bai-pi-shu", "virtuals-protocol-whitepaper-ko")):
        seen.add(fn)
        url = "https://whitepaper.virtuals.io/" + fn[:-3].replace("__", "/")
        body = gitbook_body(open(f"{wpdir}/{fn}").read())
        title = first_heading(body, fn[:-3])
        lang = "zh" if fn.startswith("virtuals-bai") else "ko"
        write(title, url, "GitBook .md endpoint via curl", body, f"_raw/jina/whitepaper/{fn}", f"wp-{lang}-" + slugify(fn[:-3].split("__")[-1]))

# 2b. hidden whitepaper pages found by following internal links (not in sitemap or llms.txt)
for fn in sorted(os.listdir(wpdir)):
    if fn in seen or "?" in fn or not fn.endswith(".md"):
        continue
    text = open(f"{wpdir}/{fn}").read()
    if text.startswith("# Page Not Found") or len(text) < 50:
        seen.add(fn)
        continue
    seen.add(fn)
    url = "https://whitepaper.virtuals.io/" + fn[:-3].replace("__", "/")
    body = gitbook_body(text)
    title = first_heading(body, fn[:-3])
    lang = "zh-" if fn.startswith("virtuals-bai") else ("ko-" if fn.startswith("virtuals-protocol-whitepaper-ko") else "")
    write(title, url, "GitBook .md endpoint via curl (page not in sitemap, found by following internal links)", body, f"_raw/jina/whitepaper/{fn}", f"wp-{lang}hidden-" + slugify(fn[:-3].split("__")[-1]))

leftover = [f for f in os.listdir(wpdir) if f not in seen]
print("whitepaper leftovers (not paged):", leftover)


# 3. marketing pages (Jina)
def jina_meta(text):
    t = re.search(r"^Title: (.*)$", text, re.M)
    u = re.search(r"^URL Source: (.*)$", text, re.M)
    body = text.split("Markdown Content:", 1)[1] if "Markdown Content:" in text else text
    return (t.group(1).strip() if t else ""), (u.group(1).strip() if u else ""), body.strip()


for fn, slug in [("www-home.md", "www-home"), ("www-researches.md", "www-researches")]:
    text = open(f"{RAW}/jina/{fn}").read()
    title, url, body = jina_meta(text)
    write(title or slug, url, "Jina Reader", body, f"_raw/jina/{fn}", slug)

# 4. app views (agent-browser read text + screenshot reference)
shots = sorted(os.listdir(f"{BASE}/screenshots"))


def shot_for(key):
    for s in shots:
        if s.split("-", 1)[1][:-4] == key:
            return s
    return None


APP_URLS = {
    "app-home": ("https://app.virtuals.io/", "Home (Capital Market)"),
    "app-robinhood-list": ("https://app.virtuals.io/", "Home, Robinhood Chain filter (Trending, Top, Gainers, New)"),
    "app-create": ("https://app.virtuals.io/create", "Create (login gate)"),
    "app-build": ("https://app.virtuals.io/build", "Build"),
    "app-dashboard": ("https://app.virtuals.io/dashboard", "Dashboard (veVIRTUAL, airdrops)"),
    "app-referral": ("https://app.virtuals.io/referral", "Referral"),
    "app-research-agent-commerce-protocol": ("https://app.virtuals.io/research/agent-commerce-protocol", "Research: Agent Commerce Protocol"),
    "app-login-modal": ("https://app.virtuals.io/", "Login modal"),
    "app-launch-token-click": ("https://app.virtuals.io/", "Launch Token click (login gate)"),
    "app-create-agent-click": ("https://app.virtuals.io/", "Create Agent click (login gate)"),
    "app-agentic-commerce-menu": ("https://app.virtuals.io/", "Agentic Commerce menu"),
    "app-acp-butler": ("https://app.virtuals.io/acp/butler", "ACP Butler"),
    "app-acp-scan-agents": ("https://app.virtuals.io/acp/scan/agents", "ACP Scan: Agents"),
    "app-acp-scan-offerings": ("https://app.virtuals.io/acp/scan/offerings", "ACP Scan: Offerings"),
    "whitepaper-home": ("https://whitepaper.virtuals.io/", "Whitepaper home (rendered)"),
    "www-home": ("https://www.virtuals.io/", "Marketing home (rendered)"),
    "www-researches": ("https://www.virtuals.io/researches", "Researches (rendered)"),
}

reads = sorted(glob.glob(f"{RAW}/network/read-*.txt"))


def read_key(path):
    return os.path.basename(path)[5:-4]


# order app views: home, robinhood list, agents by id, then the rest
def app_sort(path):
    k = read_key(path)
    if k == "app-home":
        return (0, 0, k)
    if k == "app-robinhood-list":
        return (1, 0, k)
    m = re.match(r"app-agent-(\d+)", k)
    if m:
        return (2, int(m.group(1)), k)
    return (3, 0, k)


for path in sorted(reads, key=app_sort):
    key = read_key(path)
    if key in ("app-agent-96200", "legacy-home"):
        continue  # duplicate of app-agent-96200-vex; legacy-home is written in section 5e
    body = open(path).read().strip()
    m = re.match(r"app-agent-(\d+)-(.+)", key)
    if m:
        url = f"https://app.virtuals.io/virtuals/{m.group(1)}"
        title = f"Agent page {m.group(1)} ({m.group(2).upper()})"
    else:
        url, title = APP_URLS.get(key, (f"https://app.virtuals.io/{key}", key))
    extras = []
    for s in shots:
        stem = s.split("-", 1)[1][:-4]
        if stem == key or stem.startswith(key + "-") or (key == "app-agent-96200-vex" and stem == "app-agent-96200-vex"):
            extras.append(f"Screenshot: screenshots/{s}")
    snap = f"{RAW}/network/snapshot-{key}.txt"
    if os.path.exists(snap):
        extras.append(f"Interactive snapshot: _raw/network/snapshot-{key}.txt")
    req = f"{RAW}/network/requests-{key}.txt"
    if os.path.exists(req):
        extras.append(f"Network requests: _raw/network/requests-{key}.txt")
    full = ("\n".join(extras) + "\n\n" if extras else "") + body
    slug = ("rendered-" + key) if key in ("www-home", "www-researches", "whitepaper-home") else key
    write(title, url, "agent-browser read, session lp-virtuals", full, f"_raw/network/read-{key}.txt", slug)

# 4b. snapshot-only view (menu state with no read capture)
if os.path.exists(f"{RAW}/network/snapshot-app-agentic-commerce-menu.txt"):
    body = "Screenshot: screenshots/38-app-agentic-commerce-menu.png\nInteractive snapshot: _raw/network/snapshot-app-agentic-commerce-menu.txt\n\nThe Agentic Commerce menu opened from the app header; the interactive snapshot below is the only text capture of this state.\n\n```\n" + open(f"{RAW}/network/snapshot-app-agentic-commerce-menu.txt").read().strip() + "\n```"
    write("Agentic Commerce menu", "https://app.virtuals.io/", "agent-browser snapshot, session lp-virtuals", body, "_raw/network/snapshot-app-agentic-commerce-menu.txt", "app-agentic-commerce-menu")

# 5. external pages (Jina)
for path in sorted(glob.glob(f"{RAW}/jina/ext-*.md")):
    text = open(path).read()
    title, url, body = jina_meta(text)
    fn = os.path.basename(path)
    if "retry" in fn or fn == "ext-legacy-virtuals-io.md":
        continue
    if len(body) < 120 or body.startswith('{"data":null'):
        body = body + "\n\nCapture note: the page returned no content on 2026-09-02. The retry capture is in _raw/jina/" + fn[:-3] + ".retry.md and was equally empty (docs.game.virtuals.io is an empty GitBook shell, acp.virtuals.io does not resolve in DNS)."
    write(title or fn[4:-3], url, "Jina Reader", body, f"_raw/jina/{fn}", "ext-" + fn[4:-3])

# 5b. EconomyOS docs (os.virtuals.io, Jina; the site has no .md endpoint and llms-full.txt has no page delimiters)
for path in sorted(glob.glob(f"{RAW}/os/jina-*.md")):
    text = open(path).read()
    title, url, body = jina_meta(text)
    fn = os.path.basename(path)
    body = "Whole-site text dump: _raw/os/llms-full.txt (175 KB, all pages) and _raw/os/llms.txt (nav).\n\n" + body
    write(("EconomyOS: " + title) if title else fn, url, "Jina Reader", body, f"_raw/os/{fn}", "os-" + fn[5:-3])

# 5c. degen.virtuals.io docs, build, terms (Jina)
for path in sorted(glob.glob(f"{RAW}/degen/*.md")):
    text = open(path).read()
    title, url, body = jina_meta(text)
    fn = os.path.basename(path)
    write(("Degen: " + title) if title else fn, url, "Jina Reader", body, f"_raw/degen/{fn}", "degen-" + fn[:-3])

# 5d. governance forum (agent-browser)
GOV = {
    "gov-home": ("https://gov.virtuals.io/", "Governance forum home (proposal list)", "45-gov-home.png"),
    "proposal-114159049320": ("https://gov.virtuals.io/proposal/114159049320088981416633051769497309098912685542870398419330790013517149477918", "Governance proposal 114159...77918 (pending, empty)", "46-gov-proposal-114159049320.png"),
    "proposal-569967636290": ("https://gov.virtuals.io/proposal/56996763629027767054698714571712096750640983191659498948864059685705038611655", "Governance proposal: Allocation of 1 percent VIRTUAL for Sniper Defense and Yield Fund", "47-gov-proposal-569967636290.png"),
    "proposal-582382599697": ("https://gov.virtuals.io/proposal/58238259969716106252633733975150732933829817308503391581801496289223305313092", "Governance proposal: Establishing an Ecosystem Growth Foundation", "48-gov-proposal-582382599697.png"),
    "proposal-858630801508": ("https://gov.virtuals.io/proposal/85863080150801247354820503347649561342766624974699481992117779927201501850460", "Governance proposal: Performance-based Ecosystem Grant to Virgen Labs", "49-gov-proposal-858630801508.png"),
}
for key, (url, title, shot) in GOV.items():
    path = f"{RAW}/gov/read-{key}.txt"
    if not os.path.exists(path):
        continue
    body = f"Screenshot: screenshots/{shot}\nInteractive snapshot: _raw/gov/snapshot-{key}.txt\n\n" + open(path).read().strip()
    write(title, url, "agent-browser read, session lp-virtuals", body, f"_raw/gov/read-{key}.txt", "gov-" + key)

# 5e. legacy.virtuals.io (agent-browser; Jina returned an empty shell)
if os.path.exists(f"{RAW}/network/read-legacy-home.txt"):
    body = "Screenshot: screenshots/50-legacy-home.png\nInteractive snapshot: _raw/network/snapshot-legacy-home.txt\n\n" + open(f"{RAW}/network/read-legacy-home.txt").read().strip()
    write("Legacy app (VIRTUAL to xVIRTUAL conversion, bridge)", "https://legacy.virtuals.io/", "agent-browser read, session lp-virtuals", body, "_raw/network/read-legacy-home.txt", "legacy-home")

# 6. PDFs
for name in ["launchpad_agreement", "terms_of_use", "privacy_policy", "acp_developer_agreement"]:
    text = open(f"{RAW}/pdf/{name}.md").read()
    title, url, body = jina_meta(text)
    write(title or name, url or f"https://app.virtuals.io/{name}.pdf", "Jina Reader (PDF)", body, f"_raw/pdf/{name}.md", "pdf-" + name.replace("_", "-"))

json.dump([dict(file=f, url=u, title=t, method=m, raw=r) for f, u, t, m, r in index], open(f"{RAW}/tools/pages-index.json", "w"), indent=1)
print("pages written:", n)
