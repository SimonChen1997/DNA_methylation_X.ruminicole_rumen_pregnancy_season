#!/bin/bash -l
#SBATCH --job-name="motif_detection"
#SBATCH --partition=general
#SBATCH --array=13-52
#SBATCH -o motif_detection.o
#SBATCH -e motif_detection.e

#########################################################
module load anaconda3/2023.09-0

#########################################################
### get modification at base level
source activate ont-modkit-0.5.0

#### sakai
## targeting m6a
modkit motif search -i $pileup_bed/${SLURM_ARRAY_TASK_ID}_m6a.bed -r $ref \
    --min-coverage 5 --low-thresh 0.01 --min-sites 25 --high-thresh 0.7 --min-frac-mod 0.7 --skip-search --min-log-odds 1.6 \
    -o $motif_modkit/${SLURM_ARRAY_TASK_ID}_m6a.tsv --threads 1 --force-override-spec

## targeting m4C
modkit motif search -i $pileup_bed/${SLURM_ARRAY_TASK_ID}_m4c.bed -r $ref \
    --min-coverage 5 --low-thresh 0.01 --min-sites 25 --high-thresh 0.7 --min-frac-mod 0.7 --skip-search --min-log-odds 1.6 \
    -o $motif_modkit/${SLURM_ARRAY_TASK_ID}_m4c.tsv --threads 1 --force-override-spec

## targeting m5c
modkit motif search -i $pileup_bed/${SLURM_ARRAY_TASK_ID}_m5c.bed -r $ref \
    --min-coverage 5 --low-thresh 0.01 --min-sites 25 --high-thresh 0.7 --min-frac-mod 0.7 --skip-search --min-log-odds 1.6 \
    -o $motif_modkit/${SLURM_ARRAY_TASK_ID}_m5c.tsv --threads 1 --force-override-spec

#########################################################
source activate snappy

#### sakai
## targeting m6a
snappy -mk_bed $pileup_bed/${SLURM_ARRAY_TASK_ID}_m6a.bed -genome $ref -outdir $motif_snappy/${SLURM_ARRAY_TASK_ID}_m6a

## targeting m4c
snappy -mk_bed $pileup_bed/${SLURM_ARRAY_TASK_ID}_m4c.bed -genome $ref -outdir $motif_snappy/${SLURM_ARRAY_TASK_ID}_m4c

## targeting m5c
snappy -mk_bed $pileup_bed/${SLURM_ARRAY_TASK_ID}_m5c.bed -genome $ref -outdir $motif_snappy/${SLURM_ARRAY_TASK_ID}_m5c