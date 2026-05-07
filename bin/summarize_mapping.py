#!/usr/bin/env python3
import argparse,re,pandas as pd,os
p=argparse.ArgumentParser();p.add_argument('--flagstat', nargs='+', required=True);p.add_argument('--stats', nargs='+', required=True);p.add_argument('--output', required=True);a=p.parse_args()
rows=[]
for f in a.flagstat:
    sid=os.path.basename(f).split('.samtools.flagstat.txt')[0]
    txt=open(f).read()
    m=re.search(r'^(\d+) \+ \d+ mapped', txt, re.M)
    t=re.search(r'^(\d+) \+ \d+ in total', txt, re.M)
    mapped=int(m.group(1)) if m else 0; total=int(t.group(1)) if t else 0
    rate=(mapped/total) if total else 0
    rows.append({'sample_id':sid,'total_reads':total,'mapped_reads':mapped,'mapping_rate':rate})
pd.DataFrame(rows).to_csv(a.output, sep='\t', index=False)
