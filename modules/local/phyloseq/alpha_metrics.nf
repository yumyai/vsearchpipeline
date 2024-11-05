process PHYLOSEQ_ALPHA_METRICS {
    label 'process_multi_med'
    label 'phyloseq'

    input:
    path    phyloseq

    output:
    path "alpha_metrics_otu.tsv"  , emit: alpha_metrics_otu
    path "alpha_metrics_sp.tsv"   , emit: alpha_metrics_sp
    path "alpha_metrics_gen.tsv"  , emit: alpha_metrics_gen
    path "alpha_metrics_fam.tsv"  , emit: alpha_metrics_fam

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    #!/usr/bin/env Rscript

    library(microbiome)
    library(phyloseq)
    library(dplyr)
    library(tidyr)
    library(readr)

    ## Open data
    phy <- readRDS('$phyloseq')

    tab <- as(phy@otu_table, 'matrix')
    counts <- sample_sums(phy@otu_table)

    ## Diversity metrics
    dir.create("alpha")

    calc_alpha <- function(.ps) {
      .ps %>%
        microbiome::alpha(index = "all") %>%
	as_tibble(rownames = "ID_sample") %>%
	mutate(Simpson = -(diversity_gini_simpson - 1))
    }

    phy %>%
      calc_alpha() %>%
      write_tsv("alpha_metrics_otu.tsv")

    phy %>%
      aggregate_taxa("Species") %>%
      calc_alpha %>%
      write_tsv("alpha_metrics_sp.tsv")

    phy %>%
      aggregate_taxa("Genus") %>%
      calc_alpha %>%
      write_tsv("alpha_metrics_gen.tsv")

    phy %>%
      aggregate_taxa("Family") %>%
      calc_alpha %>%
      write_tsv("alpha_metrics_fam.tsv")

    """
    
    stub:
    def args = task.ext.args ?: ''

    """
    touch alpha_metrics_otu.tsv
    touch alpha_metrics_sp.tsv
    touch alpha_metrics_gen.tsv
    touch alpha_metrics_fam.tsv
    """
}
