process PHYLOSEQ_RAREFACTION {
    label 'process_multi_low'
    label 'phyloseq'

    input:
    path    phyloseq
    val     rarelevel

    output:
    path "phyloseq_rarefied.RDS"    , emit: phyloseq
    path "rarehist.pdf"             , emit: rarecurve
    path "rarefaction_report.txt"   , emit: rarereport

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def seed = task.ext.seed ?: '1234'
    def rarelevel = rarelevel ? "${rarelevel}" : 0

    """
    #!/usr/bin/env Rscript
    library(phyloseq)

    ## Open data
    phylo <- readRDS('$phyloseq')
    numbers_before_rarefaction <- paste0('The phyloseq object has ', nsamples(phylo), ' samples and ',
                 ntaxa(phylo), ' taxa. \n')
    print(numbers_before_rarefaction)
    
    ## Calculated rarefaction level
    rarelevel <- mean(colSums(phylo@otu_table)) - 2*sd(rowSums(phylo@otu_table))
    if(rarelevel <= 15000){ rarelevel <- median(colSums(phylo@otu_table)) - IQR(colSums(phylo@otu_table)) }
    if(rarelevel <= 15000){ rarelevel <- 15000}
    if(all(colSums(phylo@otu_table) < 15000)){ rarelevel <- min(colSums(phylo@otu_table))}

    print(paste0('Max counts: ', max(colSums(phylo@otu_table))))
    print(paste0('Min counts: ', min(colSums(phylo@otu_table))))
    print(paste0('Mean counts: ', mean(colSums(phylo@otu_table))))
    print(paste0('SD counts: ', sd(colSums(phylo@otu_table))))

    ## Rarefaction
    if(sum(phylo@otu_table[1,]) != sum(phylo@otu_table[2,])){
        rarefaction_yesno <- 'Rowsums are unequal, the data has not been rarefied yet.\n'
        print(rarefaction_yesno)
        if($rarelevel == 0){
            rarefaction_outcome <- paste0('Rarefaction level: ', rarelevel, '\n')
        } else{
            rarelevel <- $rarelevel
            rarefaction_outcome <- paste0('Rarefaction level was user-defined: ', rarelevel, '\n')
        }
        print(rarefaction_outcome)
    
        phylo_rare <- rarefy_even_depth(phylo, sample.size = rarelevel, 
                                        rngseed = $seed, replace = FALSE, 
                                        trimOTUs = TRUE, verbose = TRUE)
        
        numbers_after_rarefaction <- paste0('The phyloseq object has ', nsamples(phylo), ' samples and',
                    ntaxa(phylo), ' taxa. \n')
        print(numbers_after_rarefaction)
        report <- paste0(numbers_before_rarefaction, 
                            rarefaction_yesno, 
                            rarefaction_outcome,
                            numbers_after_rarefaction)
    } else{
        rarefaction_yesno <- 'Phyloseq object seems already rarefied.\n'
        print(rarefaction_yesno)
        report <- paste0(numbers_before_rarefaction, 
                            rarefaction_yesno)
        phylo_rare <- phylo
    }

    ## Plot histogram
    pdf('rarehist.pdf')
        hist(colSums(phylo@otu_table), breaks = nsamples(phylo)/10)
        abline(v=rarelevel, col='red', lwd=3, lty='dashed')
    dev.off()
    
    write.txt(report, 'rarefaction_report.txt')
    saveRDS(phylo_rare, 'phyloseq_rarefied.RDS')
    """

    stub:
    def args = task.ext.args ?: ''
    def seed = task.ext.seed ?: '1234'
    def rarelevel = rarelevel ? "${rarelevel}" : 0

    """
    touch phyloseq_rarefied.RDS
    touch rarehist.pdf
    touch rarereport.txt
    """
}
