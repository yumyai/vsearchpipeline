process PHYLOSEQ_FIXTAXONOMY {
    label 'process_single'
    label 'phyloseq'

    input:
    path    phyloseq

    output:
    path "taxtable.RDS"             , emit: taxonomy
    path "phylogen_levels.csv"      , emit: phylevels

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
    print(paste0('The phyloseq object has ', nsamples(phylo), ' samples and',
                    ntaxa(phylo), ' taxa.'))
    
    ### Check phy levels
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

    # Get unique taxonomy strings
    unique(tax\$Tax)

    saveRDS(tax, file = "taxtable.RDS")
    """
     
    stub:
    def args = task.ext.args ?: ''

    """
    touch taxtable.RDS
    touch phylogen_levels.csv
    """
}
