Commands issued for reference based genome assemblies for P. aeruginosa acute clinical isolates from NCBI BioProject `PRJNA288601` and annotation.
# Reference-based assembly
Download the raw fastq files from the Sequence Read Archive (SRA).

	fasterq-dump SRRaccession
 > All of the SRR names used in this study can be found in `SRRaccessions.txt`

Clean raw reads by length and Phred score and remove any remaining adapters.

	trim_galore -q 20 --length 100 --paired fastq_R1 fastq_R2
> **`-q`** specifies a minimum quality Phred score of 20. **`--length`** will discard any reads >100 bp.

 This can also be run on many files at once.

	parallel --xapply trim_galore --paired --length 100 -q 20 -o trim_galore/ ::: *_R1.fastq.gz ::: *_R2.fastq.gz

Download the reference genome.

	datasets download genome accession GCF_000014625.1
	unzip ncbi_dataset.zip
	cd ncbi_dataset/data/GCF_000014625.1
	mv GCF_000014625.1_ASM1462v1_genomic.fna pa14_reference.fna
 > I like to rename the file to something more meaningful and easier for downstream use.

 > Reference file can be found in this repository `data/pa14_reference.fna`

 Index the reference genome.
 
	bwa index pa14_reference_genomic.fna
 
 Map trimmed reads to the reference genome.
 
	bwa mem pa14_reference.fna sample_R1_val_1.fq.gz sample_R2_val_2.fq.gz | samtools sort | samtools view -Sb -o sample_sorted.bam
> Note: this command pipes to **`samtools`** twice - once to sort the reads and the next time to convert the output to binary format (SAM to BAM) and save the file.
> The **`-F 4`** flag specifies **`samtools`** to exclude unaligned reads to the output .bam file.

This can also be done on many files at once (see `many_bwa.mem.sh`).
 	
	ls *_1.fq.gz | cut -d "_" -f 1 > SRRaccessions.txt
 	nano bwa.mem.sh
 	chomd a+x bwa.mem.sh
  	./bwa.mem.sh
> Note: copy `many_bwa.mem.sh` to a new file and execute the above commands. It will only work if the file extensions are the same as above.

Many can also be done in just one line if preffered.
  
	for i in `cat SRRaccessions.txt`; do bwa mem pa14_reference.fna $i"_1_val_1.fq.gz" $i"_2_val_2.fq.gz" | samtools sort | samtools view -F 4 -o $i".sorted.bam"; done
 
 Assess the quality of the alignments.
  
	samtools flagstat sample_sorted.bam

>Example **`flagstat`**  output from (https://github.com/bahlolab/bioinfotools/blob/master/SAMtools/flagstat.md):
 
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

 Index the sorted.bam file for **`mpileup`** .
  
	 samtools faidx sample.sorted.bam

Coverage summary (base pair resolution).
 
	 bcftools mpileup -f pa14_reference.fna sample_sorted.bam  | bcftools call -m -o sample.vcf
  
> The **`-m`** flag specifies the multi-allelic variant caller for identifying genotype liklehoods.

Compress the vcf file using **`bcftools`** .
 
	 bcftools convert sample.vcf -O z -o sample.vcf.gz
    
> The **`-O z`** flag specifies a compressed vcf output file.

Index the compressed vcf file.
  
	 bcftools index sample.vcf.gz

FASTA file generation. Applies the VCF file to a known reference sequence.
 
	 bcftools consensus -f pa14_reference.fna sample.vcf.gz -o sample.fasta

> The output of **`bcftools consensus`**  can be used as input for annotation.
#Genome annotation
Prokka used for annotation
 
	prokka --outdir path/to/outdir path/to/inputfile --proteins pa14_refernce.faa
> The **`--proteins`** flag points prokka towards `pa14_reference.faa` (reference proteome) this is used to generate compatable gene names to use in the output files.
> Reference file can be found in this repository `data/pa14_reference.faa`

This can be run across many files 

	 ls *.fasta > prokka_list
  	 nano many_prokka.sh
         chmod a+x many_prokka.sh
	 ./many_prokka.sh
  > Note: copy `many_prokka.sh` to a new file and execute the above commands. It will only work if the file extensions are the same as above.

 Using the annotations outlined above, sequences annotated as being rhlI were subject to the BLASTp tool on Pseudomonas DB to identify mutations.
 A file with all rhlI sequences was made `rhli.faa`.

 RhlI sequences were aligned and trimed:

 	muscle -in rhlI.faa -out rhlI_aln.faa -maxiters 3
> Note: The '**-maxiters**' is set to 3 to specify how many iterations of [MUSCLE](https://www.drive5.com/muscle/) to run.

	trimal -in rhlI_aln.faa -out rhlI_aln_trm.faa -keepheader -gt 0.8 -st 0.001 -cons 60
> Note: The '**-keepheader**' option sepcifies to keep headers, I've had unfortunate times with trimal stealing my headers without
> this flag. '**-gt 0.8**' specifies a gap-threshold of 0.8, '**-st 0.001**' specfies the minimum similarity allowed, and '**-cons 60**' specifiees the minimum percentage of positions from the original alignment to conserve.

Tree was generated using iqtree
	
 	iqtree -s rhlI_aln_trm.faa -bb 1000 -m AUTO
> Note: The tree was visualized using [iTOL](https://itol.embl.de/).
