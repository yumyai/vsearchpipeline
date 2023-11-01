process VSEARCH_CLUSTERUNOISE {
    label 'process_single'
    label 'vsearch'
    
    input:
    path(reads)
    val minsize
    val alpha

    output:
    path "asvs.clustered.fasta"      , emit: asvs
    //path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    vsearch \\
        --cluster_unoise $reads \\
        --centroids asvs.clustered.fasta \\
        --minsize $minsize \\
        --unoise_alpha $alpha
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch asvs.clustered.fasta
    """
}