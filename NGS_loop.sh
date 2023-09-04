for file in *.fastq; do
bn=`basename $file .fastq`
NGSpeciesID --ont --consensus --sample_size 300 --m 1500 --s 300 --medaka --fastq $file --outfolder ${bn}
done