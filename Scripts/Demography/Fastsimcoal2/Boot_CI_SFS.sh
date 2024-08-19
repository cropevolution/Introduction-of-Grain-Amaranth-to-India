#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth/Demography/Caudatus/BestModel_CI/
#SBATCH -o /scratch/asingh3/Indian_Amaranth/Demography/Caudatus/logs/Boot_CI-fs-Log-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/Demography/Caudatus/logs/Boot_CI-fs-Log-%j.err
#SBATCH -t 2-12:00:00
#SBATCH -J Caudatus-BootCI
#SBATCH --partition=smp-rh7
#SBATCH --mem 2g
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with updates

  /home/asingh3/TOOLS/fsc27_linux64/fsc27093 -i 2PopSplit_maxL.par -n100 -m -x -L 40 -s0 -j 

