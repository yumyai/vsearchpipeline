process DADA2_ASSIGNTAXONOMY {
    //label 'process_multi_high'
    label 'process_multi_med'
    label 'dada2'

    input:
    path asvs
    path silva_asv_db
    path silva_species_db
    val minboot
    val allowmultiple
    val tryrevcompl

    output:
    path "taxtable.csv"             , emit: taxtable
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def tryrc = tryrevcompl ? 'TRUE' : 'FALSE'
    def seed = task.ext.seed ?: '1234'

    """
    #!/usr/bin/env Rscript
    suppressPackageStartupMessages(library(dada2))
    set.seed($seed)
    taxtable <- assignTaxonomy( "$asvs", 
                                "$silva_asv_db", 
                                multithread = TRUE, 
                                minBoot = $minboot, 
                                verbose = TRUE)
    taxa <- addSpecies( taxtable, 
                        "$silva_species_db", 
                        verbose = TRUE, 
                        allowMultiple = $allowmultiple, 
                        tryRC = $tryrc)
    write.csv(taxa, file = "taxtable.csv", quote=FALSE)

    writeLines(c("\\"${task.process}\\":", 
        paste0("    R: ", paste0(R.Version()[c("major","minor")], collapse = ".")),
        paste0("    dada2: ", packageVersion("dada2")) ),
        "versions.yml")
    """

    stub:
    def args = task.ext.args ?: ''
    def tryrc = tryrevcompl ? 'TRUE' : 'FALSE'
    def seed = task.ext.seed ?: '1234'

    """
    touch taxtable.csv

    writeLines(c("\\"${task.process}\\":", 
        paste0("    R: ", paste0(R.Version()[c("major","minor")], collapse = ".")),
        paste0("    dada2: ", packageVersion("dada2")) ),
        "versions.yml")
    """
}
