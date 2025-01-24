data<- read.table(text = sub("#", "", readLines("PCA_merge2.eigenvec")), header = TRUE)
race<- read.table(file="racefile.txt", header = TRUE)
datafile<- merge(data,race,by=c("IID"))

pdf("PCA.pdf",width=500,height=500)
for (i in 1:nrow(datafile))
{
if (datafile[i,"race"]=="EUR") {plot(datafile[i,"PC1"],datafile[i,"PC2"],type="p",xlim=c(-0.1,0.2),ylim=c(-0.15,0.1),xlab="MDS Component 1",ylab="MDS Component 2",pch=1,cex=0.5,col="green")}
par(new=T)
if (datafile[i,"race"]=="ASN") {plot(datafile[i,"PC1"],datafile[i,"PC2"],type="p",xlim=c(-0.1,0.2),ylim=c(-0.15,0.1),xlab="MDS Component 1",ylab="MDS Component 2",pch=1,cex=0.5,col="red")}
par(new=T)
if (datafile[i,"race"]=="AMR") {plot(datafile[i,"PC1"],datafile[i,"PC2"],type="p",xlim=c(-0.1,0.2),ylim=c(-0.15,0.1),xlab="MDS Component 1",ylab="MDS Component 2",pch=1,cex=0.5,col=470)}
par(new=T)
if (datafile[i,"race"]=="AFR") {plot(datafile[i,"PC1"],datafile[i,"PC2"],type="p",xlim=c(-0.1,0.2),ylim=c(-0.15,0.1),xlab="MDS Component 1",ylab="MDS Component 2",pch=1,cex=0.5,col="blue")}
par(new=T)
if (datafile[i,"race"]=="OWN") {plot(datafile[i,"PC1"],datafile[i,"PC2"],type="p",xlim=c(-0.1,0.2),ylim=c(-0.15,0.1),xlab="MDS Component 1",ylab="MDS Component 2",pch=3,cex=0.7,col="black")}
par(new=T)
}

abline(v=-0.015,lty=3)
abline(h=-0.018,lty=3)
legend("topright", pch=c(1,1,1,1,3),c("EUR","ASN","AMR","AFR","OWN"),col=c("green","red",470,"blue","black"),bty="o",cex=1)
