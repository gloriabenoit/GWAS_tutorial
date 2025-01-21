gender <- read.table(text = sub("#", "", readLines("plink2.sexcheck")), header = TRUE)

pdf("Gender_check.pdf")
hist(gender[,"F"],main="Gender", xlab="F")
dev.off()

pdf("Men_check.pdf")
male=subset(gender, PEDSEX==1)
hist(male[,"F"],main="Men",xlab="F")
dev.off()

pdf("Women_check.pdf")
female=subset(gender, PEDSEX==2)
hist(female[,"F"],main="Women",xlab="F")
dev.off()
