het <- read.table(text = sub("#", "", readLines("R_check.het")), header = TRUE)
het[,"HET_RATE"] <- (het[,"OBS_CT"] - het[,"O.HOM."]) / het[,"OBS_CT"]
het_fail <- subset(het, (het[,"HET_RATE"] < mean(het[,"HET_RATE"])-3*sd(het[,"HET_RATE"])) | (het[,"HET_RATE"] > mean(het[,"HET_RATE"])+3*sd(het[,"HET_RATE"])));
het_fail$HET_DST <- (het_fail[,"HET_RATE"]-mean(het[,"HET_RATE"]))/sd(het[,"HET_RATE"]);
write.table(het_fail[,1:2], "fail-het-qc.txt", row.names=FALSE, quote=F)
