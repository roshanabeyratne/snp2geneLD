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
b_value <- 1e-6  # Initial value of b
b_increment <- 10  # Increment step for b
max_attempts <- 5  # Maximum number of attempts
attempt<- 1  # Initialize attempt counter
m <- NULL  # Placeholder for the model

# Loop until the model converges or max_attempts is reached
while (attempt <= max_attempts) {
    message(sprintf("Attempt %d: Trying b = %g", attempt, b_value))
    
    tryCatch({
        # Try fitting the model
        m <- nls(R2 ~ a * exp(-b * distance) + c,
                     data = ld2,
                     start = list(a = 0.5, b = b_value, c = 0),
                     control = nls.control(maxiter = 500))
        
        # If successful, exit the loop
        message("Model successfully fit!")
        break 
    }, error = function(e) {
        
    # If an error occurs, print the error message
    message(sprintf("Error encountered: %s", e$message))
  })

    # Increase b and try again
    b_value <- b_value * b_increment
    attempt <- attempt + 1
}

# Check if the model was successfully fit
if (!is.null(m)) {
    message("Final model fit successfully!")
    
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
    
} else {
  message("Failed to fit model after maximum attempts.")
}

# END
################################################################################