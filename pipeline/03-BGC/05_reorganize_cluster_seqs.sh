#!/usr/bin/bash -l
#SBATCH -p short -c 2 --mem 8gb

python scripts/organize_clusterseq.py \
 -a results/bigscape_v2/output_files/protocl_simplematch_hybridoff_category_2025-05-14_13-10-19_c0.3/record_annotations.tsv \
 results/antismash_regions/fasta results/bigscape_v2.seq_by_class
