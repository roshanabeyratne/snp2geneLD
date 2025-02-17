#!/bin/bash
# title          :pw_LD_and_mrkr_density_in_windows.sh
# description    :Estimates pair-wise LD, marker-density and average pairwise distance,
# between markers for local markers within user defined genomic windows
# author         :CRA
# date           :12022025
# usage          :bash ./pw_LD_and_mrkr_density_in_windows.sh -i <plink_prefx> -w <intvl_list>
# notes          :Requires PLINK and bedtoools
#==============================================================================

# Exit with the first error encountered
set -e

# Initialize variables
plink_prefx_genome=''
intvl_list=''
out_gw_ld=''

# Parsing commandline arguments and inputs
usage() { echo "Usage: $0 -i <plink_prefx> -w <intvl_list> -o <out_gw_ld>" 1>&2; exit 1;}
while getopts ":i:w:o:" opt; do
    case $opt in
        i)  plink_prefx=${OPTARG};;
        w)  intvl_list=${OPTARG};;
        o)  out_gw_ld=${OPTARG};;
        \?) echo "Invalid option: -${OPTARG}";;
        *) usage;;
    esac
done
shift "$((OPTIND-1))"

# Check all inputs provided
if [ -z "${plink_prefx}" ] || [ -z "${intvl_list}" ] || [ -z "${out_gw_ld}" ]; then
    usage
fi

# Check if inputs are valid
mod_bimfile="${plink_prefx}_modified.bim"
if [ ! -f  "${plink_prefx}.bim" ] || [ ! -f "${plink_prefx}.bed" ] || [ ! -f "${plink_prefx}.fam" ]; then
    echo "All required < ${plink_prefx} > PLINK format files do not exist!"
fi

# Convert PLINK .bim with SNP coordinates to <Chr>\t<start>\t<stop>\t<SNP_name> to make it compatible with bedtools
# cat ${plink_prefx}.bim | perl -pe 'while(<>){chomp; @var=split; print "$var[0]\t$var[3]\t$var[3]\t$var[1]\n"}' > ${out_gw_ld}/modified.bim
cat ${plink_prefx}.bim | awk 'BEGIN {OFS="\t"} {print $1, $4, $4+1, $2}' > ${out_gw_ld}/modified.bim

# Specify output file for LD esimates and remove any previous versions
outfile="${out_gw_ld}/ld_in_gw_windows.txt"
if [ -f "${outfile}" ]; then 
    rm "${outfile}"
fi








#  Writing the header of the file
echo -e "Chr\tStart\tStop\tmean_LD\tNum_Markers\tAvg_pw_dist" >> "${outfile}"

# Estimate LD for each sliding window iteratively
num_windows=$(wc -l < ${intvl_list})
if [ $num_windows == 0 ]; then
    # Exit if no window specified
    echo "${intvl_list} has zero lines!"
    exit -1
else
    for i in $(seq 1 $num_windows); do 
        line=$(head -n $i ${intvl_list} | tail -1)
        echo "$line" > ${out_gw_ld}/tmp_window_${i}.bed
        bedtools intersect -a ${out_gw_ld}/modified.bim -b ${out_gw_ld}/tmp_window_${i}.bed -nonamecheck| cut -f 4 > ${out_gw_ld}/tmp_snp_list_${i}.txt
        snp_count=$(wc -l < ${out_gw_ld}/tmp_snp_list.txt)

        if [ $snp_count == 0 ]; then
            mean_LD='NA'
            avg_pw_dist='NA'
        else
            # Estimate pair-wise LD for all SNPs within window using PLINK
            plink --bfile ${plink_prefx}.bim \
            --extract ${out_gw_ld}/tmp_snp_list_${i}.txt \
            --r2 \
            --ld-window 5 \
            --ld-window-r2 0 \
            --allow-extra-chr \
            --chr-set 18 \
            --out ${out_gw_ld}/tmp_mean_${i}

            mean_LD=`tail -n+2 ${out_gw_ld}/tmp_mean_${i}.ld | awk '{ total += $7 } END { print total/NR }'`
            bp_a=`tail -n+2 ${out_gw_ld}/tmp_mean_${i}.ld | awk '{ total += $2 } END { print total/NR }'`
            bp_b=`tail -n+2 ${out_gw_ld}/tmp_mean_${i}.ld | awk '{ total += $5 } END { print total/NR }'`
            A_var=`printf '%.2f' "$bp_a"`
            B_var=`printf '%.2f' "$bp_b"` 
            diff=`echo "$A_var-$B_var"|bc`
            avg_pw_dist=$(echo "$diff" | awk '{print ($1 < 0) ? -$1 : $1}')
            # avg_pw_dist=${diff}

            # Clean-up the temp files created during the process
            rm ${out_gw_ld}/tmp_window_${i}.bed
            rm ${out_gw_ld}/tmp_snp_list_${i}.txt
            rm ${out_gw_ld}/tmp_mean_${i}
        fi
        
        echo -e "$line\t$mean_LD\t$snp_count\t$avg_pw_dist" >> "${outfile}"
    done
fi




#==============================================================================
