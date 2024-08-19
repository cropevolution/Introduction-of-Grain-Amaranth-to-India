
######## vcf to bed biallelic


plink2 \
  --vcf All_Samples_India-MBE_MAF_filter005_Missing-80percent-MAF002.vcf.gz \
  --allow-extra-chr \
  --keep SampleNames.txt \
  --keep-allele-order \
  --maf 0.05 \
  --make-bed \
  --max-alleles 2 \
  --out All_samples_MBE-Indian_full_genome-missFilter_maf0.05_Biallelic \
  --set-all-var-ids @:# \
  --snps-only 
 
 ######## LD pruning
plink2 \
  --allow-extra-chr \
  --bfile All_samples_MBE-Indian_full_genome-missFilter_maf0.05_Biallelic \
  --indep-pairwise 50 5 0.3 \
  --keep-allele-order \
  --out indep-pairwise 

##### extract LD pruned data
plink2 \
  --allow-extra-chr \
  --bfile All_samples_MBE-Indian_full_genome-missFilter_maf0.05_Biallelic \
  --extract indep-pairwise.prune.in \
  --make-bed \
  --out All_samples_MBE-Indian_full_genome-missFilter_maf0.05_Biallelic.pruned
  
 
############# PCA - No miss filter
plink2 \
  --allow-extra-chr \
  --bfile All_samples_MBE-Indian_full_genome-missFilter_maf0.05_Biallelic.pruned \
  --out All_samples_MBE-Indian_full_genome-missFilter_maf0.05_Biallelic.pruned_PCA \
  --pca


