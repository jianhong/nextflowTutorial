params.options = [publish_dir:"."]

process PREPARE_GENOME {
  publishDir "${params.outdir}/${params.options.publish_dir}", mode: 'copy'
  conda (params.conda ? "bioconda::bwa=0.7.17" : null)

  input:
    path genome
  output:
    tuple path(genome), path("*"), emit: bwa_index

  script:

  """
  bwa index $genome
  """
}
