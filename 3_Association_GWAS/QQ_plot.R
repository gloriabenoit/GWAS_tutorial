install.packages("qqman",repos="https://mirror.ibcp.fr/pub/CRAN/",lib="~") # location of installation can be changed but has to correspond with the library location 
library("qqman",lib="~") 
results_log <- read.table(text = sub("#", "", readLines("logistic_results_2.PHENO1.glm.logistic.hybrid")), header = TRUE)
pdf("QQ-Plot_logistic.pdf")
qq(results_log$P, main = "Q-Q plot of GWAS p-values : log")
dev.off()

# results_as <- read.table("assoc_results.assoc", head=TRUE)
# pdf("QQ-Plot_assoc.pdf")
# qq(results_as$P, main = "Q-Q plot of GWAS p-values : log")
# dev.off()

