params.options = [:]
process CHECKSUM {
  publishDir "${params.outdir}/${params.options.publish_dir}"
  input: tuple val(meta), path(reads)
  output: path("md5.*.txt")
  script:
  def prefix = meta.id
  if (meta.single_end) {
        """
        md5 ${reads[0]} > md5.${prefix}.txt
        """
    } else {
        """
        md5 ${reads[0]} > md5.${prefix}.txt
        md5 ${reads[1]} >> md5.${prefix}.txt
        """
    }
}
