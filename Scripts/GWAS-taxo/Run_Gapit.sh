#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth/GAPIT
#SBATCH -o /scratch/asingh3/Indian_Amaranth/GAPIT/logs/Gapit-Log-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/GAPIT/logs/Gapit-Log-%j.err
#SBATCH -t 10:00:00
#SBATCH -J GAPIT-withoutHybrid
#SBATCH --partition=smp-rh7
#SBATCH --mem 168g
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with updates


#gunzip Hypo-Caudatus-taxonomy.pruned_INPUT.vcf.hmp.txt.gz 
module load R/4.1.3_system
export R_LIBS_USER=/scratch/asingh3/TOOLS/R/4.1.3/
# R with my R program with command line arguments
R --vanilla -f Gapit.R
