#!/bin/bash

# title          :11_snp2genes_closest_genes.sh
# description    :Creates user defined genomic-window coordinates for a reference genome in FASTA format
# author         :RoshanAbeyratne & HariChhetri
# date           :20022025
# usage          :bash ./11_snp2genes_closest_genes.sh
# notes          :Requires bedtools and a perl helper script to parse SNPs
#==============================================================================

date 

source activate /lustre/orion/syb111/proj-shared/Personal/abeyratnecr/libraries/andes/anaconda3/envs/popgen # environment contains samtools and bedtools
source ./1_set_parameters_and_io_names.sh # This script has all the required input and output variables not specified in this script

# Check all inputs provided
if [ -z "${closest_gene_snp_list}" ] || [ -z "${gff3}" ]
then
	usage
fi

# Check if all inputs exist
if [ ! -f  "${closest_gene_snp_list}" ] || [ ! -f "${gff3}" ]
then
	echo "All required input files do not exist!"
fi

# change the comma separated file into a header removed tab delimited file
tr ',' '\t' < ${closest_gene_snp_list} > ${closest_gene_snp_list%csv}tsv
perl ${wdir}/helper_scripts/parse_snp_ids.pl ${closest_gene_snp_list%csv}tsv > ${s2g}/temp_file.tsv

#  sort the input snpfile for coordinates
bedtools sort -i ${s2g}/temp_file.tsv >  ${s2g}/sorted_temp_file.tsv
bedtools sort -i ${gff3} >  ${gff3%.gff3}_sorted.gff3

bedtools closest -nonamecheck -a ${s2g}/sorted_temp_file.tsv -b ${gff3%.gff3}_sorted.gff3 -k 2 -D ref | perl -lane 'print "$F[0]\t$F[1]\t$F[2]\t$F[3]\t$F[-2]\t$F[-1]"' | perl -ple 's/ID=|Name=//g' | perl -ple 's|\;|\t|g' | perl -ple 's/,/\t/g'| perl -ple 's|\s+|\t|g' >> ${s2g}/testing_the_script.txt
# perl -lane 'print "$F[0]\t$F[1]\t$F[8]\t$F[9]\t$F[12]\t$F[17]\t$F[18]\t$F[20]\t$F[22]\t$F[-1]"' >> ${s2g}/testing_the_script.txt

conda deactivate

date
#==============================================================================