#!/lustre/orion/syb111/proj-shared/Personal/abeyratnecr/libraries/andes/anaconda3/envs/ORNL_ENV_2/bin/R
################################################################################
# Filter SNPs that meet a p-value cutoff
# CRA 041122024
################################################################################
rm(list=ls())
library(tidyverse)

args=commandArgs(trailingOnly=T)
in_snpfile<-as.character(args[1])
out_snpfile=as.character(args[2])

p_val_cut=1e-7

tmp_df <- read.csv(file=in_snpfile, header=TRUE)
tmp_df2 <- tmp_df %>% filter(P.value <= p_val_cut)

if (nrow(tmp_df2) == 0) {
    tmp_df3 <- tmp_df %>% filter(row_number()==1)
    tmp_df3[1,] <- NA
    write.csv(tmp_df3, file=out_snpfile, row.names=F, col.names=F, quote=F)
        
} else {
    write.csv(tmp_df2, file=out_snpfile, row.names=F, col.names=F, quote=F)
}
# END
