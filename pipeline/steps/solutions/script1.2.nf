#!/usr/bin/env nextflow

params.reads = "$projectDir/../../data/ggal/gut_{1,2}.fq"
params.transcriptome_file = "$projectDir/../../data/ggal/transcriptome.fa"
params.multiqc = "$projectDir/multiqc"
params.outdir = "$projectDir/results"

workflow {
    println "reads: $params.reads"
}
