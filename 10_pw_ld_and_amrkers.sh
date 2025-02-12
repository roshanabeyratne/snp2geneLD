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


intvl_list="${out_pw_ld}/${win_size}_${step_size}.bed"

bash ${wdir}/helper_scripts/pw_LD_and_mrkr_density_in_windows.sh -i ${plink_prefx} -w ${intvl_list}

date
