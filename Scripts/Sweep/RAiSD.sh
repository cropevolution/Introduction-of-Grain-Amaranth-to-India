#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth/Sweep-RAISD  
#SBATCH -o /scratch/asingh3/Indian_Amaranth/logs/Sweep-Raisd-Log-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/logs/Sweep-Raisd-Log-%j.err
#SBATCH -t 3-15:00:00
#SBATCH -J RAiSD_Sweep
#SBATCH --mem 2g
#SBATCH --array=0-11
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with updates

#RAiSD/raisd-master/RAiSD 

#module load gsl/2.7.1 
#module load vcftools
FILES=(SampleFiles/*.txt)
FILE="$(basename ${FILES[$SLURM_ARRAY_TASK_ID]})"

#FILE="$(basename ${Sample})"
echo processing ${FILE}

module load vcftools
vcftools --gzvcf All_Samples_India-MBE_MAF_filter005_Missing-80percent-MAF002.vcf.gz --keep ${FILES[$SLURM_ARRAY_TASK_ID]} --recode --recode-INFO-all --out ${FILE}_forRAISD

module unload vcftools

module load gsl
/scratch/asingh3/Indian_Amaranth/RAiSD/raisd-master/RAiSD -n ${FILE} -I ${FILE}_forRAISD.recode.vcf -f -R

#/scratch/asingh3/Indian_Amaranth/RAiSD/raisd-master/RAiSD -n ${FILE}_manhat -I ${FILE}_forRAISD.recode.vcf -A 0.99

