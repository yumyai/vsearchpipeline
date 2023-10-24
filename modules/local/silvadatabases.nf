process SILVADATABASES {
    label 'process_single'
    storeDir 'db'

    output:
    path "SILVA_asv_db.fa.gz"             , emit: asvdb
    path "SILVA_species_db.fa.gz"         , emit: speciesdb

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    wget -c https://zenodo.org/records/4587955/files/silva_nr99_v138.1_train_set.fa.gz\\?download\\=1 \\
        -O SILVA_asv_db.fa.gz
    wget -c https://zenodo.org/records/4587955/files/silva_species_assignment_v138.1.fa.gz\\?download\\=1 \\
        -O SILVA_species_db.fa.gz
    """

    stub:
    def args = task.ext.args ?: ''
    
    """
    
    """
}
