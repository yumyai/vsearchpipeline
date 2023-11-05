process PHYLOSEQ_FIXTAXONOMY {
    label 'process_multi_low'
    label 'phyloseq'

    input:
    path    phyloseq

    output:
    path "taxtable.RDS"                 , emit: taxonomy
    path "phylogen_levels.csv"          , emit: phylevels
    path "phylogen_levels_top300.csv"   , emit: phylevelstop

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def seed = task.ext.seed ?: '1234'
    """
    #!/usr/bin/env Rscript
    library(phyloseq)

    ## Open data
    phylo <- readRDS('$phyloseq')
    print(paste0('The phyloseq object has ', nsamples(phylo), ' samples and ',
                    ntaxa(phylo), ' taxa.'))
    
    ### Check levels
    tax <- as.data.frame(as(phylo@tax_table, 'matrix'))
    head(tax)
    splevel <- sum(!is.na(tax\$Species)) / nrow(tax) * 100
    genlevel <- sum(!is.na(tax\$Genus)) / nrow(tax) * 100
    famlevel <- sum(!is.na(tax\$Family)) / nrow(tax) * 100
    phylevel <- sum(!is.na(tax\$Phylum)) / nrow(tax) * 100
    df <- data.frame(
        level = c("Species", "Genus", "Family", "Phylum"),
        ntax = rep(nrow(tax), 4),
        number_known = c(sum(!is.na(tax\$Species)), sum(!is.na(tax\$Genus)),
                        sum(!is.na(tax\$Family)), sum(!is.na(tax\$Phylum))),
        perc_known = c(splevel, genlevel, famlevel, phylevel)
    )
    write.csv2(df, 'phylogen_levels.csv')

    ### Check levels top 300
    taxasums <- taxa_sums(phylo)
    taxasums <- taxasums[order(taxasums, decreasing = T)]
    top300 <- names(taxasums[1:300])
    tax300 <- tax[rownames(tax) %in% top300, ]
    splevel <- sum(!is.na(tax300\$Species)) / nrow(tax300) * 100
    genlevel <- sum(!is.na(tax300\$Genus)) / nrow(tax300) * 100
    famlevel <- sum(!is.na(tax300\$Family)) / nrow(tax300) * 100
    phylevel <- sum(!is.na(tax300\$Phylum)) / nrow(tax300) * 100
    df2 <- data.frame(
        level = c("Species", "Genus", "Family", "Phylum"),
        ntax = rep(nrow(tax300), 4),
        number_known = c(sum(!is.na(tax300\$Species)), sum(!is.na(tax300\$Genus)),
                        sum(!is.na(tax300\$Family)), sum(!is.na(tax300\$Phylum))),
        perc_known = c(splevel, genlevel, famlevel, phylevel)
    )
    write.csv2(df2, 'phylogen_levels_top300.csv')

    # get 'nice' taxonomy for ASVs (unfortunately in base R)
    tax\$Tax <- ifelse(!is.na(tax\$Genus) & !is.na(tax\$Species), paste(tax\$Genus, tax\$Species),
                    ifelse(!is.na(tax\$Genus) & is.na(tax\$Species), paste(tax\$Genus, 'spp.'),
                    ifelse(!is.na(tax\$Family) & is.na(tax\$Genus), paste(tax\$Family, 'spp.'),
                    ifelse(!is.na(tax\$Order) & is.na(tax\$Family), paste(tax\$Order, 'spp.'),
                    ifelse(!is.na(tax\$Class) & is.na(tax\$Order), paste(tax\$Class, 'spp.'),
                    ifelse(!is.na(tax\$Phylum) & is.na(tax\$Class), paste(tax\$Phylum, 'spp.'),
                    ifelse(!is.na(tax\$Kingdom) & is.na(tax\$Phylum), paste(tax\$Kingdom, 'spp.'),
                    ifelse(is.na(tax\$Kingdom), 'unclassified', NA))))))))
    tax\$ASV <- rownames(tax)

    saveRDS(tax, file = "taxtable.RDS")
    """
     
    stub:
    def args = task.ext.args ?: ''

    """
    touch taxtable.RDS
    touch phylogen_levels.csv
    """
}
