process VSEARCH_DEREPFULLLENGTHALL {
    //tag "$meta.id"
    label 'process_single'
    conda "bioconda::vsearch=2.23.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/vsearch:2.21.2--hf1761c0_0 ':
        'biocontainers/vsearch:2.23.0--h6a68c12_0' }"

    input:
    path(reads)

    output:
    path("all.concat.fasta") , emit: concatreads
    path("all.derep.fasta")  , emit: reads
    path "versions.yml"      , emit: versions
    
    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    cat $reads > all.concat.fasta
    
    vsearch \\
        --derep_fulllength all.concat.fasta\\
        --output all.derep.fasta \\
        --strand plus \\
        --sizein \\
        --sizeout \\
        --fasta_width 0 \\
        --minuniquesize 2

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(vsearch --version 2>&1) | sed 's/^.*vsearch //; s/Using.*\$//' ))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch all.concat.fasta
    touch all.derep.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(vsearch --version 2>&1) | sed 's/^.*vsearch //; s/Using.*\$//' ))
    END_VERSIONS
    """
}
