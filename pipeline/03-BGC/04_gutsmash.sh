#!/usr/bin/bash -l
#SBATCH -p short -c 8 -N 1 -n 1 --mem 16gb  --out logs/gutsmash.%a.log -a 1-1508
CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

IN=input
OUT=gutsmash
mkdir -p $OUT
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
  N=$1
fi
if [ -z $N ]; then
  echo "cannot run without a number provided either cmdline or --array in sbatch"
  exit
fi
GENOME=$(ls $IN/*.fasta | sed -n ${N}p)
BASE=$(basename $GENOME .fasta)
if [[ ! -d $OUT/$BASE && ! -f $OUT/$OUT.zip ]]; then
    module load gutsmash
    mkdir -p $OUT/$BASE
    #time antismash --genefinding-tool prodigal --output-dir $OUT/$BASE --taxon bacteria --fullhmmer --clusterhmmer --tigrfam \
	#	--cc-mibig --cb-general --cb-subclusters --cb-knownclusters --pfam2go --cpus $CPU $GENOME 
    echo $BASE
    time run_gutsmash.py --genefinding-tool prodigal --output-dir $OUT/$BASE --taxon bacteria --cpus $CPU \
	 $GENOME
else
    echo "skipping $N $BASE already run"
fi
