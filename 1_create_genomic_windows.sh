#!/bin/bash

# title          :genomic_window_coordinates_using_reference.sh
# description    :Creates user defined genomic-window coordinates for a reference genome in FASTA format
# author         :CRA
# date           :19022024
# usage          :bash ./genomic_window_coordinates_using_reference.sh -i <ref_genome> -w <win_size> -s <step_size> -o <out_put_folder>
# notes          :Requires samtools and bedtools
#==============================================================================

date 

source activate /lustre/orion/syb111/proj-shared/Personal/abeyratnecr/libraries/andes/anaconda3/envs/popgen # contains samtools and bedtools

ref_genome="/lustre/orion/syb111/proj-shared/Personal/abeyratnecr/pennycress/data/reference.fasta" # <ref_genome with full-path>
win_size=5000000 # <win_size>
step_size=$((${win_size}/2))
out_put_folder="/lustre/orion/syb111/proj-shared/Personal/abeyratnecr/pennycress/sub_proj/snp2genes_growout1/github_sync/results/" # <out_put_folder full-path>

bash ./helper_scripts/genomic_window_coordinates_using_reference.sh -i ${ref_genome} -w ${win_size} -s ${step_size} -o ${out_put_folder}

conda deactivate

date

# NOTE:
# The output file name will be formatted as ${out_put_folder}/${win_size}_${step_size}.bed
#==============================================================================