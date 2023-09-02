finding which pa genomes have our mutants
protein_sequences <- "/Users/calebmallery/Desktop/pqse_evol_manuscript/luxR_homologues.txt"
x <- readAAStringSet(protein_sequences)
data = tidy_msa(x, 62, 63)
write.csv(data, "/Users/calebmallery/Desktop/rhlI_83.csv", row.names=FALSE)

ggtree(tree, ignore.negative.edge = TRUE, branch.length="none", layout="circular",color="grey") +
