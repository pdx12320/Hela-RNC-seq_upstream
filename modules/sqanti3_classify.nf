process SQANTI3_CLASSIFY {
    tag "sqanti3"
    publishDir "${params.outdir}/sqanti3", mode: 'copy'
    conda "${projectDir}/envs/sqanti3.yml"
    input:
    path isoform_gtf
    path reference
    path annotation
    path bam_list
    output:
    path 'sqanti3_classification.txt', emit: classification_tsv
    path 'sqanti3_junctions.txt', emit: junctions_tsv
    script:
    """
    ls ${bam_list} > bam_files.list
    sqanti3_qc.py ${isoform_gtf} ${annotation} ${reference} --fl_count bam_files.list --output sqanti3_run
    cp sqanti3_run/*classification*.txt sqanti3_classification.txt
    cp sqanti3_run/*junctions*.txt sqanti3_junctions.txt
    """
}
