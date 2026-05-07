process INPUT_CHECK {
    tag "input_check"
    publishDir "${params.outdir}/logs", mode: 'copy', pattern: 'input_check.log'
    publishDir "${params.outdir}/tables", mode: 'copy', pattern: 'samplesheet.validated.csv'
    conda "${projectDir}/envs/base.yml"
    input:
    path samplesheet
    path reference
    path annotation
    output:
    path 'samplesheet.validated.csv', emit: validated_csv
    path 'input_check.log', emit: input_log
    script:
    """
    python ${projectDir}/bin/check_samplesheet.py --samplesheet ${samplesheet} --reference ${reference} --annotation ${annotation} --out_csv samplesheet.validated.csv --log input_check.log
    """
}
