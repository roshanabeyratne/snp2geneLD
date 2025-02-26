#!/bin/bash
# title          :snp2genes.sh
# description    :obtain the closest neighboring genes for a given list of SNP
# author         :CRA
# date           :03192024
# usage          :bash ./snp2genes.sh -i <snp_list> -g <GFF gene annotations>
# notes          :Requires PLINK and bedtoools
#==============================================================================
# Exit with the first error encountered
set -e

# Initialize variables
snp_list=''
gff=''


# Parsing commandline arguments and inputs
usage() { echo "Usage: $0 -i <snp_list> -g <GFF gene annotations>" 1>&2; exit 1;}
while getopts ":i:g:" opt
do
	case $opt in
		i)  snp_list=${OPTARG};;
        g)  gff=${OPTARG};;
        \?) echo "Invalid option: -${OPTARG}";;
        *) usage;;
    esac
done

shift "$((OPTIND-1))"


# Check all inputs provided
if [ -z "${snp_list}" ] || [ -z "${gff}" ]
then
	usage
fi


# Check if all inputs exist
if [ ! -f  "${snp_list}" ] || [ ! -f "${gff}" ]
then
	echo "All required input files do not exist!"
fi


# print the header line
echo -e "chr\tsnp_pos\tbeta\tbeta_SE\tp_wald\tgene_start\tgene_end\tstrand\tgene_name\tdistance"


#  sort the input snpfile for coordinates
bedtools sort -i ${snp_list} \
| bedtools closest -nonamecheck -a - -b ${gff} -k 2 -D ref \
| perl -lane 'print "$F[0]\t$F[1]\t$F[8]\t$F[9]\t$F[12]\t$F[17]\t$F[18]\t$F[20]\t$F[22]\t$F[-1]"'
#==============================================================================
