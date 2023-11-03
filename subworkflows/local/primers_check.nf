//
// Check primersheet
//

include { PRIMERSHEET_CHECK } from '../../modules/local/primersheet_check'

workflow PRIMER_CHECK {
    take:
    primersheet

    main:    
    PRIMERSHEET_CHECK ( primersheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_primer_channel(it) }
        .set { primers }

    emit:
    primers                                   // channel: [ forward_primer, reverse_primer ]
    versions = PRIMERSHEET_CHECK.out.versions // channel: [ versions.yml ]
}

def create_primer_channel(LinkedHashMap row) {
    def primer = [:]
    primer.forward         = row.forward_primer
    primer.reverse         = row.reverse_primer

    return primer
}
