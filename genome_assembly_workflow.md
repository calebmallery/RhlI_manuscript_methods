Objective: Perform reference based genome assemblies for P. aeruginosa acute clinical isolates from NCBI BioProject `PRJNA288601`.

Download the raw fastq files from the SRA

Clean your raw reads and remove any remaining adapters with TrimGalore, where fastq_R1 and fastq_R2 are your fastq files.

	trim_galore -q 20 --length 100 --paired fastq_R1 fastq_R2

 This can be run on many files at once

	parallel --xapply trim_galore --paired --length 100 -q 20 -o trim_galore/ ::: *_R1.fastq.gz ::: *_R2.fastq.gz

Download the reference genome

	datasets download genome accession GCF_000014625.1
	unzip ncbi_dataset.zip
	cd ncbi_dataset/data/GCF_000014625.1
	mv GCF_000014625.1_ASM1462v1_genomic.fna pa14_reference.fna
 > I like to rename the file to something more meaningful and easier for downstream use.

 Index the reference genome
 
	bwa index pa14_reference_genomic.fna
 
 Map trimmed reads to the reference genome
 
	bwa mem pa14_reference.fna sample_R1_val_1.fq.gz sample_R2_val_2.fq.gz | samtools sort | samtools view -Sb -o sample_sorted.bam

 Assess the quality of the alignments
  
	samtools flagstat sample_sorted.bam

> Here is an example of output from samtools flagstat.

 Index the sorted.bam file for mpileup
  
	 samtools faidx sample.sorted.bam

Coverage summary (base pair resolution).
 
	 bcftools mpileup -f pa14_reference.fna sample_sorted.bam  | bcftools call -c -o sample.vcf
  
> The **`-c`** flag specifies.

Compress the .vcf file using bcftools
 
	 bcftools convert sample.vcf -O z -o sample.vcf.gz
    
> The **`-c`** flag specifies.

Index compressed vcf
 
	 bcftools index sample.vcf.gz

FASTA file generation
 
	 bcftools consensus -f pa14_reference_genomic.fna sample.vcf.gz -o sample.fasta

> The **`-c`** flag specifies.


