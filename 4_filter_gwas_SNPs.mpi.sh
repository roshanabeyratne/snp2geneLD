#!/bin/bash
#SBATCH -A SYB111
#SBATCH -J filter_gwas_SNPs
#SBATCH -N 1
#SBATCH -t 48:00:00 
#SBATCH -o ./%x-%j-%a.o
#SBATCH -e ./%x-%j-%a.e

#==============================================================================
# title          :filter_gwas_SNPs.mpi.sh
# description    :Obtain a filtered list of GWAS SNPs for all GAPIT models based on a threshold.
# author         :CRA
# date           :19022024
# usage          :Submit this MPI script 
# notes          :Specify following input variables in the following script. <trait_list>, <gwas_loc>, <models>, <out_dir>
#==============================================================================

date 

# activate the conda env with bedtools and plink
module load python
source /ccs/home/abeyratnecr/loadmyconda.sh
source activate /lustre/orion/syb111/proj-shared/Personal/abeyratnecr/libraries/andes/anaconda3/envs/ORNL_ENV_2

# set input variables
wdir="/lustre/orion/syb111/proj-shared/Personal/abeyratnecr/pennycress/sub_proj/snp2genes_growout1/github_sync"
trait_list="${wdir}/results/gwas_trait_list.txt" # gwas_trait_list.txt is a one column list with traits separated by "\n" 
gwas_loc="/lustre/orion/syb111/proj-shared/Personal/hchhetri/projects/pennycress/set423/gapit_runs/variety_notas_CV" # <location of the GWAS out from GAPIT>
models=("BLINK" "FarmCPU" "MLMM" "MLM") # These are the GAPIT models. Change the list as needed based on what models used
out_dir="${wdir}/results/filtered_snps" # <proposed location for filtered SNPs>

# derived variables
ntraits=$(wc -l < ${trait_list}) 
tmp_command_list="${out_dir}/filter_snps_command_list.txt"

for model in ${models[@]}
do
    for t in $(seq 1 ${ntraits})
    do
        trait=$(sed -n "${t}p" ${trait_list})
        snpfile="GAPIT.Association.GWAS_Results.${model}.${trait}.csv"
    	filt_snpfile="${snpfile%.csv}_filtered.csv"
    	echo "Rscript ${wdir}/helper_scripts/filter_snps_by_pval_cutoff.r ${gwas_loc}/${snpfile} ${out_dir}/${filt_snpfile}"
    done
done > ${tmp_command_list}
srun -n16 -N1 python ${wdir}/helper_scripts/pyscript.py -c ${tmp_command_list}

conda deactivate
rm ${tmp_command_list}

date
#==============================================================================