# Builds pages/NN-<slug>.md from the raw captures in _raw/.
# Each entry is (number, slug, url, retrieved, method, source file, note).
import os, sys
BASE = "/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/noxa"

PAGES = []

def add(slug, url, date, method, src, note=""):
    PAGES.append((slug, url, date, method, src, note))

def build():
    os.makedirs(f"{BASE}/pages", exist_ok=True)
    for i, (slug, url, date, method, src, note) in enumerate(PAGES, 1):
        p = f"{BASE}/_raw/{src}"
        if not os.path.exists(p):
            print("MISSING RAW", src); continue
        body = open(p, encoding="utf8", errors="replace").read()
        # Jina files repeat a Title/URL Source/Markdown Content preamble; keep it, it is verbatim output.
        out = f"# Noxa - {slug.replace('-', ' ')}\n\n> Source: {url}\n> Retrieved: {date} ({method})\n"
        if note:
            out += f">\n> Note: {note}\n"
        out += "\n---\n\n" + body.rstrip() + "\n"
        fn = f"{BASE}/pages/{i:02d}-{slug}.md"
        open(fn, "w").write(out)
    print("wrote", len(PAGES), "pages")

B = "2026-09-02"
T = "2026-09-03"
AB = "agent-browser read"
JN = "Jina Reader"

# fun.noxa.fi, the live V2 app
add("fun-home-trending", "https://fun.noxa.fi/", B, AB, "browser/fun-home-trending.txt")
add("fun-home-trending-loadmore", "https://fun.noxa.fi/", B, AB, "browser/fun-home-trending-loadmore.txt", "the same feed after clicking Load more")
add("fun-home-live", "https://fun.noxa.fi/?sort=live", B, AB, "browser/fun-home-live.txt")
add("fun-home-new", "https://fun.noxa.fi/?sort=new", B, AB, "browser/fun-home-new.txt")
add("fun-home-gainers", "https://fun.noxa.fi/?sort=gainers", B, AB, "browser/fun-home-gainers.txt")
add("fun-home-market-cap", "https://fun.noxa.fi/?sort=marketcap", B, AB, "browser/fun-home-market-cap.txt")
add("fun-home-volume", "https://fun.noxa.fi/?sort=volume", B, AB, "browser/fun-home-volume.txt")
add("fun-home-holders", "https://fun.noxa.fi/?sort=holders", B, AB, "browser/fun-home-holders.txt")
add("fun-home-trades", "https://fun.noxa.fi/?sort=trades", B, AB, "browser/fun-home-trades.txt")
add("fun-home-oldest", "https://fun.noxa.fi/?sort=oldest", B, AB, "browser/fun-home-oldest.txt")
add("fun-home-search-noxa", "https://fun.noxa.fi/?q=noxa", B, AB, "browser/fun-home-search-noxa.txt")
add("fun-home-jina", "https://fun.noxa.fi/", T, JN, "jina-2026-09-03/fun.noxa.fi.md", "recaptured on the report date, with every card link resolved")
add("fun-token-pcc", "https://fun.noxa.fi/token/0xbf3e53713a53e9c3d5d1ddc25dd2c65669244663", B, AB, "browser/fun-token-pcc.txt")
add("fun-token-pcc-snapshot", "https://fun.noxa.fi/token/0xbf3e53713a53e9c3d5d1ddc25dd2c65669244663", B, "agent-browser snapshot", "browser/fun-token-pcc-snapshot.txt")
add("fun-token-pcc-holders", "https://fun.noxa.fi/token/0xbf3e53713a53e9c3d5d1ddc25dd2c65669244663", B, AB, "browser/fun-token-pcc-holders.txt", "Holders tab")
add("fun-token-pcc-comments", "https://fun.noxa.fi/token/0xbf3e53713a53e9c3d5d1ddc25dd2c65669244663", B, AB, "browser/fun-token-pcc-comments.txt", "Comments tab")
add("fun-token-pcc-sell", "https://fun.noxa.fi/token/0xbf3e53713a53e9c3d5d1ddc25dd2c65669244663", B, AB, "browser/fun-token-pcc-sell.txt", "Sell side of the trade panel")
add("fun-token-cashcat", "https://fun.noxa.fi/token/0x020bfc650a365f8bb26819deaabf3e21291018b4", B, AB, "browser/fun-token-cashcat.txt")
add("fun-token-misshim", "https://fun.noxa.fi/token/0x0ec130c6258534663b67c131a5a6719b4f614663", B, AB, "browser/fun-token-misshim.txt")
add("fun-launch", "https://fun.noxa.fi/launch", B, AB, "browser/fun-launch.txt")
add("fun-launch-snapshot", "https://fun.noxa.fi/launch", B, "agent-browser snapshot", "browser/fun-launch-snapshot.txt")
add("fun-launch-filled", "https://fun.noxa.fi/launch", B, AB, "browser/fun-launch-filled.txt", "the form with every field filled in")
add("fun-launch-jina", "https://fun.noxa.fi/launch", T, JN, "jina-2026-09-03/fun.noxa.fi-launch.md", "recaptured on the report date; the page still offers a working launch form")
add("fun-bridge", "https://fun.noxa.fi/bridge", B, AB, "browser/fun-bridge.txt")
add("fun-bridge-anywallet", "https://fun.noxa.fi/bridge", B, AB, "browser/fun-bridge-anywallet.txt")
add("fun-bridge-snapshot", "https://fun.noxa.fi/bridge", B, "agent-browser snapshot", "browser/fun-bridge-snapshot.txt")
add("fun-bridge-from", "https://fun.noxa.fi/bridge", B, "agent-browser snapshot", "browser/fun-bridge-from-snapshot.txt", "source chain picker")
add("fun-profile", "https://fun.noxa.fi/profile", B, AB, "browser/fun-profile.txt")
add("fun-stats", "https://fun.noxa.fi/stats", B, AB, "browser/fun-stats.txt")
add("fun-docs", "https://fun.noxa.fi/docs", B, AB, "browser/fun-docs.txt")
add("fun-root-jina", "https://fun.noxa.fi/", B, JN, "jina-fun.noxa.fi-root.md")
add("fun-launch-jina-first", "https://fun.noxa.fi/launch", B, JN, "jina-fun.noxa.fi-launch.md")
add("fun-bridge-jina", "https://fun.noxa.fi/bridge", B, JN, "jina-fun.noxa.fi-bridge.md")
add("fun-profile-jina", "https://fun.noxa.fi/profile", B, JN, "jina-fun.noxa.fi-profile.md")
add("fun-stats-jina", "https://fun.noxa.fi/stats", B, JN, "jina-fun.noxa.fi-stats.md")
add("fun-docs-jina", "https://fun.noxa.fi/docs", B, JN, "jina-fun.noxa.fi-docs.md")
add("noxa-fi-root", "https://noxa.fi/", B, JN, "jina-noxa.fi.md", "noxa.fi redirects to fun.noxa.fi")
add("noxa-fi-docs", "https://noxa.fi/docs", B, JN, "jina-noxa.fi-docs.md")
add("noxa-fi-stats", "https://noxa.fi/stats", B, JN, "jina-noxa.fi-stats.md")

# The ENS/IPFS rescue interface
add("ens-fun-noxa-eth-limo", "https://fun.noxa.eth.limo/", B, JN, "jina-fun.noxa.eth.limo.md")
add("ens-fun-noxa-eth-limo-robinhood", "https://fun.noxa.eth.limo/#/robinhood", B, JN, "jina-fun.noxa.eth.limo-robinhood.md")
add("ens-fun-noxa-eth-link", "https://fun.noxa.eth.link/", B, JN, "jina-fun.noxa.eth.link.md")
add("ens-fun-noxa-eth-limo-today", "https://fun.noxa.eth.limo/", T, JN, "jina-2026-09-03/fun.noxa.eth.limo.md", "recaptured on the report date; still serving, still read-only")
add("ens-index-html", "https://fun.noxa.eth.limo/", T, "curl", "live-2026-09-03-fun.noxa.eth.limo.html", "the raw HTML shell, whose comments explain why the artifact carries no absolute URLs")

# noxa.io, the separate interface over a third contract set
add("noxa-io-root", "https://noxa.io/", B, JN, "jina-noxa.io-root.md")
add("noxa-io-robinhood", "https://noxa.io/robinhood", B, JN, "jina-noxa.io-robinhood.md")
add("noxa-io-robinhood-launch", "https://noxa.io/robinhood/launch", B, JN, "jina-noxa.io-robinhood-launch.md")
add("noxa-io-robinhood-noxa", "https://noxa.io/robinhood/noxa", B, JN, "jina-noxa.io-robinhood-noxa.md")
add("noxa-io-terms", "https://noxa.io/terms", B, JN, "jina-noxa.io-terms.md")
add("noxa-io-robinhood-today", "https://noxa.io/robinhood", T, JN, "jina-2026-09-03/noxa.io-robinhood.md", "recaptured on the report date; also still live and also offering a launch flow")

# docs.noxa.fi
add("docs-root", "https://docs.noxa.fi/", B, JN, "jina-docs.noxa.fi-root.md")
add("docs-introduction", "https://docs.noxa.fi/introduction/", B, JN, "jina-docs.noxa.fi-introduction.md")
add("docs-launchpad-overview", "https://docs.noxa.fi/launchpad/overview/", B, JN, "jina-docs.noxa.fi-launchpad-overview.md")
add("docs-launchpad-how-to-launch", "https://docs.noxa.fi/launchpad/how-to-launch/", B, JN, "jina-docs.noxa.fi-launchpad-how-to-launch.md")
add("docs-launchpad-chains", "https://docs.noxa.fi/launchpad/chains/", B, JN, "jina-docs.noxa.fi-launchpad-chains.md")
add("docs-dex-overview", "https://docs.noxa.fi/dex/overview/", B, JN, "jina-docs.noxa.fi-dex-overview.md")
add("docs-dex-trading", "https://docs.noxa.fi/dex/trading/", B, JN, "jina-docs.noxa.fi-dex-trading.md")
add("docs-dex-liquidity", "https://docs.noxa.fi/dex/liquidity/", B, JN, "jina-docs.noxa.fi-dex-liquidity.md")
add("docs-contracts-noxa-fun", "https://docs.noxa.fi/contracts/noxa-fun/", B, JN, "jina-docs.noxa.fi-contracts-noxa-fun.md")
add("docs-contracts-noxa-dex", "https://docs.noxa.fi/contracts/noxa-dex/", B, JN, "jina-docs.noxa.fi-contracts-noxa-dex.md")
add("docs-integrations-launchpad", "https://docs.noxa.fi/integrations/launchpad/", B, JN, "jina-docs.noxa.fi-integrations-launchpad.md")
add("docs-integrations-dex", "https://docs.noxa.fi/integrations/dex/", B, JN, "jina-docs.noxa.fi-integrations-dex.md")
add("docs-contracts-noxa-fun-today", "https://docs.noxa.fi/contracts/noxa-fun/", T, JN, "jina-2026-09-03/docs.noxa.fi-contracts-noxa-fun.md", "recaptured on the report date; the Robinhood row still names the disabled V1 factory")
add("dex-noxa-fi", "https://dex.noxa.fi/", B, JN, "jina-dex.noxa.fi.md", "the domain no longer resolves as of 2026-09-03")

# noxacto.xyz, a third-party CTO site
add("noxacto-root", "https://noxacto.xyz/", B, JN, "jina-noxacto.xyz.md", "returns HTTP 503 as of 2026-09-03")
add("noxacto-faq", "https://noxacto.xyz/faq", B, JN, "jina-noxacto.xyz-faq.md")
add("noxacto-launchpad", "https://noxacto.xyz/launchpad", B, JN, "jina-noxacto.xyz-launchpad.md")
add("noxacto-pool", "https://noxacto.xyz/pool", B, JN, "jina-noxacto.xyz-pool.md")
add("noxacto-team", "https://noxacto.xyz/team", B, JN, "jina-noxacto.xyz-team.md")
add("noxacto-wnoxa", "https://noxacto.xyz/wnoxa", B, JN, "jina-noxacto.xyz-wnoxa.md")

add("noxa-io-robinhood-launch-today", "https://noxa.io/robinhood/launch", T, AB, "browser/noxaio-launch-2026-09-03.txt", "recaptured on the report date; the form carries an \"Enabled\" badge and a live Connect Wallet to Launch button")
add("defillama-noxa-fun", "https://defillama.com/protocol/noxa-fun", B, JN, "jina-defillama-noxa-fun.md")

build()
