process VSEARCH_DEREPFULLLENGTH {
    tag "$meta.id"
    label 'process_single_low'
    label 'vsearch'

    input:
    tuple val(meta), path(reads)
    val strand
    val fastawidth

    output:
    tuple val(meta), path("*.derep.fasta")     , emit: reads

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def uniq = "${prefix}.derep.fasta"
    """
    vsearch \\
        --derep_fulllength $reads \\
        --output $uniq \\
        --strand $strand \\
        --sizeout \\
        --fasta_width $fastawidth \\
        --relabel $prefix.
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def uniq = "${prefix}.derep.fasta"
    """
    touch $uniq
    """
}
