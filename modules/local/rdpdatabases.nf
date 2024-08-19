process RDPDATABASES {
    label 'process_single_med'
    storeDir 'db'

    output:
    path "rdp_16s_v18.fa"              , emit: rdp_16s_v18_db
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    wget -c https://www.drive5.com/sintax/rdp_16s_v18.fa.gz -O rdp_16s_v18.fa.gz
    gunzip rdp_16s_v18.fa.gz
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        RDP: v18
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    
    """
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        RDP: v18
    END_VERSIONS
    """
}
