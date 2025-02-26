#!/bin/bash

#==============================================================================
# title          :9_coordinates_to_gene_assignment.sh
# description    :Creates user defined genomic-window coordinates for a reference genome in FASTA format
# author         :RoshanAbeyratne & HariChhetri
# date           :19022024
# usage          :bash 9_coordinates_to_gene_assignment.sh
# notes          :Requires an environment with bedtools & set input variable <wdir>, <query_intvls>, <gff_fn>
#==============================================================================

date

source /ccs/home/abeyratnecr/loadmyconda.sh
source activate /lustre/orion/syb111/proj-shared/Personal/abeyratnecr/libraries/andes/anaconda3/envs/popgen
source ./0_set_parameters_and_io_names.sh # This script has all the required input and output variables not specified in this script

# make snptogene output folder if it does not exist
if [ ! -d "${s2g}" ]; then
    echo "Directory < ${s2g} > does not exist! Creating it now..."
    mkdir -p "${s2g}"  # -p ensures no error if parent directories are missing
    echo "Directory < ${s2g} > created."
else
    echo "Directory < ${s2g} > already exists."
fi

# set input variables
query_invls="${fsnps}/query_intervals.bed"

bedtools intersect \
-a ${query_invls} \
-b ${gff3} \
-wa \
-wb \
> ${s2g}/coordinate_to_gene_assignments.txt

date
#==============================================================================