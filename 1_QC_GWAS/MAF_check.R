maf_freq <- read.table(text = sub("#", "", readLines("MAF_check.afreq")), header = TRUE)
pdf("MAF_distribution.pdf")
hist(maf_freq[,"ALT_FREQS"],main = "MAF distribution", xlab = "MAF")
dev.off()
