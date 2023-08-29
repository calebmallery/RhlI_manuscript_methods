Objective: Perform reference based genome assemblies for P. aeruginosa acute clinical isolates from NCBI BioProject `PRJNA288601`.

Download the raw fastq files from the Sequence Read Archive (SRA)

	fasterq-dump SRRname
 > All of the SRR names used in this study can be found in `SRRnames.txt`

Clean your raw reads and remove any remaining adapters with TrimGalore, where fastq_R1 and fastq_R2 are your fastq files.

	trim_galore -q 20 --length 100 --paired fastq_R1 fastq_R2
> **`-q`** specifies a minimum quality Phred score of 20. **`--length`** will discard any reads >100 bp.

 This can also be run on many files at once

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
> Note: this command pipes to **`samtools`** twice - once to sort the reads and the next time to convert the output to binary format (SAM to BAM) and save the file.
> The **`-F 4`** flag specifies **`samtools`** to exclude unaligned reads to the output .bam file.
 Assess the quality of the alignments

This can also be done on many files at once (see `bwa.mem.sh`).
 	
	ls *_1.fq.gz | cut -d "_" -f 1 > SRRlist.txt
 	nano bwa.mem.sh
 	chomd a+x bwa.mem.sh
  	./bwa.mem.sh
> Note: copy `bwa.mem.sh` to a new file and execute the above commands. It will only work if the file extensions are the same as above.

 Assess the quality of the alignments
  
	samtools flagstat sample_sorted.bam

>Example flagstat output from (https://github.com/bahlolab/bioinfotools/blob/master/SAMtools/flagstat.md):
 
	 1 480861162 + 0 in total (QC-passed reads + QC-failed reads)
	 2 0 + 0 secondary
	 3 3055712 + 0 supplementary
	 4 0 + 0 duplicates
	 5 475908985 + 0 mapped (98.97%:-nan%)
	 6 477805450 + 0 paired in sequencing
	 7 238902725 + 0 read1
	 8 238902725 + 0 read2
	 9 461777552 + 0 properly paired (96.65%:-nan%)
	 10 472089012 + 0 with itself and mate mapped
	 11 764261 + 0 singletons (0.16%:-nan%)
  	 12 5697922 + 0 with mate mapped to a different chr
	 13 2424881 + 0 with mate mapped to a different chr (mapQ>=5).
> In this output, I commonly check line 1 for the number of QC-passed reads and line 5 for the percentage of reads mapped.

 Index the sorted.bam file for mpileup
  
	 samtools faidx sample.sorted.bam

Coverage summary (base pair resolution).
 
	 bcftools mpileup -f pa14_reference.fna sample_sorted.bam  | bcftools call -m -o sample.vcf
  
> The **`-m`** flag specifies the multi-allelic variant caller for identifying genotype liklehoods.

Compress the .vcf file using bcftools
 
	 bcftools convert sample.vcf -O z -o sample.vcf.gz
    
> The **`-O z`** flag specifies a compressed .vcf output file.

Index compressed vcf
 
	 bcftools index sample.vcf.gz

FASTA file generation. Applies the VCF file to a known reference sequence.
 
	 bcftools consensus -f pa14_reference_genomic.fna sample.vcf.gz -o sample.fasta

> The output of bcftools consensus can be used as input for annotation.


