#!/bin/bash

for i in $(cat SRR_list)
do
bwa mem pa14.fna $i"_1_val_1.fq" $filn"_2_val_2.fq" | samtools sort | samtools view -F 4 -o $filn".sorted.bam"
done
