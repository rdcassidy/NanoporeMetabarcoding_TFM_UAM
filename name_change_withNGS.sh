#!/bin/bash

# Get the current working directory
directory=$(pwd)

# Check if the specified directory exists
if [ ! -d "$directory" ]; then
  echo "Error: Directory not found!"
  exit 1
fi

# Change to the directory
cd "$directory" || exit 1

# Loop through each folder
for folder in */; do
  # Extract the first two characters from the folder name
  new_name="${folder:0:2}"

  # Check if the new name is not empty and different from the current name
  if [[ -n "$new_name" && "$new_name" != "$folder" ]]; then
    # Rename the folder
    mv "$folder" "$new_name"
    echo "Renamed '$folder' to '$new_name'"
  fi
done

# Loop through each folder again to rename FASTA files inside "medaka" folders
for folder in */; do
  # Check if the folder name starts with "medaka"
  if [[ "$folder" == medaka* && -d "$folder" ]]; then
    # Extract the parent directory name
    parent_name=$(dirname "$folder")
    # Call the function to rename FASTA files inside "medaka" folders
    rename_fasta_files "$folder" "$parent_name"
  fi
done

#change consensus sequences to same name as their parent directories#
find . -type f -name "consensus.fasta" -exec sh -c 'parent_dir=$(dirname "$0"); mv "$0" "$parent_dir/${parent_dir##*/}.fasta"' {} \;

#delete non-polished consensus sequences#
find . -type f -name "consensus*" -delete

#move all polished consensus sequences to the same separate working folder 
mkdir ../polished_reads

mv */*.fasta ../polished_reads/

#rename all fasta headers to match well id/filename#

for file in *.fasta; do awk '/^>/{sub(/^>.*/, "> " substr(FILENAME, 1, 2))}1' "$file" > tmpfile && mv tmpfile "$file"; done

#concatenate all fastas into one#
cat *.fasta > all_together_polished_refs.fasta




