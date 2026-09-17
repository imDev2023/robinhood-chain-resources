import re, sys

ABBR = re.compile(r'(?:\b(?:e\.g|i\.e|vs|Nov|Inc|No|approx|etc|Dr|Mr|Ms|Fig|cf|al)\.)$')

def split_sentences(text):
    # split after . ! ? followed by a space and an uppercase/quote/backtick/digit start
    out=[]
    start=0
    i=0
    while i < len(text):
        c=text[i]
        if c in '.!?':
            # don't split inside inline code
            before = text[:i+1]
            if before.count('`') % 2 == 1:
                i+=1; continue
            j=i+1
            if j < len(text) and text[j] == ')':
                i+=1; continue
            if j < len(text) and text[j] == '"':
                j+=1
            if j < len(text) and text[j] == ' ':
                nxt = text[j+1:j+2]
                if nxt and (nxt.isupper() or nxt in '`"' or nxt.isdigit() or nxt == '['):
                    seg = text[start:j]
                    if ABBR.search(seg.rstrip()):
                        i+=1; continue
                    # avoid splitting a decimal or version like 1.0.39 (handled by isdigit check on prev)
                    if text[i-1:i].isdigit() and nxt.isdigit():
                        i+=1; continue
                    out.append(seg.strip())
                    start=j+1
                    i=j+1
                    continue
        i+=1
    tail=text[start:].strip()
    if tail: out.append(tail)
    return out

def process(path):
    lines=open(path).read().split('\n')
    out=[]
    infence=False
    for ln in lines:
        if ln.lstrip().startswith('```'):
            infence = not infence
            out.append(ln); continue
        if infence or not ln.strip():
            out.append(ln); continue
        s=ln.strip()
        # leave headings, tables, list items, blockquotes, indented code alone
        if s.startswith(('#','|','-','*','>','1.','2.','3.','4.','5.','6.','7.','8.','9.','10.')) or ln.startswith('    '):
            out.append(ln); continue
        parts=split_sentences(ln)
        out.extend(parts if parts else [ln])
    open(path,'w').write('\n'.join(out))
    print(path, len(lines), '->', len(out))

for p in sys.argv[1:]:
    process(p)
