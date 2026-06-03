#!/bin/bash -l
#SBATCH --job-name="rumen_basecalling_dorado"
#SBATCH --partition=gpu_cuda
#SBATCH --gres=gpu:h100:1
#SBATCH -o rumen_basecalling_dorado.o
#SBATCH -e rumen_basecalling_dorado.e

#########################################################
module use /sw/auto/rocky8c/epyc3_h100/modules/all/
module load cuda/12.6.0

#########################################################
$dorado basecaller --no-trim --recursive $model $input_scratch_pod5 \
    --modified-bases 6mA 4mC_5mC \
    --kit-name SQK-NBD114-96 > $output_scratch_bam/$output_bam