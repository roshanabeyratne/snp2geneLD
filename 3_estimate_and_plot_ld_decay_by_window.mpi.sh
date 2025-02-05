#!/bin/bash
#SBATCH -A SYB111
#SBATCH -J LD_decay
#SBATCH -N 1
#SBATCH -t 12:00:00 
#SBATCH -o ./%x-%j-%a.o
#SBATCH -e ./%x-%j-%a.e

#==============================================================================
# title          :estimate_and_plot_ld_decay_by_window_mpi.sh
# description    :Estimate the target distance at which LD reaches a given LD value. Uses the Hill & Weir, 1988 equation to model LD
# author         :CRA
# date           :19022024
# usage          :Submit this MPI script 
# notes          :Requires an R-environment with tidyverse and NLS. Set input variables <wdir>, <intvl_list>, <n>, <target_bkg_ld>, <tmp_command_list>
#==============================================================================

date 

# activate the conda env with bedtools and plink
module load python
source /ccs/home/abeyratnecr/loadmyconda.sh
source activate /lustre/orion/syb111/proj-shared/Personal/abeyratnecr/libraries/andes/anaconda3/envs/ORNL_ENV_2

# set input variables
wdir="/lustre/orion/syb111/proj-shared/Personal/abeyratnecr/pennycress/sub_proj/snp2genes_growout1/github_sync"
intvl_list="${wdir}/results/5000000_2500000.bed" # <bed file with genomic window intervals>
n=423 # Number of samples used in GWAS/ individuals with genotype data used for LD estimation
target_bkg_ld=0.1 # target background LD for the SNP
tmp_command_list="${wdir}/results/command_list_ld_decay.txt" # <full-path for the output mpi-command-list>

# create mpi-command-list
missing_runs=( 52 53 54 55 105 106 125 126 127 )
for i in "${missing_runs[@]}"
# for i in $(seq 1 $(wc -l < ${intvl_list}))
# $(wc -l < ${intvl_list})
do 
    line="$(sed -n ${i}p ${intvl_list})"
    chr="$(echo ${line} | awk '{print $1}')"
    start="$(echo ${line} |awk '{print $2}')"
    end="$(echo ${line} |awk '{print $3}')"
    snpld_filename="${wdir}/results/${chr}_${start}_${end}.ld"
    plot_out="${wdir}/plots/${chr}_${start}_${end}.pdf"
    echo "Rscript ${wdir}/helper_scripts/estimate_and_plot_LD_decay.R ${snpld_filename} ${n} ${target_bkg_ld} ${plot_out}"
done > ${tmp_command_list}

srun -n4 -N1 python ${wdir}/helper_scripts/pyscript.py -c ${tmp_command_list}

conda deactivate
rm ${tmp_command_list}

date 
#==============================================================================