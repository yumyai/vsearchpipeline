process VSEARCH_SINTAX {
    label 'process_multi_med'
    label 'vsearch'

    input:
    path asvs
    path rdp_db
    val cutoff
    val tryrevcompl

    output:
    path "taxtable.csv"             , emit: taxtable
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def tryrc = tryrevcompl ? 'both' : 'plus'
    def seed = task.ext.seed ?: '1234'

    """
    vsearch -sintax reads.fastq -db "${rdp_db}" -tabbedout taxtable.csv
      -strand "${tryrc}" -sintax_cutoff 0.8

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(vsearch --version 2>&1))
    END_VERSIONS

    """

    stub:
    def args = task.ext.args ?: ''
    def tryrc = tryrevcompl ? 'TRUE' : 'FALSE'
    def seed = task.ext.seed ?: '1234'

    """
    touch taxtable.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(vsearch --version 2>&1))
    END_VERSIONS

    """
}
