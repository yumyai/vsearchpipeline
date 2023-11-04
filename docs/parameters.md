# vsearchpipeline: Parameters

| Group                      | Property                | Type     | Description                                            | Default Value | Required |
|----------------------------|-------------------------|----------|--------------------------------------------------------|---------------|----------|
| Input/output options       | input                   | string   | Path to comma-separated file containing information about the samples in the experiment. | -            | *        |
|                            | primers                 | string   | Path to comma-separated file containing forward_primer and reverse_primer sequences. | -            |          |
|                            | outdir                  | string   | The output directory where the results will be saved. You have to use absolute paths to storage on Cloud infrastructure. | -            | *        |
|                            | email                   | string   | Email address for completion summary.                  | -            |          |
|                            | multiqc_title           | string   | MultiQC report title. Printed as page header, used for filename if not otherwise specified. | -            |          |
| VSEARCH options             | allowmergestagger       | boolean  | Fastq merge process: allow merging of staggered read pairs. | -            |          |
|                            | maxdiffs                | integer  | Fastq merge process: specify the maximum number of non-matching nucleotides allowed in the overlap region. | 10           |          |
|                            | minlength               | integer  | Fastq merge process: discard input sequences with less than the specified number of bases. | -            |          |
|                            | maxlength               | integer  | Fastq merge process: discard sequences with more than the specified number of bases. | -            |          |
|                            | fastqmaxee              | integer  | Filtering process: discard sequences with an expected error greater than the specified number. | 1            |          |
|                            | fastawidth              | integer  | Filtering process: Fasta files produced by vsearch are wrapped. | 0            |          |
|                            | fastqmaxns              | integer  | Filtering process: discard sequences with more than the specified number of N’s. | 0            |          |
|                            | derep_strand            | string   | Dereplicate process: plus or both strands. | plus         |          |
|                            | derep_fastawidth        | integer  | Dereplicate process.                                   | 0            |          |
|                            | derep_strand_all        | string   | Dereplicate process all samples: plus or both strands. | plus         |          |
|                            | derep_fastawidth_all    | integer  | Dereplicate process all samples. | 0            |          |
|                            | derep_minunique_all     | integer  | Dereplicate process all samples. | 2            |          |
|                            | cluster_minsize         | integer  | Clustering.                                            | 8            |          |
|                            | cluster_alpha           | integer  | Clustering.                                            | 2            |          |
|                            | uchime_label            | string   | Chimera removal: labeling (prefix) of ASVs. | ASV_         |          |
|                            | usearch_id              | number   | Usearch global: id parameter. | 0.97         |          |
| Tree options                | tree_doubleprecision     | boolean  | VeryFastTree with double precision. | true         |          |
| DADA2 options               | dada2minboot            | integer  | assignTaxonomy function: The minimum bootstrap confidence for assigning a taxonomic level. | 80           |          |
|                            | dada2allowmultiple      | integer  | addSpecies function: maximum number of multiple assigned species. | 3            |          |
|                            | tryrevcompl             | boolean  | assignTaxonomy function: If TRUE, the reverse-complement of each sequence will be used for classification if it is a better match to the reference sequences than the forward sequence. | -            |          |
| Phyloseq options            | rarelevel               | integer  | Rarefaction level (not used if skip_rarefaction is not set at true) | -            |          |
| Generic options             | help                    | boolean  | Display help text. | -            |          |
|                            | version                 | boolean  | Display version and exit. | -            |          |
