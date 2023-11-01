process PHYLOSEQ {
    // tag '$bam'
    label 'process_low'

    conda "/miniforge3/envs/phyloseq"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://barbarahelena/phylomodule:1.1':
        'docker://barbarahelena/phylomodule:1.1' }"

    input:
    path asvs
    path counttable
    path tree
    path taxtable

    output:
    path "phyloseq.RDS"      , emit: phyloseq
    path "versions.yml"      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    #!/usr/bin/env Rscript
    library(Biostrings)
    library(phyloseq)

    dna <- readDNAStringSet("$asvs")
    counttable <- read.delim("$counttable")
    rownames(counttable) <- counttable[,1]
    counttable[,1] <- NULL
    taxtable <- read.csv("$taxtable")
    rownames(taxtable) <- taxtable[,1]
    taxtable[,1] <- NULL

    asv_seqs <- as.character(dna)
    asvs_names <- names(asv_seqs)
    rownames(taxtable) <- asvs_names[match(rownames(taxtable), asv_seqs)]

    tree <- ape::read.tree("$tree")
    tree_rooted <- phytools::midpoint.root(tree)

    taxtable <- as.matrix(taxtable)
    counttable <- as.matrix(counttable)

    ps <- phyloseq(otu_table(counttable, taxa_are_rows = TRUE), tax_table(taxtable), asv_seqs, tree_rooted)
    ps@refseq <- dna
    ps
    nsamples(ps)
    ntaxa(ps)
    sample_names(ps)

    saveRDS(ps, "phyloseq.RDS")

    writeLines(paste0("\\"${task.process}\\":\n", 
            paste0("    R: ", paste0(R.Version()[c("major","minor")], collapse = "."), "\n"),
            paste0("    phyloseq: ", packageVersion("phyloseq"), "\n"),
            paste0("    phytools: ", packageVersion("phytools"), "\n"),
            paste0("    Biostrings: ", packageVersion("Biostrings"), "\n")), 
        "versions.yml")

    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch phyloseq.RDS

    writeLines(paste0("\\"${task.process}\\":\n", 
            paste0("    R: ", paste0(R.Version()[c("major","minor")], collapse = "."), "\n"),
            paste0("    phyloseq: ", packageVersion("phyloseq"), "\n"),
            paste0("    phytools: ", packageVersion("phytools"), "\n"),
            paste0("    Biostrings: ", packageVersion("Biostrings"), "\n")), 
        "versions.yml")
    """
}
