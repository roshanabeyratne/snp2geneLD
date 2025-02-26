#!/bin/bash
#SBATCH -A SYB111
#SBATCH -J filter_gwas_SNPs
#SBATCH -N 1
#SBATCH -t 6:00:00 
#SBATCH -o ./%x-%j-%a.o
#SBATCH -e ./%x-%j-%a.e

#==============================================================================
# title          :7_filter_gwas_SNPs.mpi.sh
# description    :Obtain a filtered list of GWAS SNPs for all GAPIT models based on a threshold.
# author         :RoshanAbeyratne & HariChhetri
# date           :21022025
# usage          :sbatch  7_filter_gwas_SNPs.mpi.sh
# notes          :Requires env with MPI
#==============================================================================

date 

# activate the conda env with bedtools and plink
module load python
source /ccs/home/abeyratnecr/loadmyconda.sh
source activate /lustre/orion/syb111/proj-shared/Personal/abeyratnecr/libraries/andes/anaconda3/envs/ORNL_ENV_2
source ./1_set_parameters_and_io_names.sh # This script has all the required input and output variables not specified in this script

# set input variables
wdir="/lustre/orion/syb111/proj-shared/Personal/abeyratnecr/pennycress/sub_proj/snp2genes_growout1/github_sync"

if [ ! -d "${fsnps}" ]; then
    echo "Directory < ${fsnps} > does not exist! Creating it now..."
    mkdir -p "${fsnps}"  # -p ensures no error if parent directories are missing
    echo "Directory < ${fsnps} > created."
else
    echo "Directory < ${fsnps} > already exists."
fi

# derived variables
ntraits=$(wc -l < ${trait_list}) 
tmp_command_list="${wdir}/filter_snps_command_list.txt"

for model in ${models[@]}
do
    for t in $(seq 1 ${ntraits})
    do
        trait=$(sed -n "${t}p" ${trait_list})
        snpfile="GAPIT.Association.GWAS_Results.${model}.${trait}.csv"
    	filt_snpfile="${snpfile%.csv}_filtered.csv"
    	echo "Rscript ${wdir}/helper_scripts/filter_snps_by_pval_cutoff.r ${gwas_loc}/${snpfile} ${fsnps}/${filt_snpfile}"
    done
done > ${tmp_command_list}
srun -n16 -N1 python ${wdir}/helper_scripts/pyscript.py -c ${tmp_command_list}

conda deactivate
# rm ${tmp_command_list}

date
#==============================================================================