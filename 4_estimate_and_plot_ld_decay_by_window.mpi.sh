#!/bin/bash
#SBATCH -A SYB111
#SBATCH -J LD_decay
#SBATCH -N 1
#SBATCH --mem=0
#SBATCH -t 12:00:00 
#SBATCH -o ./%x-%j-%a.o
#SBATCH -e ./%x-%j-%a.e

#==============================================================================
# title          :4_estimate_and_plot_ld_decay_by_window_mpi.sh
# description    :Estimate the target distance at which LD reaches a given LD value. Uses the Hill & Weir, 1988 equation to model LD
# author         :RoshanAbeyratne & HariChhetri
# date           :20022025
# usage          :sbatch 4_estimate_and_plot_ld_decay_by_window_mpi.sh
# notes          :Requires an R-environment with tidyverse and NLS.
#==============================================================================

date 

# activate the conda env with bedtools and plink
module load python
source /ccs/home/abeyratnecr/loadmyconda.sh
source activate /lustre/orion/syb111/proj-shared/Personal/abeyratnecr/libraries/andes/anaconda3/envs/ORNL_ENV_2
source ./0_set_parameters_and_io_names.sh # This script has all the required input and output variables not specified in this script

# set input variables
intvl_list="${out_pw_ld}/${win_size}_${step_size}.bed" # <bed file with genomic window intervals>
# n=$(wc -l < ${plink_prefx}.fam) # Number of samples with genotype data used for LD estimation
tmp_command_list="${wdir}/command_list_estimate_ld_decay.txt" # <full-path for the output mpi-command-list>

if [ ! -d "${out_pw_ld}/plots" ]; then
    echo "Directory < ${out_pw_ld}/plots > does not exist! Creating it now..."
    mkdir -p "${out_pw_ld}/plots"  # -p ensures no error if parent directories are missing
    echo "Directory < ${out_pw_ld}/plots > created."
else
    echo "Directory < ${out_pw_ld}/plots > already exists."
fi

# create mpi-command-list
# missing_runs=( 2087 2088 ) # Use this and the following lines in order to rerun missing runs
# for i in "${missing_runs[@]}"
for i in $(seq 1 $(wc -l < ${intvl_list}))
do 
    line="$(sed -n ${i}p ${intvl_list})"
    chr="$(echo ${line} | awk '{print $1}')"
    start="$(echo ${line} |awk '{print $2}')"
    end="$(echo ${line} |awk '{print $3}')"
    snpld_filename="${out_pw_ld}/${chr}_${start}_${end}.ld"
    plot_out="${out_pw_ld}/plots/${chr}_${start}_${end}.pdf"
    echo "Rscript ${wdir}/helper_scripts/exponential_decay_estimate_and_plot_LD_decay.r ${snpld_filename} ${plot_out}"
done > ${tmp_command_list}

srun -n4 -N1 python ${wdir}/helper_scripts/pyscript.py -c ${tmp_command_list}

conda deactivate
# rm ${tmp_command_list}

date
#==============================================================================
