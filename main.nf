nextflow.enable.dsl=2

include { INPUT_CHECK }          from './modules/input_check'
include { NANOPLOT_RAW; MULTIQC_RAW } from './modules/qc_nanoplot'
include { CHOPPER_FILTER; FILTER_SUMMARY } from './modules/filter_chopper'
include { MINIMAP2_ALIGN }       from './modules/align_minimap2'
include { BAM_STATS; MAPPING_SUMMARY } from './modules/bam_stats'
include { ISOQUANT_DISCOVERY }   from './modules/isoquant'
include { FLAIR_DISCOVERY }      from './modules/flair'
include { SQANTI3_CLASSIFY }     from './modules/sqanti3_classify'
include { SQANTI3_FILTER }       from './modules/sqanti3_filter'
include { ISOFORM_QUANT }        from './modules/isoform_quant'
include { FINAL_REPORT }         from './modules/report'

workflow {
    if( !params.samplesheet ) error "Missing --samplesheet"
    if( !params.reference )   error "Missing --reference"
    if( !params.annotation )  error "Missing --annotation"

    Channel.fromPath(params.samplesheet, checkIfExists: true).set { ch_samplesheet }
    Channel.fromPath(params.reference, checkIfExists: true).set { ch_reference }
    Channel.fromPath(params.annotation, checkIfExists: true).set { ch_annotation }

    validated = INPUT_CHECK(ch_samplesheet, ch_reference, ch_annotation)

    samples = validated.validated_csv
        .splitCsv(header: true)
        .map { row -> tuple(row.sample_id as String, row.condition as String, row.replicate as String, file(row.fastq)) }

    nanoplot = NANOPLOT_RAW(samples)
    MULTIQC_RAW(nanoplot.nanoplot_dirs.collect())

    filtered = CHOPPER_FILTER(samples)
    FILTER_SUMMARY(filtered.filter_stats.collect())

    aligned = MINIMAP2_ALIGN(filtered.filtered_fastq, ch_reference)
    bamstat = BAM_STATS(aligned.sorted_bam)
    MAPPING_SUMMARY(bamstat.flagstat.collect(), bamstat.stats.collect())

    isoquant = ISOQUANT_DISCOVERY(aligned.sorted_bam.collect(), ch_reference, ch_annotation, validated.validated_csv)

    flair = params.run_flair ?
        FLAIR_DISCOVERY(aligned.sorted_bam.collect(), ch_reference, ch_annotation, validated.validated_csv) :
        null

    sqanti_class = params.run_sqanti3 ?
        SQANTI3_CLASSIFY(isoquant.isoform_gtf, ch_reference, ch_annotation, aligned.sorted_bam.collect()) :
        null

    sqanti_filter = params.run_sqanti3 ?
        SQANTI3_FILTER(sqanti_class.classification_tsv, sqanti_class.junctions_tsv, isoquant.isoform_gtf, isoquant.isoform_fasta, isoquant.read_support_tsv) :
        null

    quant_input_gtf   = params.run_sqanti3 ? sqanti_filter.high_conf_gtf   : isoquant.isoform_gtf
    quant_input_fasta = params.run_sqanti3 ? sqanti_filter.high_conf_fasta : isoquant.isoform_fasta

    quant = ISOFORM_QUANT(isoquant.count_matrix, isoquant.tpm_matrix, quant_input_gtf, quant_input_fasta)

    FINAL_REPORT(
        nanoplot.raw_summary,
        filtered.filtering_summary,
        bamstat.mapping_summary,
        isoquant.discovery_summary,
        params.run_flair ? flair.discovery_summary : Channel.empty(),
        params.run_sqanti3 ? sqanti_filter.confidence_summary : Channel.empty(),
        quant.quant_summary
    )
}
