process VSEARCH_FASTQFILTER {
    tag "$meta.id"
    label 'process_single_low'
    label 'vsearch'
    label 'error_retry'

    input:
    tuple val(meta), path(reads)
    val maxee
    val minlength
    val maxlength
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
    def min = $minlength != 0 ? "--fastq_minlen ${minlength}" : ""
    def max = $maxlength != 0 ? "--fastq_maxlen ${maxlength}" : ""
    def maxns = $maxns ? "--fastq_maxns ${maxns}" : ""

    """
    vsearch \\
        --fastq_filter $reads \\
        --fastq_maxee $maxee \\
        $min \\
        $max \\
        $maxns \\
        --fasta_width 0 \\
        -fastaout $filtered 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(vsearch --version 2>&1))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def filtered = "${prefix}.filtered.fasta"
    def min = $minlength != 0 ? "--fastq_minlen ${minlength}" : ""
    def max = $maxlength != 0 ? "--fastq_maxlen ${maxlength}" : ""
    def maxns = $maxns ? "--fastq_maxns ${maxns}" : ""

    """
    touch "${prefix}.filtered.fasta"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(vsearch --version 2>&1))
    END_VERSIONS
    """
}
