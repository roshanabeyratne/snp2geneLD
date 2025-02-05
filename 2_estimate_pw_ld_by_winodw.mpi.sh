#!/bin/bash
#SBATCH -A SYB111
#SBATCH -J pw_ld
#SBATCH -N 1
#SBATCH -t 12:00:00 
#SBATCH -o ./%x-%j-%a.o
#SBATCH -e ./%x-%j-%a.e

#==============================================================================
# title          :estimate_pw_ld_by_window_mpi.sh
# description    :Estimates pairwise LD (r2) for SNPs within a genomic window
# author         :CRA
# date           :19022024
# usage          :Submit this MPI script 
# notes          :Requires an environment with samtools, bedtools and MPI implementation. Set input variables <wdir>, <plink_prefx>, <intvl_list>, <tmp_command_list>, <out_dir>
#==============================================================================

date 

# activate the conda env with bedtools and plink
module load python
source activate /lustre/orion/syb111/proj-shared/Personal/abeyratnecr/libraries/andes/anaconda3/envs/popgen

# set input variables
wdir="/lustre/orion/syb111/proj-shared/Personal/abeyratnecr/pennycress/sub_proj/snp2genes_growout1/github_sync"
plink_prefx="/lustre/orion/syb111/proj-shared/Data/pennycress/genomic_data/snps2/pennycress_423_hwe1e150_mind01_maf02" # <full-path to the PLINK files>
intvl_list="${wdir}/results/5000000_2500000.bed" # <bed file with genomic window intervals>
tmp_command_list="${wdir}/results/command_list_estimate_pw_ld.txt" # <full-path for the output mpi-command-list>
out_dir="${wdir}/results/" # <out dir full-path for pairwise ld estimates within windows>

# create mpi-command-list
for i in $(seq 1 $(wc -l < ${intvl_list}))
# $(wc -l < ${intvl_list})
do 
    line="$(sed -n ${i}p ${intvl_list})"
    chr="$(echo ${line} | awk '{print $1}')"
    start="$(echo ${line} |awk '{print $2}')"
    end="$(echo ${line} |awk '{print $3}')"
    out="${out_dir}/${chr}_${start}_${end}"
    echo "plink --bfile ${plink_prefx} --allow-extra-chr --chr ${chr} --r2 --from-bp ${start} --to-bp ${end} --ld-window 99999 --ld-window-r2 0 --out ${out}"
done > ${tmp_command_list}
srun -n4 -N1 python ${wdir}/helper_scripts/pyscript.py -c ${tmp_command_list}

conda deactivate
rm ${tmp_command_list}

date 
#==============================================================================