#!/bin/bash

# title          :2_create_genomic_windows.sh
# description    :Creates user defined genomic-window coordinates for a reference genome in FASTA format
# author         :RoshanAbeyratne & HariChhetri
# date           :20022025
# usage          :bash ./2_create_genomic_windows.sh
# notes          :Requires samtools and bedtools
#==============================================================================

date 

source activate /lustre/orion/syb111/proj-shared/Personal/abeyratnecr/libraries/andes/anaconda3/envs/popgen # environment contains samtools and bedtools
source ./0_set_parameters_and_io_names.sh # This script has all the required input and output variables not specified in this script

if [ ! -d "${out_pw_ld}" ]; then
    echo "Directory < ${out_pw_ld} > does not exist! Creating it now..."
    mkdir -p "${out_pw_ld}"  # -p ensures no error if parent directories are missing
    echo "Directory < ${out_pw_ld} > created."
else
    echo "Directory < ${out_pw_ld} > already exists."
fi

bash ${wdir}/helper_scripts/genomic_window_coordinates_using_reference.sh -i ${ref_genome} -w ${win_size} -s ${step_size} -o ${out_pw_ld}

conda deactivate

date

# NOTE:
# The output file name will be formatted as ${out_pw_ld}/${win_size}_${step_size}.bed
#==============================================================================