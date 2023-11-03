# VSEARCH nextflow pipeline 

[![GitHub Actions CI Status](https://github.com/nf-core/vsearchpipeline/workflows/nf-core%20CI/badge.svg)](https://github.com/nf-core/vsearchpipeline/actions?query=workflow%3A%22nf-core+CI%22)
[![GitHub Actions Linting Status](https://github.com/nf-core/vsearchpipeline/workflows/nf-core%20linting/badge.svg)](https://github.com/nf-core/vsearchpipeline/actions?query=workflow%3A%22nf-core+linting%22)
[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

## Introduction

**nf-core/vsearchpipeline** is a bioinformatics pipeline that ...

<!-- TODO nf-core:
   Complete this sentence with a 2-3 sentence summary of what types of data the pipeline ingests, a brief overview of the
   major pipeline sections and the types of output it produces. You're giving an overview to someone new
   to nf-core here, in 15-20 seconds. For an example, see https://github.com/nf-core/rnaseq/blob/master/README.md#introduction
-->

<!-- TODO nf-core: Include a figure that guides the user through the major workflow steps. Many nf-core
     workflows use the "tube map" design for that. See https://nf-co.re/docs/contributing/design_guidelines#examples for examples.   -->
<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->

1. Read QC ([`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
2. Present QC for raw reads ([`MultiQC`](http://multiqc.info/))
3.
4.
5.
6.

## Usage

:::note
If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how
to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline)
with `-profile test` before running the workflow on actual data.
:::

First, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
sample,fastq_1,fastq_2
CONTROL_REP1,AEG588A1_S1_L002_R1_001.fastq.gz,AEG588A1_S1_L002_R2_001.fastq.gz
```

Each row represents a pair of fastq files (paired end).

Then, prepare a sheet with the forward and reverse primers. This sheet should as follows:




If there are no primers to be trimmed, simply add the `--skip_primers` flag to the command. 

-->

Now, you can run the pipeline using:

```bash
nextflow run nf-core/vsearchpipeline \
   -profile <docker/singularity/.../institute> \
   --input samplesheet.csv \
   --primers primers.csv \
   --outdir <OUTDIR>
```

:::warning
Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those
provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_;
see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).
:::

For more details and further functionality, please refer to the [usage documentation](https://nf-co.re/vsearchpipeline/usage) and the [parameter documentation](https://nf-co.re/vsearchpipeline/parameters).

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


## Pipeline output



## Credits

I used the nf-core template for this pipeline.

## Citations

If you use  nf-core/vsearchpipeline for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX)

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
