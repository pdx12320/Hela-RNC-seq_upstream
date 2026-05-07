process SQANTI3_FILTER {
    tag "sqanti3_filter"
    publishDir "${params.outdir}/high_confidence_isoforms", mode: 'copy', pattern: 'high_confidence_isoforms.*'
    publishDir "${params.outdir}/tables", mode: 'copy', pattern: 'isoform_*tsv'
    publishDir "${params.outdir}/tables", mode: 'copy', pattern: 'filtered_out_isoforms.tsv'
    conda "${projectDir}/envs/sqanti3.yml"
    input:
    path classification_tsv
    path junctions_tsv
    path isoform_gtf
    path isoform_fasta
    path read_support_tsv
    output:
    path 'high_confidence_isoforms.gtf', emit: high_conf_gtf
    path 'high_confidence_isoforms.fa', emit: high_conf_fasta
    path 'isoform_classification.tsv', emit: classification_summary
    path 'filtered_out_isoforms.tsv', emit: filtered_out
    path 'isoform_confidence_score.tsv', emit: confidence_score
    path 'sqanti3.filter.summary.tsv', emit: confidence_summary
    script:
    """
    python ${projectDir}/bin/filter_sqanti3_isoforms.py --classification ${classification_tsv} --junctions ${junctions_tsv} --isoform_gtf ${isoform_gtf} --isoform_fasta ${isoform_fasta} --read_support ${read_support_tsv} --min_read_support ${params.min_read_support} --min_novel_support ${params.min_novel_support} --min_multi_sample ${params.min_multi_sample} --out_gtf high_confidence_isoforms.gtf --out_fasta high_confidence_isoforms.fa --out_classification isoform_classification.tsv --out_filtered filtered_out_isoforms.tsv --out_confidence isoform_confidence_score.tsv --out_summary sqanti3.filter.summary.tsv
    """
}
