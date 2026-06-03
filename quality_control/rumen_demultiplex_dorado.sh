#!/bin/bash -l
#SBATCH --job-name="rumen_demultiplex_dorado"
#SBATCH --partition=general
#SBATCH -o rumen_demultiplex_dorado.o
#SBATCH -e rumen_demultiplex_dorado.e

#########################################################
module use /sw/auto/rocky8c/epyc3_h100/modules/all/
module load cuda/12.6.0

#########################################################
$dorado demux --output-dir $output_scratch_demultiplex \
    --kit-name SQK-NBD114-96 $output_scratch_bam/$output_bam