#!/bin/bash

for i in $(cat SRRaccessions.txt)
do
bwa mem pa14.fna $i"_1_val_1.fq" $i"_2_val_2.fq" | samtools sort | samtools view -F 4 -o $i".sorted.bam"
done
