#!/usr/bin/bash -l
#SBATCH --nodes 1 --ntasks 24 -p short --mem=8G 
#SBATCH --job-name=CAZY
#SBATCH --output=logs/domains.CAZY.%a.log -a 1-1508
module load workspace/scratch
module load db-cazy

export OMPI_TMPDIR=$SCRATCH
hostname
DOMAINS=domains
EXT=aa
PROTEINS=annotation

mkdir -p $DOMAINS/CAZY

if [ ! $CAZY_DB ]; then
 echo "Need a CAZY_DB env variable either from config.txt or 'module load db-cazy'"
g exit
fi
CPUS=${SLURM_CPUS_ON_NODE}
if [ ! $CPUS ]; then
 CPUS=1
fi

IN=${SLURM_ARRAY_TASK_ID}

if [ -z "$IN" ]; then
 IN=$1
 if [ -z "$IN" ]; then
   IN=1
   echo "defaulting to IN value is 1 - specify with --array or cmdline"
 fi
fi

TOTAL=$(ls ${PROTEINS}/*.${EXT} | wc -l)
if [ $IN -gt $TOTAL ]; then
 echo "Only $TOTAL files in folder $PROTEINS, skipping $IN"
 exit
fi
INFILE=$(ls ${PROTEINS}/*.${EXT} | sed -n ${IN}p)
OUT=$DOMAINS/CAZY/$(basename ${INFILE} .${EXT})
echo "processing $INFILE"
if [ ! -s ${OUT}.tsv ]; then
    module load hmmer/3.3.2-mpi
    # hmmscan --cpu $CPUS --domtbl ${OUT}.domtbl -o ${OUT}.hmmscan $CAZY_DB $INFILE
    srun hmmscan --mpi --domtbl ${OUT}.domtbl -o ${OUT}.hmmscan $CAZY_DB $INFILE
    bash $CAZY_FOLDER/hmmscan-parser.sh ${OUT}.domtbl | sort > ${OUT}.tsv
    module unload hmmer
fi
echo "skipping the hotpep runs as this is pretty slow and maybe unnecessary for simple profiles"
exit
if [[ ! -d $OUT.run_dbcan || ! -f $OUT.run_dbcan/overview.txt ]]; then
    module load run_dbcan    
    module load hmmer/3
    run_dbcan --db_dir $CAZY_FOLDER --out_dir $OUT.run_dbcan --tools all \
	    --dbcan_thread $CPUS --stp_cpu $CPUS --hmm_cpu $CPUS --dia_cpu $CPUS --tf_cpu $CPUS \
	    --use_signalP true $INFILE protein 
fi
