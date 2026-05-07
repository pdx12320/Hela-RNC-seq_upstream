process CHOPPER_FILTER {
    tag "$sample_id"
    publishDir "${params.outdir}/filtered_fastq", mode: 'copy', pattern: '*.filtered.fastq.gz'
    publishDir "${params.outdir}/tables/filter_stats", mode: 'copy', pattern: '*.filtering.tsv'
    conda "${projectDir}/envs/base.yml"
    input:
    tuple val(sample_id), val(condition), val(replicate), path(fastq)
    output:
    tuple val(sample_id), path("${sample_id}.filtered.fastq.gz"), emit: filtered_fastq
    path "${sample_id}.filtering.tsv", emit: filter_stats
    script:
    """
    raw_reads=\$(zcat ${fastq} | awk 'NR%4==2{c++} END{print c+0}')
    zcat ${fastq} | chopper -l ${params.chopper_min_length} -q ${params.chopper_min_quality} | gzip -c > ${sample_id}.filtered.fastq.gz
    filtered_reads=\$(zcat ${sample_id}.filtered.fastq.gz | awk 'NR%4==2{c++} END{print c+0}')
    echo -e "sample_id\traw_reads\tfiltered_reads\tretention_rate" > ${sample_id}.filtering.tsv
    awk -v s=${sample_id} -v r=\${raw_reads} -v f=\${filtered_reads} 'BEGIN{rate=(r>0)?f/r:0; print s"\t"r"\t"f"\t"rate}' >> ${sample_id}.filtering.tsv
    """
}

process FILTER_SUMMARY {
    tag "filter_summary"
    publishDir "${params.outdir}/tables", mode: 'copy', pattern: 'filtering_summary.tsv'
    conda "${projectDir}/envs/base.yml"
    input:
    path filter_stats
    output:
    path 'filtering_summary.tsv', emit: filtering_summary
    script:
    """
    { head -n 1 \$(ls ${filter_stats} | head -n 1); for f in ${filter_stats}; do tail -n +2 \$f; done; } > filtering_summary.tsv
    """
}
