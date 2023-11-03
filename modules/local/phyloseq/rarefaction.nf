process PHYLOSEQ_RAREFACTION {
    label 'process_multi_low'
    label 'phyloseq'

    input:
    path    phyloseq
    val     rarelevel
    val     prune

    output:
    path "phyloseq.RDS"             , emit: phyloseq
    path "rarehist.pdf"             , emit: rarecurve

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def seed = task.ext.seed ?: '1234'
    def rarelevel = rarelevel ? "${rarelevel}" : 'NA'
    def skipprune = prune ? 'TRUE' : 'FALSE'

    """
    #!/usr/bin/env Rscript
    library(phyloseq)

    ## Open data
    phylo <- readRDS('$phyloseq')
    print(paste0('The phyloseq object has ', nsamples(phylo), ' samples and',
                    ntaxa(phylo), ' taxa.'))
    
    # Plot histogram
    pdf('rarehist.pdf')
        hist(rowSums(phylo@otu_table), breaks = 20)
    dev.off()

    ## Rarefaction
   if(sum(phylo@otu_table[1,]) != sum(phylo@otu_table[2,])){
    print('Rowsums are unequal, the data has not been rarefied yet.')
    if(is.na($rarelevel)){
        rarelevel <- mean(rowSums(phylo@otu_table)) - 2*sd(rowSums(phylo@otu_table))
        if(rarelevel <= 0){ rarelevel <- min(rowSums(phylo@otu_table))}
        print(paste0('Rarefaction level: ', rarelevel))
    } else{
        rarelevel <- $rarelevel
        print(paste0('Rarefaction level was user-defined: ', rarelevel))
    }
    
    phylo_rare <- rarefy_even_depth(phylo, sample.size = rarelevel, 
                                    rngseed = $seed, replace = FALSE, 
                                    trimOTUs = TRUE, verbose = TRUE)
    print(paste0('The phyloseq object has ', nsamples(phylo), ' samples and',
                 ntaxa(phylo), ' taxa.'))

    } else{
        print('Phyloseq object seems already rarefied.')
        phylo_rare <- phylo
    }

    ## Remove constant/empty ASVs
        if($skipprune == FALSE){
            print('Prune taxa to remove contant or empty ASVs.')
            phylo_prune <- prune_taxa(taxa_sums(phylo_rare) > 0, phylo_rare)
            print(paste0('The phyloseq object has ', nsamples(phylo_prune), ' samples and',
                ntaxa(phylo_prune), ' taxa.'))
        } else {
            print('No pruning was performed.')
            phylo_prune <- phylo_rare
        }

    saveRDS(phylo_prune, 'phyloseq_rarefied.RDS')
    """

    stub:
    def args = task.ext.args ?: ''

    """
    touch phyloseq_rarefied.RDS
    """
}
