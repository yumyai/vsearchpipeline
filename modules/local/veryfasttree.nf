process VERYFASTTREE {
    label 'process_single_low'

    conda "bioconda::veryfasttree=4.0.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/veryfasttree:4.0.2':
        'biocontainers/veryfasttree:4.0.2' }"

    input:
    path msa
    val tree_dp

    output:
    path "asvs.msa.tree"    , emit: tree
    path "versions.yml"     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def dp = tree_dp ? "-double-precision" : ''
    
    """
    VeryFastTree \\
        -nt \\
        $dp \\
        -gtr \\
        -gamma $msa \\
        -threads $task.cpus \\
        > asvs.msa.tree

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        veryfasttree: \$(VeryFastTree -help 2>&1 | head -n 1 | sed -n 's/.*\\([0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\\).*/\\1/p')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    
    """
    touch asvs.msa.tree

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        veryfasttree: \$(VeryFastTree -help 2>&1 | head -n 1 | sed -n 's/.*\\([0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\\).*/\\1/p')
    END_VERSIONS
    """
}
