/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PRINT PARAMS SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { paramsSummaryLog; paramsSummaryMap } from 'plugin/nf-validation'

def logo = NfcoreTemplate.logo(workflow, params.monochrome_logs)
def citation = '\n' + WorkflowMain.citation(workflow) + '\n'
def summary_params = paramsSummaryMap(workflow)

// Print parameter summary log to screen
log.info logo + paramsSummaryLog(workflow) + citation

WorkflowVsearchpipeline.initialise(params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_multiqc_config          = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config   = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
ch_multiqc_logo            = params.multiqc_logo   ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ) : Channel.empty()
ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Local modules
//
include { SEQTK_TRIMFQ }                from '../modules/local/seqtk/trimfq'
include { VSEARCH_FASTQMERGEPAIRS }     from '../modules/local/vsearch/fastqmergepairs'
include { VSEARCH_FASTQFILTER }         from '../modules/local/vsearch/fastqfilter'
include { VSEARCH_DEREPFULLLENGTH }     from '../modules/local/vsearch/derepfulllength'
include { VSEARCH_DEREPFULLLENGTHALL }  from '../modules/local/vsearch/derepfulllengthall'
include { VSEARCH_CLUSTERUNOISE }       from '../modules/local/vsearch/clusterunoise'
include { VSEARCH_UCHIMEDENOVO }        from '../modules/local/vsearch/uchimedenovo'
include { VSEARCH_USEARCHGLOBAL }       from '../modules/local/vsearch/usearchglobal'
include { MAFFT }                       from '../modules/local/mafft'
include { VERYFASTTREE }                from '../modules/local/veryfasttree'
include { SILVADATABASES }              from '../modules/local/silvadatabases'
include { DADA2_ASSIGNTAXONOMY }        from '../modules/local/dada2/assigntaxonomy'
include { PHYLOSEQ_MAKEOBJECT }         from '../modules/local/phyloseq/makeobject'
include { PHYLOSEQ_RAREFACTION }        from '../modules/local/phyloseq/rarefaction'
include { PHYLOSEQ_FIXTAXONOMY }        from '../modules/local/phyloseq/fixtaxonomy'

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { INPUT_CHECK } from '../subworkflows/local/input_check'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { FASTQC                      } from '../modules/nf-core/fastqc/main'
include { MULTIQC                     } from '../modules/nf-core/multiqc/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary
def multiqc_report = []

workflow VSEARCHPIPELINE {
    ch_versions = Channel.empty()

    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    INPUT_CHECK (
        file(params.input),
        file(params.primers)
    )
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)
    //
    // MODULE: Run FastQC
    //
    FASTQC (
        INPUT_CHECK.out.reads
    )
    ch_versions = ch_versions.mix(FASTQC.out.versions.first())
    ch_primers = INPUT_CHECK.out.primers.first()

    //
    // MODULE:  Seqtk trim primers in fastq files
    //
    if (!params.without_primers) {
        SEQTK_TRIMFQ (
            INPUT_CHECK.out.reads, 
            ch_primers
        ).reads.set {ch_trimmed_reads}
    } else {
        ch_trimmed_reads = INPUT_CHECK.out.reads
    }    

    //
    // MODULE: VSEARCH merge fastq pairs
    //
    VSEARCH_FASTQMERGEPAIRS (
        ch_trimmed_reads,
        params.allowmergestagger,
        params.maxdiffs,
        params.minlength,
        params.maxlength
    )

    //
    // MODULE: VSEARCH filter fastq files
    //
    VSEARCH_FASTQFILTER (
        VSEARCH_FASTQMERGEPAIRS.out.reads,
        params.fastqmaxee,
        params.fastqwidth,
        params.fastqmaxns 
    )

    //
    // MODULE: VSEARCH dereplicate per sample
    //
    VSEARCH_DEREPFULLLENGTH (
        VSEARCH_FASTQFILTER.out.reads,
        params.derep_strand,
        params.derep_fastawidth
    )

    //
    // Combine all reads
    //
    fasta_files = VSEARCH_DEREPFULLLENGTH.out.reads
        .collect { it[1] }

    // 
    // MODULE: VSEARCH dereplicate for all reads
    //
    VSEARCH_DEREPFULLLENGTHALL (
        fasta_files,
        params.derep_strand_all,
        params.derep_fastawidth_all,
        params.derep_minunique_all
    )
    //
    // MODULE: VSEARCH cluster asvs
    //
    VSEARCH_CLUSTERUNOISE (
        VSEARCH_DEREPFULLLENGTHALL.out.reads,
        params.cluster_minsize,
        params.cluster_alpha
    )
    //
    // MODULE: VSEARCH chimera detection
    //
    VSEARCH_UCHIMEDENOVO (
        VSEARCH_CLUSTERUNOISE.out.asvs,
        params.uchime_label
    )
    //
    // MODULE: VSEARCH make count table
    //
    VSEARCH_USEARCHGLOBAL (
        VSEARCH_DEREPFULLLENGTHALL.out.concatreads,
        VSEARCH_UCHIMEDENOVO.out.asvs,
        params.usearch_id
    )
    ch_versions = ch_versions.mix(VSEARCH_USEARCHGLOBAL.out.versions)
    //
    // MODULE: MAFFT for multiple sequence alignment
    //
    MAFFT (
        VSEARCH_UCHIMEDENOVO.out.asvs
    )
    ch_versions = ch_versions.mix(MAFFT.out.versions)
    //
    // MODULE: Make tree with veryfasttree (fasttree with double precision)
    //
    VERYFASTTREE (
        MAFFT.out.msa
    )
    ch_versions = ch_versions.mix(VERYFASTTREE.out.versions)
    // 
    // MODULE: Download SILVA if not already present in db folder
    //
    SILVADATABASES()
    
    // 
    // MODULE: DADA2 Assign taxonomy with SILVA db
    //
    DADA2_ASSIGNTAXONOMY (
        VSEARCH_UCHIMEDENOVO.out.asvs,
        SILVADATABASES.out.asvdb,
        SILVADATABASES.out.speciesdb,
        params.dada2minboot,
        params.dada2allowmultiple,
        params.tryrevcompl
    )
    ch_versions = ch_versions.mix(DADA2_ASSIGNTAXONOMY.out.versions)

    //
    // MODULE: Make phyloseq object
    //
    PHYLOSEQ_MAKEOBJECT (
        VSEARCH_UCHIMEDENOVO.out.asvs,
        VSEARCH_USEARCHGLOBAL.out.counts,
        VERYFASTTREE.out.tree,
        DADA2_ASSIGNTAXONOMY.out.taxtable
    )
    ch_versions = ch_versions.mix(PHYLOSEQ_MAKEOBJECT.out.versions)

    //
    // MODULE: Rarefaction
    //
    if (params.rarefaction) {
        PHYLOSEQ_RAREFACTION (
            PHYLOSEQ_MAKEOBJECT.out.phyloseq,
            params.rarelevel,
            params.rareprune
        ).phyloseq.set{ ch_rarefied_phyloseq }
    } else {
        ch_rarefied_phyloseq = PHYLOSEQ_MAKEOBJECT.out.phyloseq
    }

    if (params.fixtaxonomy) {
        PHYLOSEQ_FIXTAXONOMY (
            ch_rarefied_phyloseq
        )
    }
    //
    // MODULE: Collect software versions
    //
    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )

    //
    // MODULE: MultiQC
    //
    workflow_summary    = WorkflowVsearchpipeline.paramsSummaryMultiqc(workflow, summary_params)
    ch_workflow_summary = Channel.value(workflow_summary)

    methods_description    = WorkflowVsearchpipeline.methodsDescriptionText(workflow, ch_multiqc_custom_methods_description, params)
    ch_methods_description = Channel.value(methods_description)

    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml'))
    ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]}.ifEmpty([]))

    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList()
    )
    multiqc_report = MULTIQC.out.report.toList()


}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.dump_parameters(workflow, params)
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
