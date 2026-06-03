#!/bin/bash -l
#SBATCH --job-name="xruminicola_data_filtering"
#SBATCH --partition=general
#SBATCH --array=41-77
#SBATCH -o xruminicola_data_filtering.o
#SBATCH -e xruminicola_data_filtering.e

#########################################################
module load anaconda3
module load samtools

#########################################################
TASK_ID_PADDED=$(printf "%02d" $SLURM_ARRAY_TASK_ID)

#########################################################
### mapping to reference genome
source activate minimap2

minimap2 -y -ax lr:hq $ref $chopper/barcode${TASK_ID_PADDED}.fastq -t 5 -o $TMPDIR/barcode${TASK_ID_PADDED}.sam
samtools sort $TMPDIR/barcode${TASK_ID_PADDED}.sam -T $TMPDIR/barcode${TASK_ID_PADDED}.sorted -@ 10 --write-index -o $minimap2/barcode${TASK_ID_PADDED}.sorted.bam

#########################################################
### extract only the primary mapped reads
samtools view -F 0x900 -F 4 -@ 10 -bhS $minimap2/barcode${TASK_ID_PADDED}.sorted.bam > $minimap2_primary/barcode${TASK_ID_PADDED}.sorted.bam
samtools index $minimap2_primary/barcode${TASK_ID_PADDED}.sorted.bam
samtools fastq -T ML,MM,MN $minimap2_primary/barcode${TASK_ID_PADDED}.sorted.bam > $fastq_primary/barcode${TASK_ID_PADDED}.fastq

#########################################################
### primary mapped reads for taxanomic classification
source activate kraken2_v2

k2 classify --db $db --output output.txt --threads 6 $fastq_primary/barcode${TASK_ID_PADDED}.fastq \
    --report $kraken2_dir/barcode${TASK_ID_PADDED}.report --output $kraken2_dir/barcode${TASK_ID_PADDED}.tsv

#########################################################
### extract reads mapped to xruminicola
source activate krakentools

extract_kraken_reads.py -k $kraken2_dir/barcode${TASK_ID_PADDED}.tsv -t 839 -s $fastq_primary/barcode${TASK_ID_PADDED}.fastq --fastq-output -o $fastq_filter/barcode${TASK_ID_PADDED}.fastq