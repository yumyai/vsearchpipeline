process PHYLOSEQ_BETA_METRICS {
    label 'process_multi_med'
    label 'phyloseq'

    input:
    path    phyloseq

    output:
    path "nmds/*"      , emit: nmds
    path "pcoa/*"      , emit: pcoa

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
    library(purrr)
    library(vegan)
    library(forcats)

    ## Open data
    phy <- readRDS('$phyloseq')

    tab <- as(phy@otu_table, 'matrix')
    counts <- sample_sums(phy@otu_table)
    tab <- as.data.frame(t(tab)/counts*100)
    tab_comp <- tab
    tab_comp\$Sample <- rownames(tab_comp)
    rowSums(tab) # samples should all sum up to 100%

    calc_beta <- function(ps) {
      beta_div <- tibble(
          method = c("bray", "jaccard", "unifrac")
	) %>%
	rowwise() %>%
	mutate(
	  dist = list(
	    ps %>%
	      phyloseq::distance(method = method) %>%
	      as.matrix() %>%
	      as_tibble(rownames = "rn")
	  ),
	  NMDS_raw = list(
	    ps %>%
	      quietly(ordinate)("NMDS", method)
	  ),
	  NMDS = list(
	    NMDS_raw %>%
	      pluck("result") %>%
	      scores(display = "sites") %>%
	      as_tibble(rownames = "ID_sample")
	  ),
	  PCoA_raw = list(
	    ps %>%
	      quietly(ordinate)("PCoA", method)
	  ),
	  PCoA = list(
	    PCoA_raw %>%
	      pluck("result", "vectors") %>%
	      as_tibble(rownames = "ID_sample")
	  ),
	  PCoA_percentage = list(
	    PCoA_raw %>%
	      pluck("result", "values", "Relative_eig") * 100
	  )
	)
    }

    beta_div <- calc_beta(phy)


    # Write beta diversity
    dir.create("nmds")
    dir.create("pcoa")

    saveRDS(beta_div, file = "beta.RDS")
    saveRDS(beta_div, file = "nmds/beta_div.RDS")
    saveRDS(beta_div, file = "pcoa/beta_div.RDS")

    """
    
    stub:
    def args = task.ext.args ?: ''

    """
    mkdir nmds
    mkdir pcoa
    touch nmds/x.txt
    touch pcoa/y.txt
    """
}
