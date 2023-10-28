RhlI orthologous sequences were downloaded from the following link on Pseudomonas Genome DB (https://pseudomonas.com/orthologs/list?id=1653897) which resulted in the following .csv file `pa_rhli.csv`. Sequences and sequence names were extracted and saved as a new file `pa_rhli.faa`.

Sequences were aligned with muscle

    muscle -in pa_rhli.faa -out pa_rhli_aln.faa -maxiters 3
> Note: The '**-maxiters**' is set to 3 to specify how many iterations of [MUSCLE](https://www.drive5.com/muscle/) to run.
Trimmed with trimal
    
    trimal -in pa_rhli_aln.faa -out pa_rhli_aln_trm.faa -keepheader -gt 0.8 -st 0.001 -cons 60

Tree made with iTOL

    iqtree -s pa_rhli_aln_trm.faa -bb 1000 -m
> Note: The '**-keepheader**' option sepcifies to keep headers, I've had unfortunate times with trimal stealing my headers without
> this flag. '**-gt 0.8**' specifies a gap-threshold of 0.8, '**-st 0.001**' specfies the minimum similarity allowed, and '**-cons 60**' specifiees the minimum percentage of positions from the original alignment to conserve.

Although I did not end up using this in the analysis for the final manuscript, I did write a tiny script to ID which of these PA strains had our rhlI variants of interest `variant_finder.R`.
finding which pa genomes have our mutants


