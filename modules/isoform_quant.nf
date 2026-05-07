process ISOFORM_QUANT {
    tag "isoform_quant"
    publishDir "${params.outdir}/quantification", mode: 'copy'
    conda "${projectDir}/envs/base.yml"
    input:
    path isoform_counts
    path isoform_tpm
    path isoform_gtf
    path isoform_fasta
    output:
    path 'isoform_counts.tsv', emit: isoform_counts
    path 'isoform_tpm.tsv', emit: isoform_tpm
    path 'gene_tpm.tsv', emit: gene_tpm
    path 'isoform_fraction.tsv', emit: isoform_fraction
    path 'quantification_summary.tsv', emit: quant_summary
    script:
    """
    cp ${isoform_counts} isoform_counts.tsv
    cp ${isoform_tpm} isoform_tpm.tsv
    python ${projectDir}/bin/calc_isoform_fraction.py --isoform_tpm isoform_tpm.tsv --isoform_gtf ${isoform_gtf} --gene_tpm_out gene_tpm.tsv --isoform_fraction_out isoform_fraction.tsv
    python ${projectDir}/bin/summarize_quantification.py --isoform_counts isoform_counts.tsv --isoform_tpm isoform_tpm.tsv --gene_tpm gene_tpm.tsv --isoform_fraction isoform_fraction.tsv --output quantification_summary.tsv
    """
}
