"""Build socials/NN-<slug>.md from the raw social captures, same header format as pages/."""
import os, re, json

BASE = "/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/virtuals"
RAW = f"{BASE}/_raw"
OUT = f"{BASE}/socials"
os.makedirs(OUT, exist_ok=True)
for f in os.listdir(OUT):
    os.remove(f"{OUT}/{f}")


def hdr(title, url, method):
    return f"# Virtuals Protocol - {title}\n\n> Source: {url}\n> Retrieved: 2026-09-02 ({method})\n\n---\n\n"


def jina_body(path):
    t = open(path).read()
    return t.split("Markdown Content:", 1)[1].strip() if "Markdown Content:" in t else t.strip()


# 1. X profile
prof = open(f"{RAW}/socials/x-virtuals_io-profile.bdata.md").read().strip()
open(f"{OUT}/01-x-virtuals-io-profile.md", "w").write(hdr("X profile @virtuals_io", "https://x.com/virtuals_io", "Bright Data scrape, markdown") +
    "Public metrics visible without login: 6,300 posts, 294.5K followers, 337 following, joined September 2021, bio \"Society of AI Agents\", link app.virtuals.io.\n"
    "The timeline itself is behind the X login wall, so only the profile header was captured.\n\n" + prof + "\n")

# 2. X posts (Bright Data x_posts pipeline)
posts = json.load(open(f"{RAW}/socials/x-posts-robinhood.json"))
posts = posts if isinstance(posts, list) else [posts]
L = [hdr("X posts about Robinhood Chain", "https://x.com/virtuals_io/status/2072660137794564521", "Bright Data x_posts pipeline, JSON in _raw/socials/x-posts-robinhood.json")]
L.append("Six post URLs were submitted (the two Robinhood Chain posts linked from the whitepaper, plus four found with `bdata search \"virtuals_io Robinhood Chain site:x.com\"`, raw in `_raw/socials/search-x-virtuals-robinhood.json`).\n")
L.append("The pipeline returned one record; the other five were not returned by Bright Data (no error, no data).\n")
L.append("The returned post is an X Article, so its body is not in the JSON, only the metrics.\n")
for p in posts:
    L.append(f"\n## {p.get('url')}\n")
    for k in ["user_posted", "name", "date_posted", "replies", "reposts", "likes", "views", "quotes", "bookmarks", "external_url", "followers", "posts_count", "biography", "is_verified", "verification_type"]:
        if p.get(k) not in (None, ""):
            L.append(f"- {k}: {p.get(k)}")
    L.append("- context: linked from whitepaper page \"Builders Resources for AI Agents\" as \"Agent tokenization on Robinhood Chain guide\" (pages/ file wp-about-virtuals-builders-resources-for-ai-agents), posted 2026-07-02, the day the first Robinhood Chain agent launched.")
L.append("\n## Other post URLs submitted (not returned)\n")
for u in ["https://x.com/celesteanglm/status/2073189495173001452 (Robinhood Chain use cases with the ACP CLI, linked from the whitepaper)", "https://x.com/virtuals_io/status/2073165193040048451", "https://x.com/virtuals_io/status/2073299312751284569", "https://x.com/virtuals_io/status/2082496431404028383", "https://x.com/virtuals_io/status/2094074417660010638"]:
    L.append(f"- {u}")
L.append("\nAn earlier attempt to pull the whole timeline with `bdata pipelines x_posts https://x.com/virtuals_io` failed with a validation error because that pipeline only accepts status URLs (`_raw/socials/x-virtuals_io-posts.err`).\n")
open(f"{OUT}/02-x-posts-robinhood.md", "w").write("\n".join(L))

# 3. Discord, 4. Telegram, 5. Substack, 6. Dune, 7. GitHub
items = [
    ("03-discord-invite.md", "Discord invite", "https://discord.com/invite/virtualsio", "ext-discord-com-invite-virtualsio.md", "Jina Reader"),
    ("04-telegram.md", "Telegram channel t.me/virtuals", "https://t.me/virtuals", "ext-t-me-virtuals.md", "Jina Reader"),
    ("05-substack.md", "Substack (virtuals.substack.com)", "https://virtuals.substack.com/", "ext-virtuals-substack-com.md", "Jina Reader"),
]
for fn, title, url, raw, method in items:
    open(f"{OUT}/{fn}", "w").write(hdr(title, url, method) + jina_body(f"{RAW}/jina/{raw}") + "\n")

d1 = jina_body(f"{RAW}/jina/ext-dune-com-virtuals_protocol.md")
d2 = jina_body(f"{RAW}/jina/ext-dune-com-virtual_protocol-virtual-protocol-on-base.md")
open(f"{OUT}/06-dune-dashboards.md", "w").write(hdr("Dune dashboards", "https://dune.com/virtuals_protocol", "Jina Reader") +
    "Two Dune pages: the team profile linked from the marketing site, and the \"Virtual Protocol on Base\" dashboard linked from the whitepaper Important Links page.\n"
    "Neither covers Robinhood Chain; Dune has no Robinhood Chain dataset as of the capture date.\n\n## https://dune.com/virtuals_protocol\n\n" + d1 +
    "\n\n## https://dune.com/virtual_protocol/virtual-protocol-on-base\n\n" + d2 + "\n")

repos = json.load(open(f"{RAW}/github/org-repos.json"))
commits = open(f"{RAW}/github/COMMITS.txt").read().strip()
gh = jina_body(f"{RAW}/jina/ext-github-com-Virtual-Protocol.md")
L = [hdr("GitHub organisation Virtual-Protocol", "https://github.com/Virtual-Protocol", "GitHub API JSON in _raw/github/org-repos.json plus Jina Reader")]
L.append(f"{len(repos)} public repositories. Clones used for this archive and their commits (from `_raw/github/COMMITS.txt`):\n\n```\n{commits}\n```\n")
L.append("| repo | stars | pushed | description |\n| --- | --- | --- | --- |")
for r in sorted(repos, key=lambda r: -(r.get("stargazers_count") or 0)):
    L.append(f"| [{r['name']}]({r['html_url']}) | {r.get('stargazers_count')} | {(r.get('pushed_at') or '')[:10]} | {(r.get('description') or '').replace('|', '/')} |")
L.append("\n## Rendered organisation page\n\n" + gh + "\n")
open(f"{OUT}/07-github-org.md", "w").write("\n".join(L))
print(sorted(os.listdir(OUT)))
