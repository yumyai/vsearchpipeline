process SEQTK_TRIMFQ {
    tag "$meta.id"
    label 'process_single'

    conda "bioconda::seqtk=1.4"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/seqtk:1.2--1':
        'biocontainers/seqtk:1.4--h7132678_0' }"

    input:
    tuple val(meta), path(reads)
    tuple val(fwd_primer), val(rev_primer)

    output:
    tuple val(meta), path("*.trim.fastq.gz") , emit: reads
    path "versions.yml"                     , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def fwd_chars = fwd_primer.size()
    def rev_chars = rev_primer.size()
    def fwd_reads = reads[0]
    def rev_reads = reads[1]
    def fwd_trimmed = "${prefix}_1.trim.fastq.gz"
    def rev_trimmed = "${prefix}_2.trim.fastq.gz"

    """
    seqtk \\
        trimfq \\
        -b $fwd_chars \\
        $fwd_reads \\
        | gzip > $fwd_trimmed
    
    seqtk \\
        trimfq \\
        -b $rev_chars \\
        $rev_reads \\
        | gzip > $rev_trimmed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(seqtk --version 2>&1) | sed 's/^.*seqtk //; s/Using.*\$//' ))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch $fwd_trimmed
    touch $rev_trimmed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
    END_VERSIONS
    """
}
