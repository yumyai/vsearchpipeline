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
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    path "asvs.msa.tree"            , emit: tree
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    VeryFastTree -nt -double-precision -gtr -gamma $msa > asvs.msa.tree

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(veryfasttree --version 2>&1) | sed 's/^.*veryfasttree //; s/Using.*\$//' ))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    touch asvs.msa.treefile
    touch tree.tre

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
    END_VERSIONS
    """
}
