process FINAL_REPORT {
    tag "final_report"
    publishDir "${params.outdir}/report", mode: 'copy', pattern: 'final_report.html'
    conda "${projectDir}/envs/base.yml"
    input:
    path raw_qc_summary
    path filtering_summary
    path mapping_summary
    path isoquant_summary
    path flair_summary
    path sqanti_summary
    path quant_summary
    output:
    path 'final_report.html'
    script:
    """
    cat > final_report.html <<HTML
    <html><body><h1>ONT cDNA upstream report</h1>
    <p>Raw QC: ${raw_qc_summary}</p><p>Filtering: ${filtering_summary}</p>
    <p>Mapping: ${mapping_summary}</p><p>IsoQuant: ${isoquant_summary}</p>
    <p>FLAIR: ${flair_summary}</p><p>SQANTI3: ${sqanti_summary}</p>
    <p>Quantification: ${quant_summary}</p></body></html>
    HTML
    """
}
