#!/usr/bin/bash -l
#SBATCH -p short --mem 8gb -c 2 --out logs/protein_summary.log

#CAZY
perl scripts/gather_CAZY_counts.pl
perl scripts/gather_CAZY_counts.pl --merge

#perl scripts/gather_CAZY_rundbcan_counts.pl # currently fails

# pfam
perl scripts/gather_hmmscanMPI_domain_counts.pl
perl scripts/gather_hmmscanMPI_domain_counts.pl --merge

# MEROPS
perl scripts/gather_MEROPS_family_counts.pl 
perl scripts/gather_MEROPS_family_counts.pl --merge

module load KEGG-Decoder
#KEGG
for BASE in $(ls domains/kofam | perl -p -e 's/\.bin\S+//' | sort | uniq | grep UHM840) 
do
	cat domains/kofam/${BASE}.bin*.tsv | perl -p -e 's/\.(k\d+)_(\d+)_(\d+)/_$1.$2.$3/; s/bin_/bin./' > summary/${BASE}.kofam.tsv
	KEGG-decoder -i summary/${BASE}.kofam.tsv -o summary/${BASE}.kofam.function.list -v static
done
cat summary/*.kofam.tsv | perl -p -e 's/\.bin/_bin/' > kofam_all.tsv
KEGG-decoder -i summary/kofam_all.tsv -o summary/kofam_all.function.list -v static

