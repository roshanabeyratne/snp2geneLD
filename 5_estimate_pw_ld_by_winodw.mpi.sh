#!/bin/bash
#SBATCH -A SYB111
#SBATCH -J pw_ld
#SBATCH -N 1
#SBATCH --mem=0
#SBATCH -t 8:00:00 
#SBATCH -o ./%x-%j-%a.o
#SBATCH -e ./%x-%j-%a.e

#==============================================================================
# title          :5_estimate_pw_ld_by_window_mpi.sh
# description    :Estimates pairwise LD (r2) for SNPs within a genomic window
# author         :RoshanAbeyratne & HariChhetri
# date           :20022025
# usage          :sbatch 5_estimate_pw_ld_by_window.mpi.sh
# notes          :Requires an environment with samtools, bedtools and MPI implementation.
#==============================================================================

date 

# activate the conda env with bedtools and plink
module load python
source activate /lustre/orion/syb111/proj-shared/Personal/abeyratnecr/libraries/andes/anaconda3/envs/popgen # environment with bedtools, samtools and MPI
source ./0_set_parameters_and_io_names.sh # This script has all the required input and output variables not specified in this script

# Check if all PLINK inputs exist
if [ ! -f  "${plink_prefx}.bim" ] || [ ! -f "${plink_prefx}.bed" ] || [ ! -f "${plink_prefx}.fam" ]; then
    echo "All required < ${plink_prefx} > PLINK format files do not exist!"
fi

# set input variables
intvl_list="${out_pw_ld}/${win_size}_${step_size}.bed" # <bed file with genomic window intervals>
cat ${intvl_list}| grep -v 'scaffold' > ${intvl_list} # Comment this section out when estimating for scaffolds
tmp_command_list="${wdir}/command_list_estimate_pw_ld.txt" # <full-path for the output mpi-command-list>

# Handling the case when chromosome IDs are mentioned as numbers in the first column of the PLINK.bim file
foo=$(cat ${plink_prefx}.bim| grep -v 'scaffold' |awk '{print $1}' | uniq) # check .bim file contig names
bar=($foo)
fooz=$(cat ${intvl_list}| grep -v 'scaffold'| awk '{print $1}' | uniq) # check intvl_list contig names
barz=($fooz)

if [[ ${bar[0]} =~ ^[0-9]+$ ]] || [[ ${barz[0]} =~ ^[0-9]+$ ]]; then
    for ((i=0;i<${#barz[@]};i++))
        do 
            # j=$(echo $i+1| bc) # This does not work when when the sequence goes like [ Chr01K, Chr02k, ... Chr01N, Chr02N ]
            printf "%s\t%s\n" "${bar[$i]}" "${barz[$i]}"
        done > ${out_pw_ld}/tmp_bim.txt
fi

if [[ ${bar[0]} =~ ^[0-9]+$ ]]; then
    # create mpi-command-list
    for i in $(seq 1 $(wc -l < ${intvl_list}))
    # $(wc -l < ${intvl_list})
    do 
        line="$(sed -n ${i}p ${intvl_list})"
        chr="$(echo ${line} | awk '{print $1}')"
        start="$(echo ${line} |awk '{print $2}')"
        end="$(echo ${line} |awk '{print $3}')"
        chr_num=$(awk -v key="$chr" '$2 == key {print $1}' "${out_pw_ld}/tmp_bim.txt")
        # echo "${chr} ${start} ${end} ${chr_num}"
        out="${out_pw_ld}/${chr}_${start}_${end}"
        echo "plink --bfile ${plink_prefx} \
        --allow-extra-chr \
        --chr-set ${#bar[@]} \
        --chr ${chr_num} \
        --r2 \
        --from-bp ${start} \
        --to-bp ${end} \
        --ld-window ${max_adj_mrkrs} \
        --ld-window-r2 0 \
        --freq \
        --hardy \
        --out ${out}"
    done > ${tmp_command_list}

else
    # create mpi-command-list
    for i in $(seq 1 $(wc -l < ${intvl_list}))
    # $(wc -l < ${intvl_list})
    do 
        line="$(sed -n ${i}p ${intvl_list})"
        chr="$(echo ${line} | awk '{print $1}')"
        start="$(echo ${line} |awk '{print $2}')"
        end="$(echo ${line} |awk '{print $3}')"
        out="${out_pw_ld}/${chr}_${start}_${end}"
        echo "plink --bfile ${plink_prefx} \
        --allow-extra-chr \
        --chr ${chr} \
        --r2 \
        --from-bp ${start} \
        --to-bp ${end} \
        --ld-window ${max_adj_mrkrs} \
        --ld-window-r2 0 \
        --freq \
        --hardy \
        --out ${out}"
    done > ${tmp_command_list}
fi

srun -n4 -N1 python ${wdir}/helper_scripts/pyscript.py -c ${tmp_command_list}

conda deactivate
# rm ${tmp_command_list}

date 
#==============================================================================