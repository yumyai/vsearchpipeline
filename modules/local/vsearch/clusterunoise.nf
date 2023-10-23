process VSEARCH_CLUSTERUNOISE {
    label 'process_single'
    conda "bioconda::vsearch=2.23.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/vsearch:2.21.2--hf1761c0_0 ':
        'biocontainers/vsearch:2.23.0--h6a68c12_0' }"

    input:
    path(reads)

    output:
    path "asvs.clustered.fasta"      , emit: asvs
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    vsearch \\
        --cluster_unoise $reads \\
        --centroids asvs.clustered.fasta \\
        --minsize 8 \\
        --unoise_alpha 2

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(vsearch --version 2>&1) | sed 's/^.*vsearch //; s/Using.*\$//' ))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch asvs.clustered.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(vsearch --version 2>&1) | sed 's/^.*vsearch //; s/Using.*\$//' ))
    END_VERSIONS
    """
}