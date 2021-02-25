#!/usr/bin/env nextflow
nextflow.enable.dsl=2

def options = [:]

log.info """\
NEXTFLOW PIPELINE
=================
input : ${params.input}
fasta : ${params.fasta}
outdir: ${params.outdir}
"""

ch_input = Channel.fromPath(params.input)

include { CHIPSEQ } from './chipseq' addParams(options: options)
workflow {
  CHIPSEQ(ch_input)
}

workflow.onComplete {
  log.info ( workflow.success ? "\nDone!": "\nOops..\nSomething went wrong!")
}
