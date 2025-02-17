#!/bin/bash

# title          :1_create_genomic_windows.sh
# description    :Creates user defined genomic-window coordinates for a reference genome in FASTA format
# author         :CRA
# date           :11022025
# usage          :bash ./1_create_genomic_windows.sh
# notes          :Requires samtools and bedtools
#==============================================================================

date 

source activate /lustre/orion/syb111/proj-shared/Personal/abeyratnecr/libraries/andes/anaconda3/envs/popgen # environment with bedtools, samtools and MPI
source ./0_set_parameters_and_io_names.sh # This script has all the required input and output variables not specified in this script

if [ ! -d "${out_gw_ld}" ]; then
    echo "Directory < ${out_gw_ld} > does not exist! Creating it now..."
    mkdir -p "${out_gw_ld}"  # -p ensures no error if parent directories are missing
    echo "Directory < ${out_gw_ld} > created."
else
    echo "Directory < ${out_gw_ld} > already exists."
fi

# set input variables
intvl_list="${out_pw_ld}/${win_size}_${step_size}.bed"

bash ${wdir}/helper_scripts/pw_LD_and_mrkr_density_in_windows.sh -i ${plink_prefx} -w ${intvl_list} -o ${out_gw_ld}

conda deactivate

date

#==============================================================================