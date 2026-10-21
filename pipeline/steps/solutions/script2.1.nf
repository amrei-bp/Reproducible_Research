#!/usr/bin/env nextflow

/*
 * pipeline input parameters
 */
params.reads = "$projectDir/../../data/ggal/gut_{1,2}.fq"
params.transcriptome_file = "$projectDir/../../data/ggal/transcriptome.fa"
params.multiqc = "$projectDir/multiqc"
params.outdir = "results"

/*
 * define the `INDEX` process that creates a binary index
 * given the transcriptome file
 */
process INDEX {
    container 'oras://community.wave.seqera.io/library/salmon:2.7.0--cb05356ce9eb88b7'
    publishDir "$params.outdir/salmon"

    input:
    path transcriptome

    output:
    path 'salmon_index'

    script:
    """
    salmon index --threads $task.cpus -t $transcriptome -i salmon_index
    """
}

workflow {
    log.info """\
        R N A S E Q - N F   P I P E L I N E
        ===================================
        transcriptome: ${params.transcriptome_file}
        reads        : ${params.reads}
        outdir       : ${params.outdir}
        """
        .stripIndent()

    index_ch = INDEX(file(params.transcriptome_file, checkIfExists: true))
}
