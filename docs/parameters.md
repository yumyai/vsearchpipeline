# vsearchpipeline: Parameters

| Group                   | Property                    | Type      | Description                                                  | Default Value | Required |
|-------------------------|-----------------------------|-----------|--------------------------------------------------------------|---------------|----------|
| Input/output options    | input                       | string    | Path to comma-separated file containing information about the samples in the experiment. | -             | *        |
|                         | primers                     | string    | Path to comma-separated file containing forward_primer and reverse_primer sequences. | -             |          |
|                         | outdir                      | string    | The output directory where the results will be saved. You have to use absolute paths to storage on Cloud infrastructure. | -             | *        |
|                         | email                       | string    | Email address for completion summary.                        | -             |          |
|                         | multiqc_title               | string    | MultiQC report title. Printed as page header, used for filename if not otherwise specified. | -             |          |
| VSEARCH options          | merge_allowmergestagger     | boolean   | Fastq merge process: allow merging of staggered read pairs.   | -             |          |
|                         | merge_maxdiffs              | integer   | Fastq merge process: Discard input sequences with more bases difference than specified | 30            |          |
|                         | merge_minlen                | integer   | Fastq merge process: Discard input sequences shorter than the specified number of bases | 0             |          |
|                         | merge_maxdiffpct            | integer   | Fastq merge process: maximum percentage of non-matching nucleotides allowed in the overlap region | 100           |          |
|                         | merge_maxlen                | integer   | Fastq merge process: Discard sequences longer than the specified number of bases | 0             |          |
|                         | filter_maxee                | number    | Filtering process: Discard sequences with an expected error greater than the specified number | 1             |          |
|                         | filter_maxns                | integer   | Filtering process: Discard sequences with more than the specified number of N’s. | 0             |          |
|                         | filter_minlen               | integer   | Filtering process: Discard sequences shorter than the specified length. | 0             |          |
|                         | filter_maxlen               | integer   | Filtering process: Discard sequences longer than the specified length. | 0             |          |
|                         | derep_strand                | string    | Dereplicate process: plus or both strands                     | plus          |          |
|                         | derep_all_strand            | string    | Dereplicate process all samples: plus or both strands         | plus          |          |
|                         | derep_all_fastawidth        | integer   | Dereplicate process all samples:                              | 0             |          |
|                         | derep_all_minunique         | integer   | Dereplicate process all samples                               | 2             |          |
|                         | cluster_minsize             | integer   | Clustering                                                   | 8             |          |
|                         | cluster_alpha               | number    | Clustering                                                   | 2.0           |          |
|                         | sort_fastawidth             | integer   | Sorting and removing singletons: fastawidth                   | 0             |          |
|                         | sort_minsize                | integer   | Sorting and removing singletons: minsize                      | 2             |          |
|                         | uchime_label                | string    | Chimera removal: labeling (prefix) of ASVs                    | ASV_          |          |
|                         | usearch_id                  | number    | Usearch global: id parameter                                  | 0.97          |          |
| DADA2 options            | dada2_minboot               | integer   | assignTaxonomy function: The minimum bootstrap confidence for assigning a taxonomic level. | 80            |          |
|                         | dada2_allowmultiple         | integer   | addSpecies function: maximum number of multiple assigned species. If 0, this will be set at FALSE. | 3             |          |
|                         | dada2_tryrevcompl           | boolean   | addSpecies function: If TRUE, the reverse-complement of each sequences will be used for classification if it is a better match to the reference sequences than the forward sequence. | true          |          |
| Phyloseq options         | rarelevel                   | integer   | Rarefaction level (not used if skip_rarefaction is set at true) | 0             |          |
| Skip options             | skip_primers                | boolean   | Skip trimming of primers                                    | -             |          |
|                         | skip_tree                   | boolean   | Skip multiple sequence alignment and tree processes           | -             |          |
|                         | skip_rarefaction            | boolean   | Skip rarefaction of phyloseq object                           | -             |          |
|                         | skip_fixtaxonomy            | boolean   | Skip process to make a table with composite taxonomy names    | -             |          |
|                         | skip_metrics                | boolean   | Skip process to provide some general metrics of the phyloseq object (composition, diversity) | -             |          |
