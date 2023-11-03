process VSEARCH_FASTQFILTER {
    tag "$meta.id"
    label 'process_single_low'
    label 'vsearch'
    label 'error_retry'

    input:
    tuple val(meta), path(reads)
    val maxee
    val width
    val maxns

    output:
    tuple val(meta), path("*.filtered.fasta")   , emit: reads
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def filtered = "${prefix}.filtered.fasta"

    """
    vsearch \\
        --fastq_filter $reads \\
        -fastq_maxee $maxee \\
        -fastaout $filtered \\
        --fasta_width $width \\
        --fastq_maxns $maxns

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(vsearch --version 2>&1))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def filtered = "${prefix}.filtered.fasta"
    def maxns = $maxns ?: "${maxns}" 
    def width = $width ?: "${width}"
    def maxee = $maxee ?: "${maxee}"

    """
    touch "${prefix}.filtered.fasta"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(vsearch --version 2>&1))
    END_VERSIONS
    """
}
