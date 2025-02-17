#!/bin/bash

# title          :0_set_parameters_and_io_names.sh
# description    :Define variables and set parmeters for the pipeline
# author         :CRA
# date           :12022025
# usage          :This script will be sourced by the subsequent scripts
# notes          :Define the variabels below based on inputs and the analysis
#==============================================================================

# set input variables and folders
wdir="/lustre/orion/syb111/proj-shared/Personal/abeyratnecr/switchgrass/sub_proj/snp2geneLD"

# genotype data
ref_genome="/lustre/orion/syb111/proj-shared/Personal/abeyratnecr/switchgrass/data/Pvirgatum_516_v5.0.hardmasked.fa" # <full-path to refrence genome>
plink_prefx="/lustre/orion/syb111/proj-shared/Data/switchgrass/Variants/verified_geno/Pvirg_285g.AllChr.geno01.mind02.hwe1e50.maf01" # <full-path to the PLINK files>

# GWAS data
gwas_loc="/lustre/orion/syb111/proj-shared/Personal/hchhetri/projects/pennycress/set423/gapit_runs/variety_notas_CV" # <location of the GWAS out from GAPIT>
trait_list="${wdir}/results/gwas_trait_list.txt" # gwas_trait_list.txt is a one column list with traits separated by "\n" 
models=("BLINK" "FarmCPU" "MLMM" "MLM") # These are the GAPIT models. Change the list as needed based on what models used

# set parameters
win_size=1000000 # <win_size>
step_size=$((${win_size}/2)) # <step_size>
max_adj_mrkrs=1000 # set this to 99999 for all pair-wise LD estimates (But 1000 is reasonable). for LD decay and low number such as 5-10 for genomewide LD analysis

# set output folders and filenames
out_pw_ld="${wdir}/pw_ld" # <out_put_folder for pairwise LD estimation full-path>
s2g="${wdir}/s2g" # <out_put_folder for snp-to-gene assignments full-path>
#==============================================================================