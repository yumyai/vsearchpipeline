process DADA2_ASSIGNTAXONOMY {
    // tag '$bam'
    label 'process_medium'

    conda "bioconda::bioconductor-dada2=1.22.0 conda-forge::r-digest=0.6.30"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bioconductor-dada2:1.22.0--r41h399db7b_0' :
        'biocontainers/bioconductor-dada2:1.22.0--r41h399db7b_0' }"

    input:
    path asvs
    path silva_asv_db
    path silva_species_db

    output:
    path "taxtable.csv"             , emit: taxtable
    //path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    #!/usr/bin/env Rscript
    suppressPackageStartupMessages(library(dada2))
    set.seed(1234)
    taxtable <- assignTaxonomy("$asvs", "$silva_asv_db", multithread = $task.cpus, minBoot = 80, verbose = TRUE)
    taxa <- addSpecies(taxtable, "$silva_species_db", verbose = TRUE, allowMultiple = 3, tryRC = TRUE)
    write.csv(taxa, file = "taxtable.csv", quote=FALSE)
    """

    stub:
    def args = task.ext.args ?: ''
    
    """
    touch taxtable.csv
    """
}
