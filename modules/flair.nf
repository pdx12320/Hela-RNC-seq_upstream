process FLAIR_DISCOVERY {
    tag "flair"
    publishDir "${params.outdir}/flair", mode: 'copy'
    conda "${projectDir}/envs/isoform.yml"
    input:
    path bam_list
    path reference
    path annotation
    path validated_csv
    output:
    path 'flair.isoforms.gtf', emit: isoform_gtf
    path 'flair.counts.tsv', emit: count_matrix
    path 'flair.isoforms.fa', emit: isoform_fasta
    path 'flair.read_support.tsv', emit: read_support
    path 'flair.discovery.summary.tsv', emit: discovery_summary
    script:
    """
    ls ${bam_list} > bam_files.list
    flair collapse -g ${reference} -r bam_files.list -f ${annotation} -q flair
    cp flair.isoforms.gtf flair.isoforms.gtf || touch flair.isoforms.gtf
    cp flair.counts.tsv flair.counts.tsv || touch flair.counts.tsv
    cp flair.isoforms.fa flair.isoforms.fa || touch flair.isoforms.fa
    cp flair.read_support.tsv flair.read_support.tsv || touch flair.read_support.tsv
    echo -e "metric\tvalue" > flair.discovery.summary.tsv
    echo -e "isoform_gtf_lines\t\$(wc -l < flair.isoforms.gtf)" >> flair.discovery.summary.tsv
    """
}
