#!/bin/bash

# title          :1_set_parameters_and_io_names.sh
# description    :Define variables and set parmeters for the pipeline
# author         :RoshanAbeyratne & HariChhetri
# date           :20022025
# usage          :This script will be sourced by the subsequent scripts
# notes          :Define the variabels below based on inputs and the analysis
#==============================================================================

# set working directory
wdir="/lustre/orion/syb111/proj-shared/Personal/abeyratnecr/switchgrass/sub_proj/snp2geneLD"

# set genotype data file names
ref_genome="/lustre/orion/syb111/proj-shared/Personal/abeyratnecr/switchgrass/data/Pvirgatum_516_v5.0.hardmasked.fa" # <full-path to refrence genome>
plink_prefx="/lustre/orion/syb111/proj-shared/Data/switchgrass/Variants/verified_geno/Pvirg_285g.AllChr.geno01.mind02.hwe1e50.maf01" # <full-path to the PLINK genotype files>

# set GWAS input data file names
gwas_loc="/lustre/orion/syb111/proj-shared/Personal/hchhetri/projects/pennycress/set423/gapit_runs/variety_notas_CV" # <location of the GWAS out from GAPIT> only support GAPIT output at the moment
trait_list="${wdir}/results/gwas_trait_list.txt" # gwas_trait_list.txt is a one column list with traits separated by "\n" 
models=("BLINK" "FarmCPU" "MLMM" "MLM") # These are the GAPIT models. Change the list as needed based on what models used

# set gene-annotation file
gff3="/lustre/orion/syb111/proj-shared/Personal/abeyratnecr/switchgrass/data/Pvirgatum_516_v5.1.gene.gff3" # <general feature format for genes in the genome> 

# set parameters
win_size=1000000 # <win_size>
step_size=$((${win_size}/2)) # <step_size>
max_adj_mrkrs=1000 # set this to 99999 for all pair-wise LD estimates (But 1000 is reasonable). for LD decay and low number such as 5-10 for genomewide LD analysis

# output folder names [DO NOT CHANGE these variable names as they are called within R-scripts]
out_pw_ld="${wdir}/pw_ld" # <out_put_folder for pairwise LD estimation full-path>
out_gw_ld="${wdir}/gw_ld" # <out_put_folder for pairwise LD estimation full-path> with low number of adjacent markers to estimate LD trends genomewide
fsnps="${wdir}/fsnps" # <filtered GWAS SNPs based on a threshold that was provided>
s2g="${wdir}/s2g" # <out_put_folder for snp-to-gene assignments full-path>
#==============================================================================