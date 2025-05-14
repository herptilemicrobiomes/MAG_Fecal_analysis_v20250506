#!/usr/bin/bash -l
#SBATCH -p epyc -c 48 -N 1 -n 1 --mem 512gb --out logs/bigscape_v2.%A.log
CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi
module load bigscape/2.0
module load db-pfam
pushd results
mkdir -p bigscape_v2
bigscape cluster --mibig-version 4.0 --include-singletons --input-dir antismash --output-dir bigscape_v2 --pfam-path $PFAM_DB/Pfam-A.hmm -c $CPU
