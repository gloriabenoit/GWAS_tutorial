het <- read.table(text = sub("#", "", readLines("R_check.het")), header = TRUE)
jpeg("heterozygosity.jpeg", quality=100, height=600, width=600)
het[,"HET_RATE"] <- (het[,"OBS_CT"] - het[,"O.HOM."]) / het[,"OBS_CT"]
hist(het[,"HET_RATE"], xlab="Heterozygosity", ylab="Frequency", main= "Heterozygosity Rate")
dev.off()
