#!/bin/bash

for i in $(cat SRR_list)
do 
docker run --rm -v $(pwd):/data -w /data staphb/prokka prokka --outdir PROKKA_"$i" "$i" --proteins pa14.faa
done
