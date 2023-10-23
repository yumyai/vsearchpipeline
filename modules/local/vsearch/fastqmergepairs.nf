process VSEARCH_FASTQMERGEPAIRS {
    tag "$meta.id"
    label 'process_single'
    conda "bioconda::vsearch=2.23.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/vsearch:2.21.2--hf1761c0_0 ':
        'biocontainers/vsearch:2.23.0--h6a68c12_0' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.merged.fastq.gz")  , emit: reads
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def fwd_reads = reads[0]
    def rev_reads = reads[1]
    def merged = "${prefix}.merged.fastq.gz"

    //         # --fastq_minmergelen 230 \\
    //    # --fastq_maxmergelen 270 \\
    //    # --fastq_eeout \\

    """
    vsearch \\
        --fastq_mergepairs $fwd_reads \\
        --reverse $rev_reads \\
        --fastq_maxdiffs 100 \\
        --fastq_allowmergestagger \\
        --fastqout $merged
        

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(vsearch --version 2>&1) | sed 's/^.*vsearch //; s/Using.*\$//' ))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def fwd_reads = reads[0]
    def rev_reads = reads[1]
    def merged = "${prefix}.merged.fastq.gz"
    """
    touch $merged

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(vsearch --version 2>&1) | sed 's/^.*vsearch //; s/Using.*\$//' ))
    END_VERSIONS
    """
}