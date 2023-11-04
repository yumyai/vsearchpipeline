# VSEARCH nextflow pipeline 

[![GitHub Actions CI Status](https://github.com/nf-core/vsearchpipeline/workflows/nf-core%20CI/badge.svg)](https://github.com/nf-core/vsearchpipeline/actions?query=workflow%3A%22nf-core+CI%22)
[![GitHub Actions Linting Status](https://github.com/nf-core/vsearchpipeline/workflows/nf-core%20linting/badge.svg)](https://github.com/nf-core/vsearchpipeline/actions?query=workflow%3A%22nf-core+linting%22)
[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

## Introduction

**vsearchpipeline** is a bioinformatics pipeline that uses VSEARCH to infer ASVs and make a count table from 16S sequencing reads. The input is a samplesheet with sample names and file paths to the fastq files, and a sheet with primer sequences if primer trimming is necessary. The pipeline uses DADA2 for taxonomic assignment (as opposed to VSEARCH sintax) using the SILVA v.138.1 database. The resulting count table, taxonomic table and phylogenetic tree resulting from the pipeline are stored in a phyloseq object.

1. Read QC ([`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
2. Trim primers (['Seqtk'](https://github.com/lh3/seqtk))
3. Infer ASVs and make count table (['VSEARCH'](https://github.com/torognes/vsearch))
4. Multiple sequence alignment (['MAFFT']()) to make phylogenetic tree (['VeryFastTree'](https://github.com/citiususc/veryfasttree))
5. Taxonomic assignment (['DADA2'](https://benjjneb.github.io/dada2/)) using SILVA 138.1 database for DADA2
6. Phyloseq object with count table, taxonomic table and phylogenetic tree (['Phyloseq'](https://joey711.github.io/phyloseq/))
7. MultiQC report ([`MultiQC`](http://multiqc.info/))


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

Then, prepare a sheet with the forward and reverse primers. This sheet should look as follows:

```console
forward_primer, reverse_primer
CCTACGGGAGGCAGCAG,TACNVGGGTATCTAAKCC
```

If there are no primers to be trimmed, simply add the `--skip_primers` flag to the nextflow run command. 

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

For more details and further functionality, please refer to the [usage documentation](https://github.com/barbarahelena/vsearchpipeline/blob/master/docs/usage.md) and the [parameter documentation](https://github.com/barbarahelena/vsearchpipeline/blob/master/docs/parameters.md).


## Pipeline output
All output of the different parts of the pipeline are stored in subdirectories of the output directory. These directories are named after the tools that were used ('vsearch', 'dada2', etc.). In the phyloseq folder, you can find the end result of the pipeline, which is the phyloseq object. Other important outputs are the multiqc report in the multiqc folder and the execution html report in the pipeline_info folder.

For more details on the pipeline output, please refer to the [output documentation](https://github.com/barbarahelena/vsearchpipeline/blob/master/docs/output.md).


## Credits

This pipeline uses the nf-core template (as much as possible).

## Citations

If you use  nf-core/vsearchpipeline for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX)

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
