process PHYLOSEQ_MAKEOBJECT {
    label 'process_multi_low'
    label 'phyloseq'

    input:
    path asvs
    path counttable
    path tree
    path taxtable
    path metatable

    output:
    path "phyloseq.RDS"             , emit: phyloseq
    path "phylo_raw_taxtable.csv"   , emit: taxtable
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def treepresent = tree.name != 'NO_TREEFILE' ? "TRUE" : "FALSE"

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
    metatable <- read.csv("$metatable", row.names = 1)
    # Check if the metatable has no columns
    if (ncol(metatable) == 0) {
      # Add a placeholder column with NA values
      # Hack. Nextflow need column
      metatable\$placeholder <- "placeholder"
    }

    asv_seqs <- as.character(dna)
    asvs_names <- names(asv_seqs)
    rownames(taxtable) <- asvs_names[match(rownames(taxtable), asv_seqs)]
    metatable <- sample_data(metatable)
    taxtable <- as.matrix(taxtable)
    counttable <- as.matrix(counttable)

    if($treepresent == TRUE) {
        tree <- ape::read.tree("$tree")
        tree_rooted <- phytools::midpoint.root(tree)
        ps <- phyloseq(otu_table(counttable, taxa_are_rows = TRUE), tax_table(taxtable), asv_seqs, metatable, tree_rooted)
    } else{
        ps <- phyloseq(otu_table(counttable, taxa_are_rows = TRUE), tax_table(taxtable), asv_seqs, metatable )
    }
    ps@refseq <- dna
    ps
    nsamples(ps)
    ntaxa(ps)
    sample_names(ps)

    saveRDS(ps, "phyloseq.RDS")
    write.csv(ps@tax_table, "phylo_raw_taxtable.csv")

    writeLines(paste0("\\"${task.process}\\":\n", 
            paste0("    R: ", paste0(R.Version()[c("major","minor")], collapse = "."), "\n"),
            paste0("    phyloseq: ", packageVersion("phyloseq"), "\n"),
            paste0("    phytools: ", packageVersion("phytools"), "\n"),
            paste0("    Biostrings: ", packageVersion("Biostrings"))), 
        "versions.yml")

    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch phyloseq.RDS
    touch phylo_raw_taxtable.csv

    writeLines(paste0("\\"${task.process}\\":\n", 
            paste0("    R: ", paste0(R.Version()[c("major","minor")], collapse = "."), "\n"),
            paste0("    phyloseq: ", packageVersion("phyloseq"), "\n"),
            paste0("    phytools: ", packageVersion("phytools"), "\n"),
            paste0("    Biostrings: ", packageVersion("Biostrings"))), 
        "versions.yml")
    """
}
