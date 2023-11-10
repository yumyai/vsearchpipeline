process IQTREE {
    label 'process_multi_long'

    conda "bioconda::iqtree=2.2.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/iqtree%3A2.2.5--h21ec9f0_0':
        'biocontainers/iqtree--h21ec9f0_0' }"

    input:
    path msa

    output:
    path "asvs.msa.treefile"    , emit: tree
    path "asvs.msa.log"         , emit: log
    path "asvs.msa.iqtree"      , emit: iqtree
    path "versions.yml"         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    iqtree \\
        -s ${msa} \\
        -n 0 \\
        -m GTR+R10  \\
        -T AUTO
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        iqtree: \$(iqtree -help 2>&1 | head -n 1 | sed -n 's/.*\\([0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\\).*/\\1/p')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    
    """
}
