#!/bin/bash -l
#SBATCH --job-name="read_quality_control"
#SBATCH --partition=general
#SBATCH --array=41-77
#SBATCH -o read_quality_control.o
#SBATCH -e read_quality_control.e

#########################################################
module load anaconda3
module load samtools

#########################################################
TASK_ID_PADDED=$(printf "%02d" $SLURM_ARRAY_TASK_ID)

#########################################################
### extract fastq with methylation tag
samtools fastq -T ML,MM,MN $output_scratch_demultiplex/barcode${TASK_ID_PADDED}.bam > $fastq_sup/barcode${TASK_ID_PADDED}.fastq

#########################################################
### map data to the bovine reference genome
source activate minimap2

minimap2 -y -ax lr:hq $bovine_ref $fastq_sup/barcode${TASK_ID_PADDED}.fastq -o $TMPDIR/barcode${TASK_ID_PADDED}.sam
samtools sort $TMPDIR/barcode${TASK_ID_PADDED}.sam -T $TMPDIR/barcode${TASK_ID_PADDED}.sorted -@ 20 --write-index -o $minimap_host/barcode${TASK_ID_PADDED}.sorted.bam

#########################################################
### exclude the reads mapped to bovine genome
samtools view -@ 20 -f 4 -bhS $minimap_host/barcode${TASK_ID_PADDED}.sorted.bam | samtools fastq -@ 20 -T ML,MM,MN - > $dehost/barcode${TASK_ID_PADDED}.fastq

#########################################################
### remove short reads
source activate chopper

chopper -q 10 -l 250 -i $dehost/barcode${TASK_ID_PADDED}.fastq > $chopper_dir/barcode${TASK_ID_PADDED}.fastq