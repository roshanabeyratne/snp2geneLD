#!/lustre/orion/syb111/proj-shared/Personal/abeyratnecr/libraries/andes/anaconda3/envs/ORNL_ENV_2/bin/R
################################################################################
# Estimate the target distance at which LD reaches a given LD value
# Uses the Exponential decay method
# CRA 041122024
################################################################################
rm(list=ls())
args=commandArgs(trailingOnly=T)
snpld_filename<-as.character(args[1])
plot_name=as.character(args[2])

# load tidyverse for binning function
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(pracma))

# reading the pairwise-LD values generated for the focal SNP
# ld<-read.table(snpld_filename,header=T)
ld<-read.table(snpld_filename,header=T)
focal_snp<-unique(ld$SNP_A)
ld$distance<-abs(ld$BP_A-ld$BP_B)

# average pairwise LD for the focal SNP across bins
ld2 <- ld %>% 
    mutate(bin=ntile(distance,n=200)) %>%
    group_by(bin) %>% 
    summarise_at(c("R2","distance"),mean,na.rm=TRUE)
ld2$distance=round(ld2$distance,0)

# using exponential decay to model LD decay and estmate the distance at which LD reches background levels
m<-nls(R2 ~ a * exp(-b * distance) + c,
       data=ld2,
       start = list(a = 0.5, b = 1e-4, c = 0),
       control = nls.control(maxiter = 500))
results.m<-summary(m)

r2_smooth <- predict(m, newdata = list(dist=ld2$distance))
cor_m<-cor.test(ld2$R2,r2_smooth)

# Obtain the point at which background LD is reached
f_prime <- gradient(r2_smooth, ld2$distance)
f_doubleprime <- gradient(f_prime, ld2$distance)
curvature <- abs(f_doubleprime) / (1 + f_prime^2)^(3/2)
mid_idx=which.min(abs(mean(curvature) - curvature))

distance.span=ld2$distance[mid_idx]
expected.ld=r2_smooth[mid_idx]
mod_fit=cor_m$estimate

# hill.weir.eq=(R2~(((10+(rho*distance))/((2+(rho*distance))*(11+(rho*distance))))*(1+(((3+(rho*distance))*(12+(12*(rho*distance))+((rho*distance)**2)))/(n*(2+(rho*distance))*(11+(rho*distance)))))))
# # n=423
# rho.start=1e-7
# m<-nls(formula=hill.weir.eq, data=ld2, start=list(rho=rho.start), control=nls.control(maxiter=200))
# results.m<-summary(m)
# # results.m
# # Assess the nls-fit using pw-LD in bin vs fitted values in model
# cor_m<-cor.test(ld2$R2,predict(m))

# # using estimates of local recombination based on observed LD in the region
# rho.estimate=results.m$parameters[1]
# Distance=seq(from=min(ld2$distance),to=max(ld2$distance),by=1000)
# exp.rsquared=(((10+(rho.estimate*Distance))/((2+(rho.estimate*Distance))*(11+(rho.estimate*Distance))))*(1+(((3+(rho.estimate*Distance))*(12+(12*(rho.estimate*Distance))+((rho.estimate*Distance)**2)))/(n*(2+(rho.estimate*Distance))*(11+(rho.estimate*Distance))))))

# # predict distance based on background LD
# # target_bkg_ld=0.2
# idx1<-which.min(abs(exp.rsquared-target_bkg_ld))
# distance.span=Distance[idx1]
# distance.span=round(distance.span,0)
# expected.ld=exp.rsquared[idx1]
# mod_fit=cor_m$estimate

# Following line when writing to a text file with sequential lines
# cat('focal_snp', ",", 'distance.span', ",", 'expected.ld', ",", 'mod_fit')

# When writing as separate lines for each window
# cat(focal_snp, ",", distance.span, ",", expected.ld, ",", mod_fit)
tmp_mat <- matrix(c(distance.span, expected.ld, mod_fit), nrow=1) %>% as.data.frame()
colnames(tmp_mat) <- c('distance.span', 'expected.ld', 'mod_fit')
table_name <- snpld_filename %>% str_replace("ld$", 'decay')
write.table(tmp_mat, file=table_name, quote=F, row.names=F)

# plot the LD-decay from marker
pdf(plot_name)
plot(R2~ distance, data=ld2, pch=16, cex=1, col=alpha('black',0.9))
lines(ld2$distance, r2_smooth, col="purple", lwd=2)
legend(5000,0.99, c("Means","Expected R2"), lty=1, col="purple")
abline(v=ld2$distance[mid_idx])
dev.off()

# END
################################################################################