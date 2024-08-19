## script adapted and modified from https://github.com/Capblancq/RDA-landscape-genomics/tree/main

library(pegas)
library(ggplot2)
library(raster)
library(rgdal)
library(LEA)
library(rnaturalearth)
library(rnaturalearthdata)
library(RColorBrewer)
library(ggpubr)
library(vegan)
library(qvalue)
library(robust)
library(WMDB)
library(ggVennDiagram)
library(cowplot)
library(ggcorrplot)
library(rgeos)
library(dplyr)
library(viridis)
library(grid)
library(reshape2)


###read genetic data
Genotypes <- read.table("File_4_RDA.maf05.pruned.90miss.raw", header = T)
InfoInd <- read.table("PopAssignment.txt", sep = "\t", header = T)
names(InfoInd)
data = subset(Genotypes, select = -c(FID,IID,PAT,MAT,SEX,PHENOTYPE) )
row.names(data) = Genotypes$IID
row.names(data)
data <- data[match(InfoInd$SamID, row.names(data), nomatch = 0),]
row.names(data)
#names(data)
AllFreq <- aggregate(data, by = list(InfoInd$Pop), function(x) mean(x, na.rm = T)/2)
row.names(AllFreq) <- as.character(AllFreq$Group.1)
row.names(AllFreq) 
for (i in 1:ncol(AllFreq))
{
  AllFreq[which(is.na(AllFreq[,i])),i] <- median(AllFreq[-which(is.na(AllFreq[,i])),i], na.rm=TRUE)
}
row.names(AllFreq) =AllFreq$Group.1

### import in same name convention for easy script adoption
data <- AllFreq[,-1]
############

## read neutral genetic data for population structure
neutral <- read.table("File_4_RDA.maf05.Neutral-intergenicSNPS.pruned.90miss.raw", header = T)
names(neutral[1:8])
data1 = subset(neutral, select = -c(FID,IID,PAT,MAT,SEX,PHENOTYPE) )
names(data1[1:8])
head(data1[1:8,5])
row.names(data1) = neutral$IID
row.names(data1)

data1 <- data1[match(InfoInd$SamID, row.names(data1), nomatch = 0),]
# Calculate AF and impute missing
AllFreq_neutral <- aggregate(data1, by = list(InfoInd$Pop), function(x) mean(x, na.rm = T)/2)
for (i in 2:ncol(AllFreq_neutral))
{
  AllFreq_neutral[which(is.na(AllFreq_neutral[,i])),i] <- median(AllFreq_neutral[-which(is.na(AllFreq_neutral[,i])),i], na.rm=TRUE)
}
row.names(AllFreq_neutral) =AllFreq_neutral$Group.1

# conduct PCA for getting PCs for population stucture
pca <- rda(AllFreq_neutral[,-1], scale=T)
pca
pdf("PCA-ScreePlot-Genotype-90miss-imputed.pdf")
screeplot(pca, type = "barplot", npcs=10, main="PCA Eigenvalues")
dev.off()
#Store PC information
PCs <- scores(pca, choices=c(1:3), display="sites", scaling=0)
##recheck the formats
head(PCs)

### read and format climatic data

Coordinates <- read.table("BioClim-location.txt", sep = "\t", header = T, row.names = 1)

## formating in Population Format
Coordinates <- Coordinates[match(InfoInd$SamID, row.names(Coordinates), nomatch = 0),]
nrow(Coordinates)
Coordinates
PopCoordinates <- aggregate(Coordinates, by = list(InfoInd$Pop), function(x) mean(x))
nrow(PopCoordinates)
## Standardization of the variables to remove the effect due to different metric system
Env <- scale(PopCoordinates[4:22], center=TRUE, scale=TRUE)
# storing of scaled value for future use
scale_env <- attr(Env, 'scaled:scale')
center_env <- attr(Env, 'scaled:center')
# the PC into the climatic variables
Variables <- data.frame(PopCoordinates[2:3],PopCoordinates[23],Env, PCs)
row.names(Variables) = PopCoordinates$Group.1

### RDA for varaible selection
RDA0 <- rda(data ~ 1,  Variables) 
RDA0  # null model

# climate model for variable selection 
### use only non-collinear variables
# checked corSelect VIF <10, : "Bio2"  "Bio3"  "Bio8"  "Bio9"  "Bio13" "Bio14" "Bio15" "Bio19" are best variable non collinear with VIF and coor <0.7
 RDAfull <- rda(data ~ Bio2+Bio3+Bio8+Bio9+Bio13+Bio14+Bio15+Bio19, Variables) 
# RDAfull <- rda(data ~ Bio1+Bio2+Bio3+Bio4+Bio5+Bio6+Bio7+Bio8+Bio9+Bio10+Bio11+Bio12+Bio13+Bio14+Bio15+Bio16+Bio17+Bio18+Bio19, Variables)

#Seclection using vegan ordiR2step process
mod <- ordiR2step(RDA0, RDAfull, Pin = 0.01, R2permutations = 1000, R2scope = T)
mod

## Bio3 + Bio9
## Variance partitioning based on selected variable (above result of mod)
#Full model including genetic and geography
pRDAful <- rda(formula = data ~ PC1 + PC2 + PC3 + X_Long + Y_Lat + Elevation + Bio3 + Bio9, data = Variables)
RsquareAdj(pRDAful)
anova(pRDAful)
anova.cca(pRDAful, step = 1000, by = "term")
#Climatic model constrained by genetic and geography
pRDAclim <- rda(data ~ Bio3 + Bio9 + Condition(PC1 + PC2 + PC3 + X_Long + Y_Lat + Elevation), Variables)
RsquareAdj(pRDAclim)
anova(pRDAclim)
anova.cca(pRDAclim, step = 1000, by = "term")
 
#Genetic model
pRDAstruct <- rda(data ~ PC1 + PC2 + PC3 + Condition(Bio3 + Bio9 + X_Long + Y_Lat + Elevation), data = Variables)
RsquareAdj(pRDAstruct)
anova(pRDAstruct)
anova.cca(pRDAstruct, step = 1000, by = "term")

# Geogrpahical model
pRDAgeo <- rda(data ~ X_Long + Y_Lat + Elevation + Condition(PC1 + PC2 + PC3 + Bio3 + Bio9), data = Variables)
RsquareAdj(pRDAgeo)
anova(pRDAgeo)
anova.cca(pRDAgeo, step = 1000, by = "term")
 
#Plotting RDA
perc <- round(100*(summary(pRDAful)$cont$importance[2, 1:2]), 2)
perc
pdf("pRDAFul-text12.pdf")
plot(pRDAful, xlab=paste0("RDA1 (",perc["RDA1"],"%)"), ylab=paste0("RDA2 (",perc["RDA2"],"%)"))
dev.off()

### Correlation between selected factors used - to have idea of dependency among variables
SelVar <- select(Variables, c('PC1','PC2','PC3','Bio3', 'Bio9', 'X_Long', 'Y_Lat', 'Elevation')) 
corr <- round(cor(SelVar),1)
p.mat <- cor_pmat(SelVar)
ggcorrplot(corr, method = "circle", outline.col="white", type="upper")
#ggsave("Correlation_ExpVariables.png")
ggsave("Correlation_ExpVariables.pdf")

### different color for native and India
samDetail <- read.table("Sam_Pop-Region.txt", header=T, sep="\t", row.names=1)
Variables$ecotype <- samDetail$Region
pdf("pRDA_full_colored.pdf")
plot(pRDAful, xlab=paste0("RDA1 (",perc["RDA1"],"%)"), ylab=paste0("RDA2 (",perc["RDA2"],"%)"),type="n", scaling=3)
points(pRDAful, display="sites", pch=21, cex=1.3, col="gray32", scaling=3, bg=c("orange", "green")[factor(Variables$ecotype)])
text(pRDAful, scaling=3, display="bp", col="#0868ac", cex=1)
legend("bottomright", legend=c("India","Native"), bty="n", col="gray32", pch=21, cex=1, pt.bg=c("orange","green"))
dev.off()


##### GEA - loci identification (after the identification significant factors)
RDA_env <- rda(data ~ Bio3 + Bio9 + Condition(PC1 + PC2 + PC3 ), Variables)
pdf("Screeplot_RDA-constrained-env.pdf")
screeplot(RDA_env, main="Eigenvalues of constrained axes")
dev.off()

#### add here for plotting RDA with specific colors
perc <- round(100*(summary(RDA_env)$cont$importance[2, 1:2]), 2)
pdf("RDA_env_colored.pdf")
plot(RDA_env, xlab=paste0("RDA1 (",perc["RDA1"],"%)"), ylab=paste0("RDA2 (",perc["RDA2"],"%)"),type="n", scaling=3)
points(RDA_env, display="sites", pch=21, cex=1.3, col="gray32", scaling=3, bg=c("orange", "green")[factor(Variables$ecotype)])
text(RDA_env, scaling=3, display="bp", col="#0868ac", cex=1)
legend("topleft", legend=c("India","Native"), bty="n", col="gray32", pch=21, cex=1, pt.bg=c("orange","green"))
dev.off()



### Identifying GxE interaction
source("rdadapt.R")
rdadapt_env<-rdadapt(RDA_env, 2)   ### with 2 RDA axis - explaining all variations

write.table(rdadapt_env, file="GEA_RDA-all.csv")
## P-values threshold after Bonferroni correction  this time used qvalue cutoff of 0.05
#thres_env <- 0.01/length(rdadapt_env$p.values) ### this is top 1%
thres_env <- max(rdadapt_env$p.values[which(rdadapt_env$q.values<0.05)])
  
## Identifying the loci that are below the p-value threshold
outliers <- data.frame(Loci = colnames(data)[which(rdadapt_env$p.values<thres_env)], p.value = rdadapt_env$p.values[which(rdadapt_env$p.values<thres_env)], contig = unlist(lapply(strsplit(colnames(data)[which(rdadapt_env$p.values<thres_env)], split = "\\."), function(x) x[1])))
write.table(outliers, file="GEA_outliers.csv")

## Top hit outlier per contig
outliers <- outliers[order(outliers$contig, outliers$p.value),]
## List of outlier names 
outliers_rdadapt_env <- as.character(outliers$Loci[!duplicated(outliers$contig)])
write.table(outliers_rdadapt_env, file="GEA_outliers_topperContig.csv")


## Formatting of list of outlier names to match for plotting
locus_scores <- scores(RDA_env, choices=c(1:2), display="species", scaling="none") # vegan references "species", here these are the loci
TAB_loci <- data.frame(names = row.names(locus_scores), locus_scores)
TAB_loci$type <- "Neutral"
TAB_loci$type[TAB_loci$names%in%outliers$Loci] <- "All outliers"
TAB_loci$type[TAB_loci$names%in%outliers_rdadapt_env] <- "Top outliers"
TAB_loci$type <- factor(TAB_loci$type, levels = c("Neutral", "All outliers", "Top outliers"))
TAB_loci <- TAB_loci[order(TAB_loci$type),]
TAB_var <- as.data.frame(scores(RDA_env, choices=c(1,2), display="bp")) # pull the biplot scores
  
## Biplot of RDA loci and variables scores
ggplot() +
   geom_hline(yintercept=0, linetype="dashed", color = gray(.80), size=0.6) +
   geom_vline(xintercept=0, linetype="dashed", color = gray(.80), size=0.6) +
   geom_point(data = TAB_loci, aes(x=RDA1*20, y=RDA2*20, colour = type), size = 1.4) +
   scale_color_manual(values = c("gray90", "#F9A242FF", "#6B4596FF")) +
   geom_segment(data = TAB_var, aes(xend=RDA1, yend=RDA2, x=0, y=0), colour="black", size=0.15, linetype=1, arrow=arrow(length = unit(0.02, "npc"))) +
   geom_text(data = TAB_var, aes(x=1.1*RDA1, y=1.1*RDA2, label = row.names(TAB_var)), size = 2.5, family = "Times") +
   xlab("RDA 1") + ylab("RDA 2") +
   facet_wrap(~"RDA space") +
   guides(color=guide_legend(title="Locus type")) +
   theme_bw(base_size = 11, base_family = "Times") +
   theme(panel.background = element_blank(), legend.background = element_blank(), panel.grid = element_blank(), plot.background = element_blank(), legend.text=element_text(size=rel(.8)), strip.text = element_text(size=11))
ggsave("Env-selectedLoci-plot.pdf")
#ggsave("Env-selectedLoci-plot.png")
dev.off()


## Manhattan plot
Outliers <- rep("Neutral", length(colnames(data)))
Outliers[colnames(data)%in%outliers$Loci] <- "All outliers"
Outliers[colnames(data)%in%outliers_rdadapt_env] <- "Top outliers"
Outliers <- factor(Outliers, levels = c("Neutral", "All outliers", "Top outliers"))
TAB_manhatan <- data.frame(pos = 1:length(colnames(data)), 
                             pvalues = rdadapt_env$p.values, 
                             Outliers = Outliers)
TAB_manhatan <- TAB_manhatan[order(TAB_manhatan$Outliers),]
ggplot(data = TAB_manhatan) +
   geom_point(aes(x=pos, y=-log10(pvalues), col = Outliers), size=1.4) +
   scale_color_manual(values = c("gray90", "#F9A242FF", "#6B4596FF")) +
   xlab("Loci") + ylab("-log10(p.values)") +
   geom_hline(yintercept=-log10(thres_env), linetype="dashed", color = gray(.80), size=0.6) +
   facet_wrap(~"Manhattan plot", nrow = 3) +
   guides(color=guide_legend(title="Locus type")) +
   theme_bw(base_size = 11, base_family = "Times") +
   theme(legend.position="right", legend.background = element_blank(), panel.grid = element_blank(), legend.box.background = element_blank(), plot.background = element_blank(), panel.background = element_blank(), legend.text=element_text(size=rel(.8)), strip.text = element_text(size=11))
ggsave("ManhattonPlot-Env.pdf")
#ggsave("ManhattonPlot-Env.png")
dev.off()

#### Running another RDA not accounting for the popoulation structure to check the reliability of the loci - may be onlyu select loci that overlap in both RDAs
RDA_env_unconstrained <- rda(data ~ Bio3 + Bio9  , Variables)
rdadapt_env_unconstrained <- rdadapt(RDA_env_unconstrained, 2)
thres_env <- max(rdadapt_env$p.values[which(rdadapt_env$q.values<0.05)])
outliers_unconstrained <- data.frame(Loci = colnames(data)[which(rdadapt_env_unconstrained$p.values<thres_env)], p.value = rdadapt_env_unconstrained$p.values[which(rdadapt_env_unconstrained$p.values<thres_env)], contig = unlist(lapply(strsplit(colnames(data)[which(rdadapt_env_unconstrained$p.values<thres_env)], split = "\\."), function(x) x[1])))
outliers_unconstrained <- outliers_unconstrained[order(outliers_unconstrained$contig, outliers_unconstrained$p.value),]
outliers_rdadapt_env_unconstrained <- as.character(outliers_unconstrained$Loci[!duplicated(outliers_unconstrained$contig)])
list_outliers_RDA_all <- list(RDA_constrained = as.character(outliers$Loci), RDA_unconstrained = as.character(outliers_unconstrained$Loci))
length(rdadapt_env_unconstrained$p.values)
write.table(outliers_unconstrained, file="Outliers_unconstrained.csv")
### plot venn Diagram
ggVennDiagram(list_outliers_RDA_all, category.names = c("partial RDA", "simple RDA"), lty="solid", size=0.2) + 
   scale_fill_gradient2(low = "white", high = 'gray40') + scale_color_manual(values = c("grey", "grey", "grey", "grey")) + guides(fill = "none") + theme(text = element_text(size=16, family = "Times"))
ggsave("Venn-Constrained-UnconstrainedRDA.png")
dev.off()
common_outliers_RDA_top <- Reduce(intersect, list_outliers_RDA_all)
write.table(common_outliers_RDA_top, file="List-Common_outliers_const-unconstrained.csv")

#### Now working on the adaptive landscape (#52)
# First working for the common outliers identified via constrained and inconstrained analysis

#Adaptively enriched RDA
RDA_outliers <- rda(data[,common_outliers_RDA_top] ~ Bio3 + Bio9, Variables)
RDA_outliers
## Variantion explained by two RDA axis
perc <- round(100*(summary(RDA_outliers)$cont$importance[2, 1:2]), 2)
perc

## RDA biplot
TAB_loci <- as.data.frame(scores(RDA_outliers, choices=c(1:2), display="species", scaling="none"))    # Species score
TAB_var <- as.data.frame(scores(RDA_outliers, choices=c(1:2), display="bp"))
ggplot() +
  geom_hline(yintercept=0, linetype="dashed", color = gray(.80), size=0.6) +
  geom_vline(xintercept=0, linetype="dashed", color = gray(.80), size=0.6) +
  geom_point(data = TAB_loci, aes(x=RDA1*3, y=RDA2*3), colour = "#EB8055FF", size = 2, alpha = 0.8) + #"#F9A242FF"
  geom_segment(data = TAB_var, aes(xend=RDA1, yend=RDA2, x=0, y=0), colour="black", size=0.15, linetype=1, arrow=arrow(length = unit(0.02, "npc"))) +
  geom_text(data = TAB_var, aes(x=1.1*RDA1, y=1.1*RDA2, label = row.names(TAB_var)), size = 2.5, family = "Times") +
  xlab(paste0("RDA1 (",perc["RDA1"],"%)")) + ylab(paste0("RDA2 (",perc["RDA2"],"%)")) +
  facet_wrap(~"Adaptively enriched RDA space") +
  guides(color=guide_legend(title="Locus type")) +
  theme_bw(base_size = 11, base_family = "Times") +
  theme(panel.grid = element_blank(), plot.background = element_blank(), panel.background = element_blank(), strip.text = element_text(size=11))
ggsave("Adaptively_enriched-RDAspace-commonOutliers.pdf")
#ggsave("Adaptively_enriched-RDAspace-commonOutliers.png")
dev.off()

### Now calculate adaptive index across landscape
## Function to predict the adaptive index across the landscape



source("adaptive_index.R")
## have to set the climate and range for adadptive index prediction along with the scalinf index doen during data loading
#define range and trimmed climate from India and Native
ras_India <- stack(list.files("ClimateData/Present/", pattern = "_India.img$", full.names = T))
ras_Native <- stack(list.files("ClimateData/Present/", pattern = "_Native.img$", full.names = T))
### remove missing data
remove.NAs.stack<-function(rast.stack){
   nom<-names(rast.stack)
   test1<-calc(rast.stack, fun=sum)
   test1[!is.na(test1)]<-1
   test2<-rast.stack*test1
   test2<-stack(test2)
   names(test2)<-nom
   return(test2)
 }
ras_India <- remove.NAs.stack(ras_India)
ras_Native <- remove.NAs.stack(ras_Native) 

### map administrative boundaries
admin <- ne_countries(scale = "medium", returnclass = "sf")  
names(ras_India) <- c("Bio1","Bio2","Bio3","Bio4","Bio5","Bio6","Bio7","Bio8","Bio9","Bio10","Bio11","Bio12","Bio13","Bio14","Bio15","Bio16","Bio17","Bio18","Bio19")
names(ras_Native) <- c("Bio1","Bio2","Bio3","Bio4","Bio5","Bio6","Bio7","Bio8","Bio9","Bio10","Bio11","Bio12","Bio13","Bio14","Bio15","Bio16","Bio17","Bio18","Bio19")

## Running the function for all the climatic pixels
res_RDA_proj_current <- adaptive_index(RDA = RDA_outliers, K = 2, env_pres = ras_India, method = "loadings", scale_env = scale_env, center_env = center_env)

## Vectorization of the climatic rasters for ggplot
RDA_proj <- list(res_RDA_proj_current$RDA1, res_RDA_proj_current$RDA2)
RDA_proj <- lapply(RDA_proj, function(x) rasterToPoints(x))
for(i in 1:length(RDA_proj)){
  RDA_proj[[i]][,3] <- (RDA_proj[[i]][,3]-min(RDA_proj[[i]][,3]))/(max(RDA_proj[[i]][,3])-min(RDA_proj[[i]][,3]))
}

## Adaptive genetic turnover projected across lodgepole pine range for RDA1 and RDA2 indexes
TAB_RDA <- as.data.frame(do.call(rbind, RDA_proj[1:2]))
colnames(TAB_RDA)[3] <- "value"
TAB_RDA$variable <- factor(c(rep("RDA1", nrow(RDA_proj[[1]])), rep("RDA2", nrow(RDA_proj[[2]]))), levels = c("RDA1","RDA2"))
ggplot(data = TAB_RDA) + 
  geom_sf(data = admin, fill=gray(.9), size=0) +
  geom_raster(aes(x = x, y = y, fill = cut(value, breaks=seq(0, 1, length.out=10), include.lowest = T))) + 
  scale_fill_viridis_d(alpha = 0.8, direction = -1, option = "A", labels = c("Negative scores","","","","Intermediate scores","","","","Positive scores")) +
  geom_sf(data = admin, fill=NA, size=0.1) +
  coord_sf(xlim = c(70, 90), ylim = c(0, 35), expand = FALSE) +
  xlab("Longitude") + ylab("Latitude") +
  guides(fill=guide_legend(title="Adaptive index")) +
  facet_grid(~ variable) +
  theme_bw(base_size = 11, base_family = "Times") +
  theme(panel.grid = element_blank(), plot.background = element_blank(), panel.background = element_blank(), strip.text = element_text(size=11))
ggsave("AdaptiveGeneticTurnover_India.png")
#ggsave("AdaptiveGeneticTurnover_India.pdf")
dev.off()

###adaptive landcape finished ################3

##############Prediction of genomic offset for future climate - In- India ##########################################################################
###   check for the data using future climate
# 1. Load future climate data
# India 2040, India 2100
ras_India_2040 <- stack(list.files("ClimateData/Future2040/", pattern = "_India.img$", full.names = T))
ras_India_2100 <- stack(list.files("ClimateData/Future2100/", pattern = "_India.img$", full.names = T))

### remove missing data
ras_India_2040 <- remove.NAs.stack(ras_India_2040)    # function to remove missing values defined earlier
names(ras_India_2040) <- c("Bio1","Bio2","Bio3","Bio4","Bio5","Bio6","Bio7","Bio8","Bio9","Bio10","Bio11","Bio12","Bio13","Bio14","Bio15","Bio16","Bio17","Bio18","Bio19")
ras_India_2100 <- remove.NAs.stack(ras_India_2100)    # function to remove missing values defined earlier
names(ras_India_2100) <- c("Bio1","Bio2","Bio3","Bio4","Bio5","Bio6","Bio7","Bio8","Bio9","Bio10","Bio11","Bio12","Bio13","Bio14","Bio15","Bio16","Bio17","Bio18","Bio19")

#Function to predict genomic offset from a RDA model
source("genomic_offset.R")

## Running the function for 2040
res_RDA_proj2040 <- genomic_offset(RDA_outliers, K = 2, env_pres = ras_India, env_fut = ras_India_2040, method = "loadings", scale_env = scale_env, center_env = center_env)
res_RDA_proj2100 <- genomic_offset(RDA_outliers, K = 2, env_pres = ras_India, env_fut = ras_India_2100, method = "loadings", scale_env = scale_env, center_env = center_env)


RDA_proj_offset <- data.frame(rbind(rasterToPoints(res_RDA_proj2040$Proj_offset_global), rasterToPoints(res_RDA_proj2100$Proj_offset_global)), Date = c(rep("2040", nrow(rasterToPoints(res_RDA_proj2040$Proj_offset_global))), rep("2100", nrow(rasterToPoints(res_RDA_proj2100$Proj_offset_global)))))

## Projecting genomic offset on a map

## all two
colors <- c(colorRampPalette(brewer.pal(11, "Spectral")[6:5])(2), colorRampPalette(brewer.pal(11, "Spectral")[4:3])(2), colorRampPalette(brewer.pal(11, "Spectral")[2:1])(3))
ggplot(data = RDA_proj_offset) + 
  geom_sf(data = admin, fill=gray(.9), size=0) +
  geom_raster(aes(x = x, y = y, fill = cut(Global_offset, breaks=seq(0, 7, by = 1), include.lowest = T)), alpha = 1) + 
  scale_fill_manual(values = colors, labels = c("0-1","1-2","2-3","3-4","4-5","5-6","6-7"), guide = guide_legend(title="Genomic offset", title.position = "top", title.hjust = 0.5, ncol = 1, label.position="right"), na.translate = F) +
  geom_sf(data = admin, fill=NA, size=0.1) +
  coord_sf(xlim = c(70, 90), ylim = c(5, 35), expand = FALSE) +
  xlab("Longitude") + ylab("Latitude") +
  facet_grid(~ Date) +
  theme_bw(base_size = 11, base_family = "Times") +
  theme(panel.grid = element_blank(), plot.background = element_blank(), panel.background = element_blank(), strip.text = element_text(size=11))
ggsave("India_geoOffset2040_NEW-Croped.png")
#ggsave("India_geoOffset2040_NEW-Croped.pdf")
dev.off()


##### Predict genomic offset for the Native range
# Load climatic data
ras_Native_2040 <- stack(list.files("ClimateData/Future2040/", pattern = "_Native.img$", full.names = T))
ras_Native_2100 <- stack(list.files("ClimateData/Future2100/", pattern = "_Native.img$", full.names = T))

### remove missing data
ras_Native_2040 <- remove.NAs.stack(ras_Native_2040)    # function to remove missing values defined earlier
names(ras_Native_2040) <- c("Bio1","Bio2","Bio3","Bio4","Bio5","Bio6","Bio7","Bio8","Bio9","Bio10","Bio11","Bio12","Bio13","Bio14","Bio15","Bio16","Bio17","Bio18","Bio19")
ras_Native_2100 <- remove.NAs.stack(ras_Native_2100)    # function to remove missing values defined earlier
names(ras_Native_2100) <- c("Bio1","Bio2","Bio3","Bio4","Bio5","Bio6","Bio7","Bio8","Bio9","Bio10","Bio11","Bio12","Bio13","Bio14","Bio15","Bio16","Bio17","Bio18","Bio19")


## Running the function for 2040
res_RDA_proj2040 <- genomic_offset(RDA_outliers, K = 2, env_pres = ras_Native, env_fut = ras_Native_2040, method = "loadings", scale_env = scale_env, center_env = center_env)
res_RDA_proj2100 <- genomic_offset(RDA_outliers, K = 2, env_pres = ras_Native, env_fut = ras_Native_2100, method = "loadings", scale_env = scale_env, center_env = center_env)

RDA_proj_offset <- data.frame(rbind(rasterToPoints(res_RDA_proj2040$Proj_offset_global/100), rasterToPoints(res_RDA_proj2100$Proj_offset_global)), Date = c(rep("2040", nrow(rasterToPoints(res_RDA_proj2040$Proj_offset_global))), rep("2100", nrow(rasterToPoints(res_RDA_proj2100$Proj_offset_global)))))


## Projecting genomic offset on a map
colors <- c(colorRampPalette(brewer.pal(11, "Spectral")[6:5])(2), colorRampPalette(brewer.pal(11, "Spectral")[4:3])(2), colorRampPalette(brewer.pal(11, "Spectral")[2:1])(3))
ggplot(data = RDA_proj_offset) + 
  geom_sf(data = admin, fill=gray(.9), size=0) +
  geom_raster(aes(x = x, y = y, fill = cut(Global_offset, breaks=seq(0, 8, by = 1), include.lowest = T)), alpha = 1) + 
  scale_fill_manual(values = colors, labels = c("0-1","1-2","2-3","3-4","4-5","5-6","6-7","7-8"), guide = guide_legend(title="Genomic offset", title.position = "top", title.hjust = 0.5, ncol = 1, label.position="right"), na.translate = F) +
  geom_sf(data = admin, fill=NA, size=0.1) +
   coord_sf(xlim = c(-85, -50), ylim = c(5, -40), expand = FALSE) + 
  xlab("Longitude") + ylab("Latitude") +
  facet_grid(~ Date) +
  theme_bw(base_size = 11, base_family = "Times") +
  theme(panel.grid = element_blank(), plot.background = element_blank(), panel.background = element_blank(), strip.text = element_text(size=11))
  
ggsave("Native_geoOffset2040_NEW-Croped.png")
#ggsave("Native_geoOffset2040_NEW-Croped.pdf")
dev.off()


#########Geographical offset
####### Genomic offset on the basis of geographical location

##Source script
source("provgar_offset.R")
## read, format and scale the environmental variables
envn <- row.names(scores(RDA_outliers, choices=c(1:2), display="bp"))  # selecting names of only selected significant variables for RDA
coor_India <- subset(samDetail, Region == "India", select = c(X_Long,Y_Lat))
coor_Native <- subset(samDetail, Region == "Native", select = c(X_Long,Y_Lat))

## Extracting environmental values for each source population and for each time frame
# For Present
envir_Native_Present <- data.frame(extract(ras_Native, coor_Native))
envir_India_Present <- data.frame(extract(ras_India, coor_India))

envir_Native_Present <- envir_Native_Present[, envn]
envir_Native_Present <- as.data.frame(scale(envir_Native_Present, center = center_env[envn], scale = scale_env[envn]))
envir_India_Present <- envir_India_Present[, envn]
envir_India_Present <- as.data.frame(scale(envir_India_Present, center = center_env[envn], scale = scale_env[envn]))

## For 2040
envir_Native_2040 <- data.frame(extract(ras_Native_2040, coor_Native))
envir_India_2040 <- data.frame(extract(ras_India_2040, coor_India))

envir_Native_2040 <- envir_Native_2040[, envn]
envir_Native_2040 <- as.data.frame(scale(envir_Native_2040, center = center_env[envn], scale = scale_env[envn]))
envir_India_2040 <- envir_India_2040[, envn]
envir_India_2040 <- as.data.frame(scale(envir_India_2040, center = center_env[envn], scale = scale_env[envn]))

## For 2100
envir_Native_2100 <- data.frame(extract(ras_Native_2100, coor_Native))
envir_India_2100 <- data.frame(extract(ras_India_2100, coor_India))

envir_Native_2100 <- envir_Native_2100[, envn]
envir_Native_2100 <- as.data.frame(scale(envir_Native_2100, center = center_env[envn], scale = scale_env[envn]))
envir_India_2100 <- envir_India_2040[, envn]
envir_India_2100 <- as.data.frame(scale(envir_India_2100, center = center_env[envn], scale = scale_env[envn]))


### projecting Indian samples to native for each Time frame
#1. Present
envir_Native <- colMeans(envir_Native_Present)

provgar_offsetI2N_Present <- provgar_offset(RDA = RDA_outliers, K = 2, env_garden = envir_Native, env_provenance = envir_India_Present, weights = TRUE)
write.table(provgar_offsetI2N_Present, file="Geographic_offset-India2Native_Present.csv")

tabmaha <- as.data.frame(rbind(envir_Native, envir_India_Present))
mahaclim <- mahalanobis(as.matrix(tabmaha), center = as.numeric(tabmaha[1,]), cov = cov(as.matrix(tabmaha)))
write.table(tabmaha, file="ClimaticDistance_India2Native_Present.csv")
write.table(mahaclim, file="mahaDistIndia2Native_Present.txt")

# 2040
envir_Native <- colMeans(envir_Native_2040)

provgar_offsetI2N_2040 <- provgar_offset(RDA = RDA_outliers, K = 2, env_garden = envir_Native, env_provenance = envir_India_2040, weights = TRUE)
write.table(provgar_offsetI2N_2040, file="Geographic_offset-India2Native_2040.csv")

tabmaha <- as.data.frame(rbind(envir_Native, envir_India_2040))
mahaclim <- mahalanobis(as.matrix(tabmaha), center = as.numeric(tabmaha[1,]), cov = cov(as.matrix(tabmaha)))
write.table(tabmaha, file="ClimaticDistance_India2Native_2040.csv")
write.table(mahaclim, file="mahaDistIndia2Native_2040.txt")

# 2100
envir_Native <- colMeans(envir_Native_2100)

provgar_offsetI2N_2100 <- provgar_offset(RDA = RDA_outliers, K = 2, env_garden = envir_Native, env_provenance = envir_India_2100, weights = TRUE)
write.table(provgar_offsetI2N_2100, file="Geographic_offset-India2Native_2100.csv")

tabmaha <- as.data.frame(rbind(envir_Native, envir_India_2100))
mahaclim <- mahalanobis(as.matrix(tabmaha), center = as.numeric(tabmaha[1,]), cov = cov(as.matrix(tabmaha)))
write.table(tabmaha, file="ClimaticDistance_India2Native_2100.csv")
write.table(mahaclim, file="mahaDistIndia2Native_2100.txt")




################################################
#### PAI and SGV in the sampled populations ####

mean_q <- apply(1-data[, common_outliers_RDA_top], 2, mean)

# Population adaptive index (Bonin et al. 2007) 
PAI <- lapply(1:nrow(data), function(x) sum(abs((1-data[x,common_outliers_RDA_top])-mean_q), na.rm=T))
names(PAI) <- row.names(data)

SVG <- lapply(lapply(1:nrow(data), function(x) data[x,common_outliers_RDA_top]*(1-data[x,common_outliers_RDA_top])), function(y) mean(unlist(y)))
names(SVG) <- row.names(data)

TAB <- data.frame(Latitude = Variables$Y_Lat, Longitude = Variables$X_Long, PAI = unlist(PAI), SVG = unlist(SVG))
write.table(TAB, file="PAI_SVG.csv")
admin <- ne_countries(scale = "medium", returnclass = "sf") 
p_SGV <- ggplot() +
  geom_sf(data=admin, colour = NA, fill = "gray95", size = 0.3) +
  #geom_raster(aes(x=x,y=y,fill="gray75"), fill="gray75") +
  #geom_polygon(data=range, aes(long, lat, group = group), colour = NA, fill = "gray75", size = 0.3) +
  geom_sf(data=admin, colour = NA, fill = "gray95", size = 0.3) +
  geom_point(data=TAB, aes(x= Longitude, y= Latitude, size = SVG, colour = PAI)) + 
  scale_color_gradient(low="#FFEDA0", high = "red") +
  xlab("Longitude") + ylab("Latitude") +
  theme_bw() +
  theme(panel.grid.major = element_blank())

native <- p_SGV + coord_sf(xlim = c(-85, -50), ylim = c(5, -40), expand = FALSE)
india <- p_SGV + coord_sf(xlim = c(70, 85), ylim = c(5, 35), expand = FALSE) 
g1 <- ggplotGrob(native)
g2 <- ggplotGrob(india)
g <- cbind(g1, g2, size="first")

pdf("GeneticOffset_PAI_SGV_India-native.pdf", width = 12, height = 4)
grid.newpage()
grid.draw(g)
dev.off()

################################################

