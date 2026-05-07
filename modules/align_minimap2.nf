process MINIMAP2_ALIGN {
    tag "$sample_id"
    publishDir "${params.outdir}/bam", mode: 'copy', pattern: '*.sorted.bam*'
    conda "${projectDir}/envs/base.yml"
    input:
    tuple val(sample_id), path(filtered_fastq)
    path reference
    output:
    tuple val(sample_id), path("${sample_id}.sorted.bam"), emit: sorted_bam
    path "${sample_id}.sorted.bam.bai", emit: sorted_bai
    script:
    """
    minimap2 ${params.minimap2_preset} -t ${task.cpus} ${reference} ${filtered_fastq} | samtools sort -@ ${task.cpus} -o ${sample_id}.sorted.bam
    samtools index ${sample_id}.sorted.bam
    """
}
