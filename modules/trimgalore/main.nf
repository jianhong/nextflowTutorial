params.options = [publishDir:'.']
process TRIMGALORE {
  tag "$meta.id"
  publishDir "${params.outdir}/${params.options.publish_dir}", mode: 'copy'
  conda (params.conda ? "bioconda::cutadapt=1.18 bioconda::trim-galore=0.6.6" : null)

  input:
    tuple val(meta), path(reads)

  output:
    tuple val(meta), path("*.fq.gz"), emit: reads

  script:
    def prefix = meta.id
    if(meta.single_end){
      """
      [ ! -f  ${prefix}.fastq.gz ] && ln -s $reads[0] ${prefix}.fastq.gz
      trim_galore --cores $task.cpus --gzip ${prefix}.fastq.gz
      """
    }else{
      """
      [ ! -f  ${prefix}_1.fastq.gz ] && ln -s ${reads[0]} ${prefix}_1.fastq.gz
      [ ! -f  ${prefix}_2.fastq.gz ] && ln -s ${reads[1]} ${prefix}_2.fastq.gz
      trim_galore --paired --cores $task.cpus --gzip ${prefix}_1.fastq.gz ${prefix}_2.fastq.gz
      """
    }
}
