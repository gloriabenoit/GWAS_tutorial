indmiss<-read.table(text = sub("#", "", readLines("plink2.smiss")), header = TRUE)
snpmiss<-read.table(text = sub("#", "", readLines("plink2.vmiss")), header = TRUE)
# read data into R 

jpeg("histsmiss.jpeg", quality=100, height=600, width=600) #indicates jpeg format and gives title to file
hist(indmiss[,"F_MISS"],main="Histogram individual missingness",xlab="Missingness") #selects column 6, names header of file

jpeg("histvmiss.jpeg", quality=100, height=600, width=600) 
hist(snpmiss[,"F_MISS"],main="Histogram SNP missingness", xlab="Missingness")  
dev.off() # shuts down the current device
