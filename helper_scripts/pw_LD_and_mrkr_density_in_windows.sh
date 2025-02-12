#!/bin/bash
# title          :average_pw_LD_in_windows.sh
# description    :Estimates pair-wise LD, marker-density and average pairwise distance,
# between markers for local markers within user defined genomic windows
# author         :CRA
# date           :19022024
# usage          :bash ./average_pw_LD_in_windows.sh -i <PLINK_prefix> -w <win_coords>
# notes          :Requires PLINK and bedtoools
#==============================================================================
# Exit with the first error encountered
set -e

# Initialize variables
PLINK_prefix_genome=''
win_coords=''


# Parsing commandline arguments and inputs
usage() { echo "Usage: $0 -i <PLINK_prefix> -w <win_coords>" 1>&2; exit 1;}
while getopts ":i:w:" opt; do
    case $opt in
        i)  PLINK_prefix=${OPTARG};;
        w)  win_coords=${OPTARG};;
        \?) echo "Invalid option: -${OPTARG}";;
        *) usage;;
    esac
done
shift "$((OPTIND-1))"


# Check all inputs provided
if [ -z "${PLINK_prefix}" ] || [ -z "${win_coords}" ]; then
    usage
fi


# Check if inputs are valid
bimfile="${PLINK_prefix}.bim"
bedfile="${PLINK_prefix}.bed"
famfile="${PLINK_prefix}.fam"
mod_bimfile="${PLINK_prefix}_modified.bim"
if [ ! -f  "${bimfile}" ] || [ ! -f "${bedfile}" ] || [ ! -f "${famfile}" ]; then
    echo "All required < ${PLINK_prefix} > PLINK format files do not exist!"
fi


# Convert PLINK .bim with SNP coordinates to <Chr>\t<start>\t<stop>\t<SNP_name> to make it compatible with bedtools
cat $bimfile| perl -pe 'while(<>){chomp; @var=split; print "$var[0]\t$var[3]\t$var[3]\t$var[1]\n"}' > ${mod_bimfile}

# Specify output file for LD estiamtes and remove any previous versions
outfile="${bedfile%.bed}.ld"
if [ -f "${outfile}" ]; then 
    rm "${outfile}"
fi


#  Writing the header of the file
echo -e "Chr\tStart\tStop\tmean_LD\tNum_Markers\tAvg_pw_dist" >> "${outfile}"

# Estimate LD for each sliding window iteratively
num_windows=`wc -l < ${win_coords}`
if [ $num_windows == 0 ]; then
    # Exit if no window specified
    echo "${win_coords} has zero lines!"
    exit -1
else
    for i in $(seq 1 $num_windows); do 
        line=`head -n $i ${win_coords} | tail -1`
        echo "$line" > tmp_window.bed
        bedtools intersect -a ${mod_bimfile} -b tmp_window.bed| cut -f 4 > tmp_snp_list.txt
        snp_count=`wc -l < tmp_snp_list.txt`

        if [ $snp_count == 0 ]; then
            mean_LD='NA'
            avg_pw_dist='NA'
        else
            # Estimate pair-wise LD for all SNPs within window using PLINK
            plink --bfile ${bimfile%.bim} \
            --extract tmp_snp_list.txt \
            --r2 \
            --ld-window 10 \
            --ld-window-r2 0 \
            --out tmp_mean

            mean_LD=`tail -n+2 tmp_mean.ld | awk '{ total += $7 } END { print total/NR }'`
            bp_a=`tail -n+2 tmp_mean.ld | awk '{ total += $2 } END { print total/NR }'`
            bp_b=`tail -n+2 tmp_mean.ld | awk '{ total += $5 } END { print total/NR }'`
            A_var=`printf '%.2f' "$bp_a"`
            B_var=`printf '%.2f' "$bp_b"` 
            diff=`echo "$A_var-$B_var"|bc`
            avg_pw_dist=$(echo "$diff" | awk '{print ($1 < 0) ? -$1 : $1}')
            # avg_pw_dist=${diff}
        fi
        
        echo -e "$line\t$mean_LD\t$snp_count\t$avg_pw_dist" >> "${outfile}"
    done
fi


# Clean-up the temp files created during the process
rm tmp_window.bed
rm tmp_snp_list.txt
rm tmp_mean*
rm "${mod_bimfile}"

# End
date
#==============================================================================
