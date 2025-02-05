#!/bin/bash

#==============================================================================
# title          :genomic_window_coordinates_using_reference.sh
# description    :Creates user defined genomic-window coordinates for a reference genome in FASTA format
# author         :CRA
# date           :19022024
# usage          :bash ./genomic_window_coordinates_using_reference.sh -i <ref_genome> -w <win_size> -s <step_size> -o <out_put_folder>
# notes          :Requires bedtools & set input variable <wdir>, <query_intvls>, <gff_fn>
#==============================================================================

date

source /ccs/home/abeyratnecr/loadmyconda.sh
source activate /lustre/orion/syb111/proj-shared/Personal/abeyratnecr/libraries/andes/anaconda3/envs/popgen

# set input variables
wdir="/lustre/orion/syb111/proj-shared/Personal/abeyratnecr/pennycress/sub_proj/snp2genes_growout1/github_sync"
query_invls="${wdir}/results/query_intervals.bed"
gff_fn="/lustre/orion/syb111/proj-shared/Personal/abeyratnecr/pennycress/data/thlaspi_arvense_v2.GENES_ONLY_23900_genes_chr_changed.gff3"

bedtools intersect \
-a ${query_invls} \
-b ${gff_fn} \
-wa \
-wb \
> ${wdir}/results/coordinate_to_gene_assignments.txt

date
#==============================================================================