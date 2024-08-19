#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth
#SBATCH -o /scratch/asingh3/Indian_Amaranth/logs/easySFS-Log-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/logs/easySFS-Log-%j.err
#SBATCH -t 10:00:00
#SBATCH -J easySFS
#SBATCH --partition=smp-rh7
#SBATCH --mem 150g
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with update

module load vcftools
module load miniconda
conda activate easySFS

### Filter vcf file for the genic regions given in the gff file (converted into bed)
vcftools --gzvcf All_Samples_India-MBE_MAF_filter005_Missing-80percent-MAF002.vcf.gz --exclude-bed Ahypochondriacus_2.2_polished_corrected.bed --keep Hypochondriacus_India.txt --keep Hypochondriacus_source-unadmixed.txt --recode --recode-INFO-all --stdout | bgzip -c  > Hypochondriacus_India_Native_all_chr_NOGENES.vcf.gz

vcftools --gzvcf All_Samples_India-MBE_MAF_filter005_Missing-80percent-MAF002.vcf.gz --exclude-bed Ahypochondriacus_2.2_polished_corrected.bed --keep Caudatus_India.txt --keep Caudatus_source-unadmixed.txt --recode --recode-INFO-all --stdout | bgzip -c  > Caudatus_India_Native_AllChr_NOGENES.vcf.gz

#Caudatus	
#./easySFS/easySFS.py -i Caudatus_India_Native_AllChr_NOGENES.vcf.gz -p PopDetails_VCF_FSC-Caudatus.txt --preview
./easySFS/easySFS.py -i Caudatus_India_Native_AllChr_NOGENES.vcf.gz -p PopDetails_VCF_FSC-Caudatus.txt -a --proj 26,22 -o SFS_Cau --order Caudatus_Native,Caudatus_India
#Hypochondriacus
#./easySFS/easySFS.py -i Hypochondriacus_India_Native_all_chr_NOGENES.vcf.gz -p PopDetails_VCF_FSC.txt --preview
./easySFS/easySFS.py -i Hypochondriacus_India_Native_all_chr_NOGENES.vcf.gz -p PopDetails_VCF_FSC.txt -a --proj 26,66 -o SFS_Hypo --order Hypochondriacus_Native,Hypochondriacus_India

