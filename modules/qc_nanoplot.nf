process NANOPLOT_RAW {
    tag "$sample_id"
    publishDir "${params.outdir}/qc/raw_nanoplot", mode: 'copy'
    conda "${projectDir}/envs/base.yml"
    input:
    tuple val(sample_id), val(condition), val(replicate), path(fastq)
    output:
    path "${sample_id}", emit: nanoplot_dirs
    path "${sample_id}.nanoplot.summary.tsv", emit: sample_summary
    script:
    """
    mkdir -p ${sample_id}
    NanoPlot --fastq ${fastq} --outdir ${sample_id} --tsv_stats --loglength
    n_reads=\$(zcat ${fastq} | awk 'NR%4==2{c++} END{print c+0}')
    n50=\$(awk 'BEGIN{n50="NA"} /^N50/{n50=\$3} END{print n50}' ${sample_id}/NanoStats.txt)
    mean_q=\$(awk 'BEGIN{q="NA"} /^Mean read quality/{q=\$4} END{print q}' ${sample_id}/NanoStats.txt)
    echo -e "sample_id\tcondition\treplicate\treads\tN50\tmean_q" > ${sample_id}.nanoplot.summary.tsv
    echo -e "${sample_id}\t${condition}\t${replicate}\t\${n_reads}\t\${n50}\t\${mean_q}" >> ${sample_id}.nanoplot.summary.tsv
    """
}

process MULTIQC_RAW {
    tag "raw_qc"
    publishDir "${params.outdir}/multiqc", mode: 'copy', pattern: 'raw_multiqc_report.html'
    publishDir "${params.outdir}/qc", mode: 'copy', pattern: 'raw_nanoplot_summary.tsv'
    conda "${projectDir}/envs/base.yml"
    input:
    path nanoplot_dirs
    output:
    path 'raw_multiqc_report.html', emit: multiqc_html
    path 'raw_nanoplot_summary.tsv', emit: raw_summary
    script:
    """
    python ${projectDir}/bin/summarize_qc.py --nanoplot_dirs ${nanoplot_dirs.join(' ')} --output raw_nanoplot_summary.tsv
    multiqc . -n raw_multiqc_report.html
    """
}
