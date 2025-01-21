het <- read.table(text = sub("#", "", readLines("R_check.het")), header = TRUE)
pdf("heterozygosity.pdf")
het[,"HET_RATE"] <- (het[,"OBS_CT"] - het[,"O.HOM."]) / het[,"OBS_CT"]
hist(het[,"HET_RATE"], xlab="Heterozygosity Rate", ylab="Frequency", main= "Heterozygosity Rate")
dev.off()
