hwe<-read.table(text = sub("#", "", readLines("plink2.hardy")), header = TRUE)
pdf("histhwe.pdf")
hist(hwe[,"P"],main="Histogram HWE")
dev.off()

hwe_zoom<-read.table (file="plink2zoomhwe.hardy", col.names=c("CHROM", "ID", "A1", "AX", "HOM_A1_CT", "HET_A1_CT", "TWO_AX_CT", "O(HET_A1)", "E(HET_A1)", "P"))
pdf("histhwe_below_theshold.pdf")
hist(hwe_zoom[,"P"],main="Histogram HWE: strongly deviating SNPs only")
dev.off()
