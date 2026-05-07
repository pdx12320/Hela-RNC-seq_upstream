process BAM_STATS {
    tag "$sample_id"
    publishDir "${params.outdir}/bam_stats", mode: 'copy'
    conda "${projectDir}/envs/base.yml"
    input:
    tuple val(sample_id), path(bam)
    output:
    path "${sample_id}.samtools.flagstat.txt", emit: flagstat
    path "${sample_id}.samtools.stats.txt", emit: stats
    script:
    """
    samtools flagstat ${bam} > ${sample_id}.samtools.flagstat.txt
    samtools stats ${bam} > ${sample_id}.samtools.stats.txt
    """
}

process MAPPING_SUMMARY {
    tag "mapping_summary"
    publishDir "${params.outdir}/tables", mode: 'copy', pattern: 'mapping_summary.tsv'
    conda "${projectDir}/envs/base.yml"
    input:
    path flagstats
    path statfiles
    output:
    path 'mapping_summary.tsv', emit: mapping_summary
    script:
    """
    python ${projectDir}/bin/summarize_mapping.py --flagstat ${flagstats.join(' ')} --stats ${statfiles.join(' ')} --output mapping_summary.tsv
    """
}
