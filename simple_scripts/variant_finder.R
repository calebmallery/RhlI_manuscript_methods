#Install and load required packages
if (!requireNamespace("devtools", quietly=TRUE))
  install.packages("devtools")
devtools::install_github("YuLab-SMU/ggmsa")

library(ggmsa)

#Upload sequnece file
protein_sequences <- "/path/to/sequence/file.txt"
x <- readAAStringSet(protein_sequences)

#Create a df with the residues at positions X
data = tidy_msa(x, 62, 63)

#Write the output to a csv file
write.csv(data, "/Users/calebmallery/Desktop/rhlI_83.csv", row.names=FALSE)