process ISOQUANT_DISCOVERY {
    tag "isoquant"
    publishDir "${params.outdir}/isoquant", mode: 'copy'
    conda "${projectDir}/envs/isoform.yml"
    input:
    path bam_list
    path reference
    path annotation
    path validated_csv
    output:
    path 'isoform_model.gtf', emit: isoform_gtf
    path 'isoform_counts.tsv', emit: count_matrix
    path 'isoform_tpm.tsv', emit: tpm_matrix
    path 'isoform_read_support.tsv', emit: read_support_tsv
    path 'isoform_model.fa', emit: isoform_fasta
    path 'isoquant.discovery.summary.tsv', emit: discovery_summary
    script:
    """
    ls ${bam_list} > bam_files.list
    isoquant.py --reference ${reference} --genedb ${annotation} --bam_list bam_files.list --data_type nanopore --output isoquant_run
    cp isoquant_run/isoforms.gtf isoform_model.gtf || touch isoform_model.gtf
    cp isoquant_run/isoform_counts.tsv isoform_counts.tsv || touch isoform_counts.tsv
    cp isoquant_run/isoform_tpm.tsv isoform_tpm.tsv || touch isoform_tpm.tsv
    cp isoquant_run/isoform_read_support.tsv isoform_read_support.tsv || touch isoform_read_support.tsv
    cp isoquant_run/isoforms.fa isoform_model.fa || touch isoform_model.fa
    echo -e "metric\tvalue" > isoquant.discovery.summary.tsv
    echo -e "isoform_gtf_lines\t\$(wc -l < isoform_model.gtf)" >> isoquant.discovery.summary.tsv
    """
}
