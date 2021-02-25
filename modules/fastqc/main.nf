params.options = [publish_dir:"."]

process FASTQC {
  tag "$meta.id"
  publishDir "${params.outdir}/${params.options.publish_dir}", mode: 'copy'
  conda (params.conda ? "bioconda::fastqc=0.11.9" : null)

  input:
    tuple val(meta), path(reads)

  output:
    tuple val(meta), path("*.html"), emit: html

  script:
    def prefix = meta.id
    if(meta.single_end){
      """
      [ ! -f  ${prefix}.fastq.gz ] && ln -s $reads[0] ${prefix}.fastq.gz
      fastqc --threads $task.cpus ${prefix}.fastq.gz
      """
    }else{
      """
      [ ! -f  ${prefix}_1.fastq.gz ] && ln -s ${reads[0]} ${prefix}_1.fastq.gz
      [ ! -f  ${prefix}_2.fastq.gz ] && ln -s ${reads[1]} ${prefix}_2.fastq.gz
      fastqc --threads $task.cpus ${prefix}_1.fastq.gz ${prefix}_2.fastq.gz
      """
    }
}
