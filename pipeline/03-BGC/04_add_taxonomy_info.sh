#!/usr/bin/bash -l
#SBATCH -p short -c 4 --mem 8gb
python scripts/add_taxonomy_to_bigscape_recordannot.py  \
	-i results/bigscape_v2/output_files/2025-05-12_15-18-08_c0.3/record_annotations.tsv \
	--gtdbtk results/gtkdb/bincount_18385/gtdbtk.bac120.summary.tsv  results/gtkdb/bincount_18385/gtdbtk.ar53.summary.tsv \
	--metadata lib/animal_metadata.csv lib/wood_frog.csv \
	-o results/bigscape_v2/output_files/2025-05-12_15-18-08_c0.3/record_annotations.gtdbtk.tsv 

pigz -fk results/bigscape_v2/output_files/2025-05-12_15-18-08_c0.3/record_annotations.gtdbtk.tsv 
