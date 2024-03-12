process MAFFT {
    label 'process_single_low'
    label 'mafft'

    input:
    path asvs

    output:
    path "asvs.msa"                 , emit: msa
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    mafft --auto $asvs > asvs.msa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mafft: \$(mafft --version 2>&1 | sed 's/^v//' | sed 's/ (.*)//')
    END_VERSIONS

    """

    stub:
    def args = task.ext.args ?: ''
    
    """
    touch asvs.msa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
    END_VERSIONS
    """
}
