#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth
#SBATCH -o /scratch/asingh3/Indian_Amaranth/logs/Bcftools-reheader-Log-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/logs/Bcftools-reheader-Log-%j.err
#SBATCH -t 15:30:00
#SBATCH -J Bcftools-reheader
#SBATCH --partition=smp-rh7
#SBATCH --cpus-per-task=5
#SBATCH --mem 8g
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with updates

module load vcftools/0.1.17
vcftools --gzvcf Analysis/Angsd/VCF/All_samples_MBE-Indian_full_genome-missFilter-newHeader.vcf.gz --mac 3 --max-missing 0.8 --recode --recode-INFO-all --stdout | gzip -c > All_samples_MBE-Indian_full_genome-missFilter-newHeader-MAC3.80missFiltered.vcf.gz
