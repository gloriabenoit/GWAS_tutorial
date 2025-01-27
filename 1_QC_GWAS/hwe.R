hwe<-read.table(text = sub("#", "", readLines("plink2.hardy")), header = TRUE)
jpeg("histhwe.jpeg", quality=100, height=600, width=600)
hist(hwe[,"P"], main="Histogram HWE", xlab="p-val")
dev.off()

hwe_zoom<-read.table (file="plink2zoomhwe.hardy", col.names=c("CHROM", "ID", "A1", "AX", "HOM_A1_CT", "HET_A1_CT", "TWO_AX_CT", "O(HET_A1)", "E(HET_A1)", "P"))
jpeg("histhwe_below_theshold.jpeg", quality=100, height=600, width=600)
hist(hwe_zoom[,"P"], main="Histogram HWE: strongly deviating SNPs only", xlab="p-val")
dev.off()
