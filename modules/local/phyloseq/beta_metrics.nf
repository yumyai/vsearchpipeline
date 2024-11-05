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
    library(readr)
    library(tidyr)
    library(purrr)
    library(vegan)
    library(forcats)

    # Open data
    phy <- readRDS('$phyloseq')

    tab <- as(phy@otu_table, 'matrix')
    counts <- sample_sums(phy@otu_table)
    tab <- as.data.frame(t(tab)/counts*100)
    tab_comp <- tab
    tab_comp\$Sample <- rownames(tab_comp)
    rowSums(tab) # samples should all sum up to 100%

    calc_beta <- function(.ps) {

      beta_div <- tibble(
          method = c("bray", "jaccard", "unifrac")
	) %>%
	rowwise() %>%
	mutate(
	  dist = list(
	    .ps %>%
	      phyloseq::distance(method = method) %>%
	      as.matrix() %>%
	      as_tibble(rownames = "rn")
	  ),
	  NMDS_raw = list(
	    .ps %>%
	      quietly(ordinate)("NMDS", method)
	  ),
	  NMDS = list(
	    NMDS_raw %>%
	      pluck("result") %>%
	      scores(display = "sites") %>%
	      as_tibble(rownames = "ID_sample")
	  ),
	  PCoA_raw = list(
	    .ps %>%
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

    calc_beta_rank <- function(.ps, rank) {

      .ps2 <- aggregate_taxa(.ps, rank)
      
      beta_div <- tibble(
          method = c("bray", "jaccard")
	) %>%
	rowwise() %>%
	mutate(
	  dist = list(
	    .ps2 %>%
	      phyloseq::distance(method = method) %>%
	      as.matrix() %>%
	      as_tibble(rownames = "rn")
	  ),
	  NMDS_raw = list(
	    .ps2 %>%
	      quietly(ordinate)("NMDS", method)
	  ),
	  NMDS = list(
	    NMDS_raw %>%
	      pluck("result") %>%
	      scores(display = "sites") %>%
	      as_tibble(rownames = "ID_sample")
	  ),
	  PCoA_raw = list(
	    .ps2 %>%
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

    beta_div_asv <- calc_beta(phy)
    beta_div_fam <- calc_beta_rank(phy, "Family")


    # Write beta diversity
    dir.create("nmds")
    dir.create("pcoa")

    saveRDS(beta_div_asv, file = "beta_asv.RDS")
    saveRDS(beta_div_fam, file = "beta_fam.RDS")

    write_beta_div <- function(beta_div, type) {
      beta_div %>%
        rowwise() %>%
        do({
          write_tsv(.\$NMDS, paste0("nmds/", .\$method, "_", type, ".tsv"))
          write_tsv(.\$PCoA, paste0("pcoa/", .\$method, "_", type, ".tsv"))
          tibble()
        })
    }
    

    # Write results for ASV and Family levels
    write_beta_div(beta_div_asv, "asv")
    write_beta_div(beta_div_fam, "fam")


    """
    
    stub:
    def args = task.ext.args ?: ''

    """
    mkdir nmds
    mkdir pcoa
    touch nmds/bray_asv.tsv
    touch nmds/jaccard_asv.tsv
    touch nmds/unifrac_asv.tsv
    touch nmds/bray_fam.tsv
    touch nmds/jaccard_fam.tsv
    touch pcoa/bray_asv.tsv
    touch pcoa/jaccard_asv.tsv
    touch pcoa/unifrac_asv.tsv
    touch pcoa/bray_fam.tsv
    touch pcoa/jaccard_fam.tsv
    """
}
