install.packages("qqman",repos="https://mirror.ibcp.fr/pub/CRAN/",lib="~") # location of installation can be changed but has to correspond with the library location 
library("qqman",lib="~") 
results_log <- read.table(text = sub("#", "", readLines("logistic_results_2.PHENO1.glm.logistic.hybrid")), header = TRUE)
jpeg("Logistic_manhattan.jpeg")
# manhattan(results_log,chr="CHR",bp="BP",p="P",snp="SNP", main = "Manhattan plot: logistic")
manhattan(results_log,chr="CHROM",bp="POS",p="P",snp="ID", main = "Manhattan plot: logistic")
dev.off()

# results_as <- read.table("assoc_results.assoc", head=TRUE)
# jpeg("assoc_manhattan.jpeg")
# manhattan(results_as,chr="CHR",bp="BP",p="P",snp="SNP", main = "Manhattan plot: assoc")
# dev.off()  
