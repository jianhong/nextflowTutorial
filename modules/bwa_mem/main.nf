params.options = [publish_dir:"."]
process BWA_MEM {
  tag "$meta.id"
  publishDir "${params.outdir}/${params.options.publish_dir}", mode: 'copy'
  conda (params.conda ? "bioconda::bwa=0.7.17 bioconda::samtools=1.09" : null)

  input:
    tuple val(meta), path(reads), path(genome), path(index)

  output:
    tuple val(meta), path("${meta.id}.srt.bam"), path("${meta.id}.srt.bam.bai"), emit: bam

  script:
  """
  bwa mem -t task.cpus $genome $reads \\
    | samtools view -@ $task.cpus -bS -o ${meta.id}.bam -
  samtools sort -o ${meta.id}.srt.bam ${meta.id}.bam
  samtools index ${meta.id}.srt.bam
  """
}
