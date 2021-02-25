/*
 * There are three steps for the PIPELINE
 * 1. fastQC
 * 2. trimgalore
 * 3. mapping
 */
params.options = [:]

include { PREPARE_GENOME    } from './modules/prepare_genome/main' addParams(options: [publish_dir: "genome"])
include { FASTQC            } from './modules/fastqc/main' addParams(options: [publish_dir: "fastqc"])
include { TRIMGALORE        } from './modules/trimgalore/main' addParams(options: [publish_dir: "trimmed"])
include { BWA_MEM           } from './modules/bwa_mem/main' addParams(options: [publish_dir: "mapping"])
workflow CHIPSEQ {
  take: ch_input
  main:
  ch_input.splitCsv(header: true)
    .map{ row ->
        fq1 = row.remove("fastq_1")
        fq2 = row.remove("fastq_2")
        def meta = row.clone()
        meta.id = row.group + "_R" + row.replicate
        meta.single_end = fq2 == ""
        [meta, [fq1, fq2]]}
    .set{ch_fastq}

  genome = Channel.fromPath(params.fasta)

  //prepare genome
  PREPARE_GENOME(genome)

  //fastqc
  FASTQC(ch_fastq)

  //trim reads
  TRIMGALORE(ch_fastq)

  //make Channel length to same
  reads = TRIMGALORE.out.reads.combine(PREPARE_GENOME.out.bwa_index)
  //mapping
  BWA_MEM(reads)

  // regroup the bams
  BWA_MEM.out.bam
    .map{
      meta, bam, bai ->
        [meta.group, [meta, bam, bai]]
    }
    .groupTuple()
    .map{
      group, data ->
        data
    }
    .view() // view the channel
}
