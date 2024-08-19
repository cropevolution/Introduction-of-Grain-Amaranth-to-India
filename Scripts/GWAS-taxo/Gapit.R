library(GAPIT)
myY <- read.table("PhenotypeFile-noHybrid.txt", head = TRUE)

## LD Filter-SNP removed
setwd("/scratch/asingh3/Indian_Amaranth/GAPIT/")
myG <- read.delim("Hypo-Caudatus-taxonomy.vcf.hmp.txt", head = FALSE)
myGAPIT <- GAPIT(
Y=myY,
G=myG,
PCA.total=3,
model="CMLM")


