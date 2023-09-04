#!/bin/bash

# Step 1: Align C5_pool.fastq to *.fasta
for fasta_file in *.fasta; do
    # Align using minimap2
    minimap2 -c -eqx -x map-ont "$fasta_file" E5_pool.fastq > alignment.paf

    # Step 2: Run perl oneliner on alignment.sam
    output_file="${fasta_file%.fasta}.txt"
    basename=$(basename "$output_file" .txt)
    
    perl -lane 'if(/tp:A:P/&&/NM:i:(\d+)/){$n=$1;$l=0;$l+=$1 while/(\d+)M/g;print("$F[0]\t".($l-$n)/$l)}' alignment.paf > "$output_file"

    # Clean up intermediate files (optional)
    rm alignment.paf
done
