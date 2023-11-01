process VERYFASTTREE {
    //tag '$bam'
    label 'process_single'

    conda "bioconda::veryfasttree=4.0.03"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/veryfasttree:3.1.1--h9f5acd7_1':
        'biocontainers/veryfasttree:4.0.03--h4ac6f70_0' }"

    input:
    path msa

    output:
    path "asvs.msa.tree"    , emit: tree
    path "versions.yml"     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    VeryFastTree -nt -double-precision -gtr -gamma $msa > asvs.msa.tree

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        veryfasttree: \$(VeryFastTree -help 2>&1 | head -n 1 | sed -n 's/.*\\([0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\\).*/\\1/p')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    
    """
    touch asvs.msa.treefile
    touch tree.tre

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        veryfasttree: \$(veryfasttree --version 2>&1 | sed 's/^v//' | sed 's/ (.*)//')
    END_VERSIONS
    """
}
