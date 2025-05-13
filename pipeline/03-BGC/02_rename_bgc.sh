#!/usr/bin/bash -l
#SBATCH -c 8 --mem 16gb -p short

module load biopython
python scripts/gather_rename_AS_regionfiles.py results/antismash results/antismash_regions
