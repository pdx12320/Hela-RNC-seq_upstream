#!/usr/bin/env python3
import argparse
import pandas as pd
from collections import Counter

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--classification', required=True)
    p.add_argument('--junctions', required=True)
    p.add_argument('--isoform_gtf', required=True)
    p.add_argument('--isoform_fasta', required=True)
    p.add_argument('--read_support', required=True)
    p.add_argument('--min_read_support', type=int, default=3)
    p.add_argument('--min_novel_support', type=int, default=5)
    p.add_argument('--min_multi_sample', type=int, default=2)
    p.add_argument('--out_gtf', required=True)
    p.add_argument('--out_fasta', required=True)
    p.add_argument('--out_classification', required=True)
    p.add_argument('--out_filtered', required=True)
    p.add_argument('--out_confidence', required=True)
    p.add_argument('--out_summary', required=True)
    a = p.parse_args()

    c = pd.read_csv(a.classification, sep='\t', comment='#', low_memory=False)
    if 'isoform' not in c.columns:
        c.rename(columns={c.columns[0]: 'isoform'}, inplace=True)
    if 'structural_category' not in c.columns:
        c['structural_category'] = 'NA'

    rs = pd.read_csv(a.read_support, sep='\t', low_memory=False)
    if 'isoform' not in rs.columns:
        rs.rename(columns={rs.columns[0]: 'isoform'}, inplace=True)
    if 'read_support' not in rs.columns:
        rs['read_support'] = 0
    if 'sample_count' not in rs.columns:
        rs['sample_count'] = 1

    df = c.merge(rs[['isoform','read_support','sample_count']], on='isoform', how='left')
    df['read_support'] = df['read_support'].fillna(0).astype(int)
    df['sample_count'] = df['sample_count'].fillna(1).astype(int)

    internal = df.get('intrapriming', False).astype(str).str.lower().isin(['true','1','yes']) if 'intrapriming' in df.columns else False
    rts = df.get('RTS_stage', False).astype(str).str.lower().isin(['true','1','yes']) if 'RTS_stage' in df.columns else False
    cat = df['structural_category'].astype(str)

    remove = internal | rts | (df['read_support'] < a.min_read_support)
    high = cat.isin(['full-splice_match','incomplete-splice_match','novel_in_catalog','FSM','ISM','NIC']) & (df['read_support'] >= a.min_read_support) & (df['sample_count'] >= a.min_multi_sample) & (~remove)
    med = cat.isin(['novel_not_in_catalog','NNC']) & (df['read_support'] >= a.min_novel_support) & (df['sample_count'] >= a.min_multi_sample) & (~remove)

    df['confidence'] = 'low'
    df.loc[high, 'confidence'] = 'high'
    df.loc[med, 'confidence'] = 'medium'
    df.loc[remove, 'confidence'] = 'remove'

    keep = set(df.loc[df['confidence'].isin(['high','medium']), 'isoform'])
    removed = df[df['confidence']=='remove'].copy()

    # filter gtf
    with open(a.isoform_gtf) as fin, open(a.out_gtf,'w') as fout:
        for line in fin:
            if line.startswith('#'):
                fout.write(line); continue
            keep_line = any(f'transcript_id "{tid}"' in line for tid in keep)
            if keep_line: fout.write(line)

    # filter fasta
    with open(a.isoform_fasta) as fin, open(a.out_fasta,'w') as fout:
        write=False
        for line in fin:
            if line.startswith('>'):
                tid = line[1:].strip().split()[0]
                write = tid in keep
            if write: fout.write(line)

    df[['isoform','structural_category','read_support','sample_count','confidence']].to_csv(a.out_classification, sep='\t', index=False)
    removed[['isoform','structural_category','read_support','sample_count','confidence']].to_csv(a.out_filtered, sep='\t', index=False)
    df[['isoform','confidence']].to_csv(a.out_confidence, sep='\t', index=False)

    cnt = Counter(df['confidence'])
    pd.DataFrame({'metric':['high','medium','low','remove'], 'value':[cnt.get('high',0),cnt.get('medium',0),cnt.get('low',0),cnt.get('remove',0)]}).to_csv(a.out_summary, sep='\t', index=False)

if __name__ == '__main__':
    main()
