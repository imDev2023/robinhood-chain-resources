import re, sys, os, difflib, json

MAP = {
 '01-overview.md':'chain_index.mdx',
 '02-connecting.md':'chain_connecting_index.mdx',
 '03-add-network-to-wallet.md':'chain_add-network-to-wallet_index.mdx',
 '04-bridging.md':'chain_bridging_index.mdx',
 '06-stock-tokens.md':'chain_stock-tokens_index.mdx',
 '07-building-with-stock-tokens.md':'chain_building-with-stock-tokens_index.mdx',
 '08-stock-token-apis.md':'chain_stock-token-apis_index.mdx',
 '12-differences-from-ethereum.md':'chain_differences-from-ethereum_index.mdx',
 '13-gas-and-fees.md':'chain_gas-and-fees_index.mdx',
 '14-transaction-finality.md':'chain_transaction-finality_index.mdx',
 '16-token-contracts.md':'chain_contracts_index.mdx',
 '17-protocol-contracts.md':'chain_protocol-contracts_index.mdx',
 '18-deploy-smart-contracts.md':'chain_deploy-smart-contracts_index.mdx',
 '19-account-abstraction.md':'chain_account-abstraction_index.mdx',
 '20-cross-chain-messaging.md':'chain_cross-chain-messaging_index.mdx',
 '21-oracles-and-price-feeds.md':'chain_oracles-and-price-feeds_index.mdx',
 '22-data-streams.md':'chain_data-streams_index.mdx',
 '26-run-a-full-node.md':'chain_run-a-full-node_index.mdx',
 '27-governance.md':'chain_governance_index.mdx',
 '28-notices-and-upgrades.md':'chain_notices-and-upgrades_index.mdx',
 '29-terms-of-service.md':'chain_terms-of-service_index.mdx',
 '30-report-issue.md':'chain_report-issue_index.mdx',
 '33-brand-guidelines.md':'chain_brand-guidelines_index.mdx',
}

ADDR = re.compile(r'0x[0-9a-fA-F]{40}')
URL  = re.compile(r'https?://[^\s)>\]"\'`,]+')
MAIL = re.compile(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}')
NUM  = re.compile(r'\b\d[\d,]*(?:\.\d+)?\s*(?:%|percent|seconds?|minutes?|hours?|days?|weeks?|months?|gwei|wei|eth|ETH|px|requests?/second|decimals?|bytes?)\b')
VER  = re.compile(r'\bv?\d+\.\d+\.\d+[\w.-]*\b')

def facts(t):
    d = {}
    d['addr'] = set(a.lower() for a in ADDR.findall(t))
    urls = set()
    for u in URL.findall(t):
        u = u.rstrip('.,;:').rstrip('/')
        if 'cdn.robinhood.com/assets' in u: continue   # logo/asset noise
        urls.add(u)
    d['url'] = urls
    d['mail'] = set(m.lower() for m in MAIL.findall(t) if not m.endswith('.svg'))
    d['num'] = set(re.sub(r'\s+',' ',n).lower() for n in NUM.findall(t))
    d['ver'] = set(VER.findall(t))
    return d

def strip_archive_header(t):
    # drop our own '# Title' + '> Source:' block up to the first '---' rule
    i = t.find('\n---\n')
    return t[i+5:] if 0 < i < 2000 else t

def norm_prose(t):
    t = re.sub(r'^---\n.*?\n---\n', '', t, flags=re.S)          # mdx frontmatter
    t = re.sub(r'```.*?```', ' ', t, flags=re.S)                 # code blocks
    t = re.sub(r'`[^`]*`', ' ', t)                               # inline code
    t = re.sub(r'<[^>]+>', ' ', t)                               # jsx/html tags
    t = re.sub(r'!\[[^\]]*\]\([^)]*\)', ' ', t)                  # images
    t = re.sub(r'\[([^\]]*)\]\([^)]*\)', r'\1', t)               # links -> text
    t = re.sub(r'[|*_#>~:\-]+', ' ', t)                          # md punctuation
    t = re.sub(r'\s+', ' ', t)
    return t.strip().lower()

def sentences(t):
    return [s.strip() for s in re.split(r'(?<=[.!?])\s+', t) if len(s.strip()) > 25]

if __name__ == '__main__':
    arch_dir = sys.argv[1]; mdx_dir = sys.argv[2]
    report = []
    for a, m in sorted(MAP.items()):
        ap = os.path.join(arch_dir, a); mp = os.path.join(mdx_dir, m)
        at = strip_archive_header(open(ap, encoding='utf-8').read())
        mt = open(mp, encoding='utf-8').read()
        af, mf = facts(at), facts(mt)
        entry = {'file': a, 'src': m, 'fact_delta': {}}
        for k in af:
            only_src = sorted(mf[k] - af[k]); only_arc = sorted(af[k] - mf[k])
            if only_src or only_arc:
                entry['fact_delta'][k] = {'in_source_not_archive': only_src,
                                          'in_archive_not_source': only_arc}
        an, mn = norm_prose(at), norm_prose(mt)
        asent, msent = sentences(an), sentences(mn)
        aset, mset = set(asent), set(msent)
        entry['ratio'] = round(difflib.SequenceMatcher(None, an, mn, autojunk=False).quick_ratio(), 4)
        entry['sent_only_source'] = sorted(mset - aset)
        entry['sent_only_archive'] = sorted(aset - mset)
        entry['counts'] = {'src_sent': len(msent), 'arc_sent': len(asent),
                           'src_only': len(mset - aset), 'arc_only': len(aset - mset)}
        report.append(entry)
    print(json.dumps(report, indent=1))
