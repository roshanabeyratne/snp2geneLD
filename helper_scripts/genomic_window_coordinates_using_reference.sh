#!/bin/bash
# title          :genomic_window_coordinates_using_reference.sh
# description    :Creates user defined genomic-window coordinates for a reference genome in FASTA format
# author         :CRA
# date           :19022024
# usage          :bash ./genomic_window_coordinates_using_reference.sh -i <ref_genome> -w <win_size> -s <step_size> -o <out_put_folder>
# notes          :Requires samtools and bedtools
#==============================================================================
# Exit with the first error encountered
set -e

# Initialize variables
ref_genome=''
win_size=''
step_size=''

# Parsing commandline arguments and inputs
usage() { echo "Usage: $0 -i <ref_genome> -w <win_size> -s <step_size> -o <out_put_folder>" 1>&2; exit 1;}

while getopts ":i:w:s:o:" opt; do
    case $opt in
        i) ref_genome=${OPTARG};;
        w) win_size=${OPTARG};;
        s) step_size=${OPTARG};;
        o) out_put_folder=${OPTARG};;
        \?) echo "Invalid option: -${OPTARG}";;
        *) usage;;
    esac
done

# Check all inputs provided
if [ -z "${ref_genome}" ] || [ -z "${win_size}" ] || [ -z "${step_size}" ] || [ -z "${out_put_folder}" ]; then
    usage
fi

# Check if inputs are valid
if [ ! -f "${ref_genome}" ]; then
    echo "file < ${ref_genome} > does not exist!"
fi

# Create genomic-windows with coordinates
samtools faidx "${ref_genome}" # Outputs the chromosome size in bps

cat "${ref_genome}.fai" | cut -f1,2 > "${out_put_folder}/chrom.lengths.txt" # extract columns <Chr> and <chrom_size>

bedtools makewindows -g "${out_put_folder}/chrom.lengths.txt" -w "${win_size}" -s "${step_size}" > "${out_put_folder}/${win_size}_${step_size}.bed"
#==============================================================================
