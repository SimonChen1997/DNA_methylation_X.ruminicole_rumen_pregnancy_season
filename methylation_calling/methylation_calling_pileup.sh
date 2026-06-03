#!/bin/bash -l
#SBATCH --job-name="methylation_calling_pileup"
#SBATCH --partition=general
#SBATCH --array=41-77
#SBATCH -o methylation_calling_pileup.o
#SBATCH -e methylation_calling_pileup.e

#########################################################
module load anaconda3/2023.09-0
module load samtools/1.18-gcc-12.3.0

#########################################################
TASK_ID_PADDED=$(printf "%02d" $SLURM_ARRAY_TASK_ID)

#########################################################
### mapping to reference genome
source activate minimap2

minimap2 -y -ax lr:hq $ref $fastq_filter/barcode${TASK_ID_PADDED}.fastq -t 5 -o $TMPDIR/barcode${TASK_ID_PADDED}.sam
samtools sort $TMPDIR/barcode${TASK_ID_PADDED}.sam -T $TMPDIR/barcode${TASK_ID_PADDED}.sorted -@ 10 --write-index -o $minimap2_k2/barcode${TASK_ID_PADDED}.sorted.bam

#########################################################
### adjust the modification information in bam file
source activate ont-modkit-0.5.0
## targeting m6A
modkit adjust-mods $minimap2_k2/barcode${TASK_ID_PADDED}.sorted.bam stdout --ignore m |\
    modkit adjust-mods stdin $minimap2_primary_m6a_subsample/barcode${TASK_ID_PADDED}_m6a.bam --ignore 21839

## targeting m4C
modkit adjust-mods $minimap2_k2/barcode${TASK_ID_PADDED}.sorted.bam stdout --ignore m |\
    modkit adjust-mods stdin $minimap2_primary_m4c_subsample/barcode${TASK_ID_PADDED}_m4c.bam --ignore a

## targeting m5C
modkit adjust-mods $minimap2_k2/barcode${TASK_ID_PADDED}.sorted.bam stdout --ignore 21839 |\
    modkit adjust-mods stdin $minimap2_primary_m5c_subsample/barcode${TASK_ID_PADDED}_m5c.bam --ignore a


#########################################################
### sort and index bam file
## targeting m6a
samtools view -bhS $minimap2_primary_m6a_subsample/barcode${TASK_ID_PADDED}_m6a.bam | \
    samtools sort -T $TMPDIR/barcode${TASK_ID_PADDED}_m6a.sorted -o $minimap2_primary_m6a_subsample/barcode${TASK_ID_PADDED}_m6a.sorted.bam
	
samtools index $minimap2_primary_m6a_subsample/barcode${TASK_ID_PADDED}_m6a.sorted.bam
	
## targeting m4c
samtools view -bhS $minimap2_primary_m4c_subsample/barcode${TASK_ID_PADDED}_m4c.bam | \
    samtools sort -T $TMPDIR/barcode${TASK_ID_PADDED}_m4c.sorted -o $minimap2_primary_m4c_subsample/barcode${TASK_ID_PADDED}_m4c.sorted.bam
	
samtools index $minimap2_primary_m4c_subsample/barcode${TASK_ID_PADDED}_m4c.sorted.bam
	
## targeting m5c
samtools view -bhS $minimap2_primary_m5c_subsample/barcode${TASK_ID_PADDED}_m5c.bam | \
    samtools sort -T $TMPDIR/barcode${TASK_ID_PADDED}_m5c.sorted -o $minimap2_primary_m5c_subsample/barcode${TASK_ID_PADDED}_m5c.sorted.bam
	
samtools index $minimap2_primary_m5c_subsample/barcode${TASK_ID_PADDED}_m5c.sorted.bam


#########################################################
### adjust the modification information in bam file
source activate ont-modkit-0.5.0

## targeting m6A
modkit pileup $minimap2_primary_m6a_subsample/barcode${TASK_ID_PADDED}_m6a.sorted.bam $modkit_pileup_primary_m6a/barcode${TASK_ID_PADDED}_m6a.bed --motif A 0 --ref $ref --filter-threshold 0.9

## targeting m4C
modkit pileup $minimap2_primary_m4c_subsample/barcode${TASK_ID_PADDED}_m4c.sorted.bam $modkit_pileup_primary_m4c/barcode${TASK_ID_PADDED}_m4c.bed --motif C 0 --ref $ref --filter-threshold 0.9

## targeting m5C
modkit pileup $minimap2_primary_m5c_subsample/barcode${TASK_ID_PADDED}_m5c.sorted.bam $modkit_pileup_primary_m5c/barcode${TASK_ID_PADDED}_m5c.bed --motif C 0 --ref $ref --filter-threshold 0.9

