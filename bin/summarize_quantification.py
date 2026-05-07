#!/usr/bin/env python3
import argparse,pandas as pd
p=argparse.ArgumentParser();
p.add_argument('--isoform_counts', required=True);p.add_argument('--isoform_tpm', required=True);p.add_argument('--gene_tpm', required=True);p.add_argument('--isoform_fraction', required=True);p.add_argument('--output', required=True)
a=p.parse_args()
ic=pd.read_csv(a.isoform_counts, sep='\t');it=pd.read_csv(a.isoform_tpm, sep='\t');gt=pd.read_csv(a.gene_tpm, sep='\t');fr=pd.read_csv(a.isoform_fraction, sep='\t')
summary=pd.DataFrame({'metric':['n_isoforms_counts','n_isoforms_tpm','n_genes_tpm','n_isoforms_fraction'],'value':[len(ic),len(it),len(gt),len(fr)]})
summary.to_csv(a.output, sep='\t', index=False)
