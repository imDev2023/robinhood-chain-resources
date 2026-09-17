import re, sys, os, difflib, json
sys.path.insert(0,'_raw/docs-audit-2026-09-03b')
from pagediff import facts, strip_archive_header, norm_prose, sentences
PAIRS = [
 ('09-eip-8056.md','ext/eip8056.raw'),
 ('10-chainlink-tokenized-equity-feeds.md','ext/chainlink-tokenized-equity.raw'),
 ('15-arbitrum-compliance-filtering.md','ext/arbitrum-compliance.raw'),
 ('23-chainlink-data-streams.md','ext/chainlink-data-streams.raw'),
 ('24-chainlink-l2-sequencer-feeds.md','ext/chainlink-l2-seq.raw'),
 ('25-alchemy-robinhood-quickstart.md','ext/alchemy-quickstart.raw'),
]
base='_raw/docs-audit-2026-09-03b'
out=[]
for a,s in PAIRS:
    at=strip_archive_header(open(a,encoding='utf-8').read())
    st=open(os.path.join(base,s),encoding='utf-8').read()
    af,sf=facts(at),facts(st)
    e={'file':a,'src':s,'fact_delta':{}}
    for k in af:
        os_,oa = sorted(sf[k]-af[k]), sorted(af[k]-sf[k])
        if os_ or oa: e['fact_delta'][k]={'in_source_not_archive':os_,'in_archive_not_source':oa}
    an,sn=norm_prose(at),norm_prose(st)
    asent,ssent=set(sentences(an)),set(sentences(sn))
    e['ratio']=round(difflib.SequenceMatcher(None,an,sn,autojunk=False).quick_ratio(),4)
    e['sent_only_source']=sorted(ssent-asent); e['sent_only_archive']=sorted(asent-ssent)
    e['counts']={'src':len(ssent),'arc':len(asent),'src_only':len(ssent-asent),'arc_only':len(asent-ssent)}
    out.append(e)
json.dump(out,open(os.path.join(base,'extdiff.json'),'w'),indent=1)
for e in out:
    print(f"{e['file']:42} ratio={e['ratio']:.3f} srcSent={e['counts']['src']:>3} arcSent={e['counts']['arc']:>3} srcOnly={e['counts']['src_only']:>3} arcOnly={e['counts']['arc_only']:>3} facts={sorted(e['fact_delta'])}")
