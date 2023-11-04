process VSEARCH_DEREPFULLLENGTH {
    tag "$meta.id"
    label 'process_single_low'
    label 'vsearch'
    label 'error_retry'

    input:
    tuple val(meta), path(reads)
    val strand

    output:
    tuple val(meta), path("*.derep.fastq")     , emit: reads

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def uniq = "${prefix}.derep.fastq"
    """
    vsearch \\
        --fastx_uniques $reads \\
        --fastqout $uniq \\
        --strand $strand \\
        --sizeout \\
        --relabel $prefix.
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def uniq = "${prefix}.derep.fastq"
    """
    touch $uniq
    """
}
