maf_freq <- read.table(text = sub("#", "", readLines("MAF_check.afreq")), header = TRUE)
jpeg("MAF_distribution.jpeg", quality=100, height=600, width=600)
hist(maf_freq[,"ALT_FREQS"],main = "MAF distribution", xlab = "MAF")
dev.off()
