#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth
#SBATCH -o /scratch/asingh3/Indian_Amaranth/logs/PopSizeABC-Log-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/logs/PopSizeABC-Log-%j.err
#SBATCH -t 24:00:00
#SBATCH -J PopSizeABC
#SBATCH --partition=smp-rh7
#SBATCH --mem 96g
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with update

module load miniconda
conda activate popsizeABC
module load vcftools

for INDV in SampleFiles/*.txt
do
	echo ${INDV}
	POP=$(basename ${INDV} .txt)
	echo starting for population ${POP}
	vcftools --gzvcf All16Scaffold_sorted.vcf.gz --keep ${INDV} --recode --recode-INFO-all --non-ref-ac-any 1 --stdout | bgzip -c > ${POP}_SC16.vcf.gz

#cd PopSizeABC

# Compute observed summary statistics using the command
python2 PopSizeABC/comp_stat1/stat_from_vcf.py 

# Simulate summary statistics using the command
python2 PopSizeABC/comp_stat1/simul_data.py 

# Perform abc estimation using the command 
R -f PopSizeABC/estim/abc_ex1.R   

# Test the expected accuracy of ABC estimation using the command 
R -f PopSizeABC/estim/abc_cv_ex1.R  

#cd ..

done
