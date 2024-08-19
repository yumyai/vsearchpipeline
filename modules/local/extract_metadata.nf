// Cut read files and put only metadata in it.
process EXTRACT_METADATA {
    input:
      path samplesheet

    output:
      path "metadata.csv" , emit: metatable
      conda "conda-forge::pandas=2.1.1"
      container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pandas:1.5.2' :
        'biocontainers/pandas:1.5.2' }"

    publishDir "${params.outdir}", mode: 'copy'

    script:
    """
    #!/usr/bin/env python

    import pandas as pd
    import shutil

    def main():
        df = pd.read_csv("${samplesheet}")
        df.columns = df.columns.str.strip()
        df = df.drop(columns=['fastq_1', 'fastq_2'])
        df_trimmed = df.apply(lambda x: x.str.strip() if x.dtype == "object" else x)
        df_trimmed.to_csv("metadata.csv", index=False)

    main()

    """
}

// vim: set expandtab tabstop=4 shiftwidth=4:
