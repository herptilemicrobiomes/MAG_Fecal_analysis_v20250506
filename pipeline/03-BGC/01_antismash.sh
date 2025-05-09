#!/usr/bin/bash -l
#SBATCH -c 16 -N 1 -n 1 --mem 32gb  --out logs/antismash.%a.log -a 1 
hostname
CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

INPUT=input
OUTPUT=results/antismash
mkdir -p $OUTPUT
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
  N=$1
fi
if [ -z $N ]; then
  echo "cannot run without a number provided either cmdline or --array in sbatch"
  exit
fi
DIR=$(ls $INPUT | sed -n ${N}p)
BASE=$(basename $DIR)
mkdir -p $OUTPUT/$BASE
echo "running on $BASE to $OUTPUT/$BASE"
module load antismash

do_smash() {
	INGENOME=$1
	OUTDIR=$2
	CPUS=$3
	if [ ! -f $OUTDIR/index.html ]; then
		rm -rf $OUTDIR
		time antismash --genefinding-tool prodigal --output-dir $OUTDIR --taxon bacteria --cpus $CPUS \
		--cc-mibig --cb-general --cb-subclusters --cb-knownclusters --clusterhmmer --tigrfam \
		$INGENOME
	fi
}
export -f do_smash
CPUPER=$(expr $CPU / 2)
parallel -j 2 do_smash {} $OUTPUT/$BASE/{/.} $CPUPER ::: $(ls $INPUT/$DIR/bins/*.fa)
