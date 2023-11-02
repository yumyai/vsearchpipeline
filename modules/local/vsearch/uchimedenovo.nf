process VSEARCH_UCHIMEDENOVO {
    label 'process_single_low'
    label 'vsearch'

    input:
    path(reads)
    val label

    output:
    path "chimeras.fasta"           , emit: chimeras
    path "asvs_nonchimeras.fasta"   , emit: asvs

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    vsearch \\
        --uchime3_denovo $reads \\
        --chimeras chimeras.fasta \\
        --nonchimeras asvs_nonchimeras.fasta \\
        --threads $task.cpus \\
        --relabel $label
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch chimeras.fasta
    touch asvs_nonchimeras.fasta
    """
}
