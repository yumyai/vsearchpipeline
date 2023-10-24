process VSEARCH_UCHIMEDENOVO {
    label 'process_single'
    conda "bioconda::vsearch=2.23.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/vsearch:2.21.2--hf1761c0_0 ':
        'biocontainers/vsearch:2.23.0--h6a68c12_0' }"

    input:
    path(reads)

    output:
    path "chimeras.fasta"           , emit: chimeras
    path "asvs_nonchimeras.fasta"   , emit: asvs
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    vsearch \\
        --uchime3_denovo $reads \\
        --chimeras chimeras.fasta \\
        --nonchimeras asvs_nonchimeras.fasta \\
        --relabel ASV_

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(vsearch --version 2>&1) | sed 's/^.*vsearch //; s/Using.*\$//' ))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch chimeras.fasta
    touch asvs_nonchimeras.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(vsearch --version 2>&1) | sed 's/^.*vsearch //; s/Using.*\$//' ))
    END_VERSIONS
    """
}
