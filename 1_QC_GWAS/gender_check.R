gender <- read.table(text = sub("#", "", readLines("plink2.sexcheck")), header = TRUE)

jpeg("Gender_check.jpeg", quality=100, height=600, width=600)
hist(gender[,"F"],main="Gender", xlab="F")
dev.off()

jpeg("Men_check.jpeg", quality=100, height=600, width=600)
male=subset(gender, PEDSEX==1)
hist(male[,"F"],main="Men",xlab="F")
dev.off()

jpeg("Women_check.jpeg", quality=100, height=600, width=600)
female=subset(gender, PEDSEX==2)
hist(female[,"F"],main="Women",xlab="F")
dev.off()
