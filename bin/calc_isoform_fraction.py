#!/usr/bin/env python3
import argparse, re
import pandas as pd

def parse_gtf_map(gtf):
    t2g = {}
    pat_t = re.compile(r'transcript_id "([^"]+)"')
    pat_g = re.compile(r'gene_id "([^"]+)"')
    with open(gtf) as f:
        for line in f:
            if line.startswith('#'): continue
            arr = line.rstrip('\n').split('\t')
            if len(arr) < 9 or arr[2] != 'transcript':
                continue
            attr = arr[8]
            mt, mg = pat_t.search(attr), pat_g.search(attr)
            if mt and mg:
                t2g[mt.group(1)] = mg.group(1)
    return t2g

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--isoform_tpm', required=True)
    p.add_argument('--isoform_gtf', required=True)
    p.add_argument('--gene_tpm_out', required=True)
    p.add_argument('--isoform_fraction_out', required=True)
    a = p.parse_args()

    tpm = pd.read_csv(a.isoform_tpm, sep='\t')
    tx_col = tpm.columns[0]
    tpm = tpm.rename(columns={tx_col:'isoform'})
    t2g = parse_gtf_map(a.isoform_gtf)
    tpm['gene_id'] = tpm['isoform'].map(t2g).fillna('NA')
    sample_cols = [c for c in tpm.columns if c not in ['isoform','gene_id']]

    gene = tpm.groupby('gene_id')[sample_cols].sum().reset_index()
    gene.to_csv(a.gene_tpm_out, sep='\t', index=False)

    gm = gene.set_index('gene_id')
    frac = tpm[['isoform','gene_id'] + sample_cols].copy()
    for c in sample_cols:
        frac[c] = frac.apply(lambda r: (r[c]/gm.at[r['gene_id'],c]) if (r['gene_id'] in gm.index and gm.at[r['gene_id'],c] > 0) else 0.0, axis=1)
    frac.to_csv(a.isoform_fraction_out, sep='\t', index=False)

if __name__ == '__main__':
    main()
