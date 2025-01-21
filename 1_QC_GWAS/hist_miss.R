indmiss<-read.table(text = sub("#", "", readLines("plink2.smiss")), header = TRUE)
snpmiss<-read.table(text = sub("#", "", readLines("plink2.vmiss")), header = TRUE)
# read data into R 

pdf("histsmiss.pdf") #indicates pdf format and gives title to file
hist(indmiss[,"F_MISS"],main="Histogram individual missingness") #selects column 6, names header of file

pdf("histvmiss.pdf") 
hist(snpmiss[,"F_MISS"],main="Histogram SNP missingness")  
dev.off() # shuts down the current device
