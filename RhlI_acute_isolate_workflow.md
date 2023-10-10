RhlI orthologous sequences were downloaded from the following link on Pseudomonas Genome DB (https://pseudomonas.com/orthologs/list?id=1653897)

Sequences were aligned with muscle
muscle code

Trimmed with trimal
trimal code

Tree made with iTOL



Did not end up including this in the final manuscript but to find which strains had our rhlI variants of interest
finding which pa genomes have our mutants
protein_sequences <- "/Users/calebmallery/Desktop/pqse_evol_manuscript/luxR_homologues.txt"
x <- readAAStringSet(protein_sequences)
data = tidy_msa(x, 62, 63)
write.csv(data, "/Users/calebmallery/Desktop/rhlI_83.csv", row.names=FALSE)

