#!/usr/bin/env python3
import argparse,glob,os,pandas as pd
p=argparse.ArgumentParser();p.add_argument('--nanoplot_dirs', nargs='+', required=True);p.add_argument('--output', required=True);a=p.parse_args()
rows=[]
for d in a.nanoplot_dirs:
    for f in glob.glob(os.path.join(d,'*.nanoplot.summary.tsv')):
        rows.append(pd.read_csv(f, sep='\t'))
out=pd.concat(rows, ignore_index=True) if rows else pd.DataFrame(columns=['sample_id','condition','replicate','reads','N50','mean_q'])
out.to_csv(a.output, sep='\t', index=False)
