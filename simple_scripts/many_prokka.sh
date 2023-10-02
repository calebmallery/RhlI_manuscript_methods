#!/bin/bash
for i in $(cat SRRaccessions.txt)
do 
docker run --rm -v $(pwd):/data -w /data staphb/prokka prokka --outdir PROKKA_"$i" "$i" --proteins pa14.faa
done
