# nf-core/vsearchpipeline: Output

## Introduction

This document describes the output produced by the pipeline. The directories listed below will be created in the results directory after the pipeline has finished. All paths are relative to the top-level results directory.


## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

- [FastQC](#fastqc) - Raw read QC
- [Seqtk](#seqtk) - Trim primers
- [VSEARCH](#vsearch) - make ASV fasta and count table
  - [fastqmerge](#vsearch) - Merge forward and reverse reads
  - [fastqfilter](#vsearch) - Filter reads
  - [dereplicate sample](#vsearch) - Dereplicate reads per sample
  - [dereplicate all](#vsearch) - Dereplicate all reads
  - [cluster_unoise](#vsearch) - Cluster reads into ASVs
  - [singleton_removal](#vsearch) - Sort and remove singletons
  - [uchime_denovo](#vsearch) - Remove chimeras with uchime_denovo method
  - [usearch_global](#vsearch) - Make count table from ASVs and dereplicated reads
- [MAFFT](#mafft) - Multiple sequence alignment of ASVs
- [FastTree](#fasttree) - Make phylogenetic tree of multiple sequence alignment
- [DADA2 taxonomic assignment](#dada2-taxonomic-assignment) - Assign taxonomy to ASVs and add species using SILVA v138.1 database
- [Phyloseq](#phyloseq) - Process data in phyloseq objects
  - [Make phyloseq object](#make-phyloseq-object) - Make phyloseq object out of count table, tax table and tree (if present)
  - [Rarefaction](#rarefaction) - Rarefy count table (experimental feature)
  - [Nicer taxonomy](#nicer-taxonomy) - Make 'nice' taxonomic names from different columns depending on known phylogenetic levels
- [MultiQC](#multiqc) - Aggregate report describing results and QC from the whole pipeline
- [Pipeline information](#pipeline-information) - Report metrics generated during the workflow execution

### FastQC

<details markdown="1">
<summary>Output files</summary>

- `fastqc/`
  - `*_fastqc.html`: FastQC report containing quality metrics.
  - `*_fastqc.zip`: Zip archive containing the FastQC report, tab-delimited data file and plot images.

</details>

[FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) gives general quality metrics about your sequenced reads. It provides information about the quality score distribution across your reads, per base sequence content (%A/T/G/C), adapter contamination and overrepresented sequences. For further reading and documentation see the [FastQC help pages](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/).

![MultiQC - FastQC sequence counts plot](images/mqc_fastqc_counts.png)

![MultiQC - FastQC mean quality scores plot](images/mqc_fastqc_quality.png)

![MultiQC - FastQC adapter content plot](images/mqc_fastqc_adapter.png)

> [!NOTE]
> The FastQC plots displayed in the MultiQC report shows _untrimmed_ reads. They may contain adapter sequence and potentially regions with low quality.

### Seqtk

<details markdown="1">
<summary>Output files</summary>

- `seqtk/`
  - `*.trim.fastq.gz`: Trimmed reads. 

</details>

[Seqtk]() trims the forward and reverse reads. In this process, the length of the primers is trimmed off of the corresponding (forward or reverse) fastq file.

### VSEARCH

<details markdown="1">
<summary>Output files</summary>

- `vsearch/`
  - `*.merged.fastq.gz`: merged fastq.gz per sample
  - `*.filtered.fastq`: filtered fastq per sample
  - `*.derep.fasta`: dereplicated fastq per sample
  - `all.concat.fasta`: all reads concatenated in one fastq file
  - `all.derep.fasta`: fasta file with unique sequences resulting from `fastq_uniques` for all concatenated reads
  - `asvs.clustered.fasta`: ASV fasta resulting from clustering
  - `asvs_nonchimeras.fasta`: fasta with ASVs that are left after `uchime3_denovo` chimera detection
  - `chimeras.fasta`: chimeras that were filtered out by `uchime3_denovo`
  - `count_table.txt`: count table resulting from `usearch_global`

</details>

In a series of seven [VSEARCH](https://github.com/torognes/vsearch/wiki/VSEARCH-pipeline) processes, the forward and reverse reads are translated into an ASV set and count table. 

First, the reads are merged using `fastq_merge` (default maxdiffs 30, no minlen or maxlen setting), so that there is one fasta file per sample left. Next, `fastq_filter` is used to filter the reads (default maxee = 1 and maxns = 1, no minlen or maxlen filter), resulting in a filtered fasta file per sample. 

Samples are then dereplicated per sample using `fastq_uniques`, resulting in a dereplicated fasta per sample. All dereplicated reads are then combined in one channel (`all.concat.fasta`) to be dereplicated again (default minunique=2), resulting in `all.derep.fasta`. This dereplicating process is performed twice since the dereplication is more efficient if first performed at sample-level - in other words, the first round per sample is mostly for compression purposes.

The `cluster_unoise` function is used to denoise fasta sequences with the VSEARCH defaults for minsize (8) and alpha (2), resulting in `asvs.clustered.fasta`. ASVs are then sorted using `sortbysize` and singletons are removed (minsize set at 2), resulting in `asvs_nonsingle.fasta`. Chimeras are removed using the `uchime3_denovo` method that uses the UNOISE version 3 algorithm by Robert Edgar. Both chimeras that are filtered out (`chimeras.fasta`) and ASVs without chimeras (`asvs_nonchimeras.fasta`), labelled with `ASV_` followed by a number, are saved. Using global pairwise alignment with `usearch_global`, target sequences `all.concat.fasta` are compared to `asv_nonchimeras.fasta`.

### MAFFT

<details markdown="1">
<summary>Output files</summary>

- `mafft/`
  - `asvs.msa`: multiple sequence alignment of the ASV sequences

</details>

[MAFFT](https://mafft.cbrc.jp/alignment/software/) is a tool for multiple sequence alignment (msa). We need the msa to make a phylogenetic tree.

### Fasttree

<details markdown="1">
<summary>Output files</summary>

- `fasttree/`
  - `asvs.msa.tree`: phylogenetic tree of ASVs

</details>

[FastTree](https://www.microbesonline.org/fasttree/) is a tool for inferring a phylogenetic tree. It is the default tool in this pipeline.

### DADA2: taxonomic assignment

<details markdown="1">
<summary>Output files</summary>

- `dada2/`
  - `taxtable.csv`: taxonomy table

</details>

[DADA2](https://benjjneb.github.io/dada2/) is used for taxonomic assignment. In this process, we use the `assignTaxonomy` (minBoot=80) and `addSpecies` (allowmultiple=3 and tryrevcompl=true) functions using [SILVA v.138.1 ASVs and species databases for DADA2](https://zenodo.org/records/4587955). The resulting taxonomy table is saved as csv.

### Phyloseq

<details markdown="1">
<summary>Output files</summary>

- `phyloseq/`
  - `complete/`
    - `phyloseq.RDS`: phyloseq object of count table, tax table and tree
    - `phylo_raw_taxtable.csv`: taxtable with columns for taxonomic levels
    - `taxtable_complete.RDS`: taxtable with assembled taxonomy in last column
    - `phylogen_levels.csv`: this table shows the phylogenetic levels known as a percentage of all ASVs
    - `phylogen_levels_top300.csv`: this table shows the phylogenetic levels known as a percentage of the top 300 most abundant ASVs
    - `composition_species_complete.pdf`: composition plot at species level
    - `composition_genus_complete.pdf`: composition plot at species level
    - `composition_family_complete.pdf`: composition plot at species level
    - `composition_phylum_complete.pdf`: composition plot at species level
    - `shannon_index_complete.pdf`: shannon diversity histogram
    - `species_richness_complete.pdf`: species richness histogram
    - `metrics_overview_complete`: some metrics on composition and diversity
  - `rarefied/`
    - `phyloseq_rarefied.RDS`: this is the rarefied phyloseq object
    - `rarefaction_plot.pdf`: histogram of total counts per sample with red line for defined rarefaction level
    - `rarefaction_report.txt`: report of rarefaction process
    - `taxtable_rarefied.RDS`: taxtable with assembled taxonomy in last column
    - `phylogen_levels.csv`: this table shows the phylogenetic levels known as a percentage of all ASVs
    - `phylogen_levels_top300.csv`: this table shows the phylogenetic levels known as a percentage of the top 300 most abundant ASVs
    - `composition_species_rarefied.pdf`: composition plot at species level
    - `composition_genus_rarefied.pdf`: composition plot at species level
    - `composition_family_rarefied.pdf`: composition plot at species level
    - `composition_phylum_rarefied.pdf`: composition plot at species level
    - `shannon_index_rarefied.pdf`: shannon diversity histogram
    - `species_richness_rarefied.pdf`: species richness histogram
    - `metrics_overview_rarefied`: some metrics on composition and diversity

</details>

#### Make phyloseq object
[Phyloseq](https://joey711.github.io/phyloseq/index.html) is an R package for handling 16S data. The different dimensions of the data can be stored in one phyloseq object, in this case `phyloseq.RDS`. If there is a phylogenetic tree (i.e. `--skip_tree` is not set), the tree wil also be stored in the phyloseq object.

#### Rarefaction
As an optional feature, this pipeline also has a process to rarefy data. It's however better to do this separately after inspecting the data carefully. The rules this process now uses for determining the rarefaction level are as follows:
- Rarefaction level as defined by `rarelevel` parameter, if set; otherwise,
- Mean - 3SDs: if that is >15000; 
- Median - IQR: if that is >15000; 
- 15000;
- If there's no samples left above >15000; minimum total counts of the samples.
Empty ASVs are trimmed from the dataset after this procedure. The rarefied phyloseq is saved as `phyloseq_rarefied.RDS`. The plots with the distribution of sample counts are saved as `rarefaction_plot.pdf`.

The processes for nicer taxonomy and metrics are both executed on the complete phyloseq object and the rarefied phyloseq object. If `skip_taxonomy` is set to true, the metrics won't be generated either because this process depends on the assembled taxonomy resulting from the taxonomy process.

#### Nicer taxonomy
The process in which the taxonomy levels are made into one taxonomy name for publication (e.g. 'Roseburia hominis' or 'Roseburia spp.') are saved in `taxtable.RDS`. The known phylogenetic levels for all ASVs and the top 300 most abundant ASVs are saved in `phylogen_levels.csv` and `phylogen_levels_top300.csv`, respectively.

#### Metrics
In this process, compositional plots and diversity (Shannon, richness) histograms are made to give some overview of the output data. 


### MultiQC

<details markdown="1">
<summary>Output files</summary>

- `multiqc/`
  - `multiqc_report.html`: a standalone HTML file that can be viewed in your web browser.
  - `multiqc_data/`: directory containing parsed statistics from the different tools used in the pipeline.
  - `multiqc_plots/`: directory containing static images from the report in various formats.

</details>

[MultiQC](http://multiqc.info) is a visualization tool that generates a single HTML report summarising all samples in your project. Most of the pipeline QC results are visualised in the report and further statistics are available in the report data directory.

Results generated by MultiQC collate pipeline QC from supported tools e.g. FastQC. The pipeline has special steps which also allow the software versions to be reported in the MultiQC output for future traceability. For more information about how to use MultiQC reports, see <http://multiqc.info>.

### Pipeline information

<details markdown="1">
<summary>Output files</summary>

- `pipeline_info/`
  - Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
  - Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameter's are used when running the pipeline.
  - Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.
  - Parameters used by the pipeline run: `params.json`.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.
