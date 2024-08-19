#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth/Demography/Caudatus/2PopSplit
#SBATCH -o /scratch/asingh3/Indian_Amaranth/Demography/Caudatus/logs/Fastsimcoal-2popSplit-Log-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/Demography/Caudatus/logs/Fastsimcoal-2popSplit-Log-%j.err
#SBATCH -t 04:00:00
#SBATCH -J Caudatus-2pop-Split
#SBATCH --partition=smp-rh7
#SBATCH --mem 4g
#SBATCH --array=0-99
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with updates


PREFIX="2PopSplit"
   mkdir ${PREFIX}_run$SLURM_ARRAY_TASK_ID
   cp ${PREFIX}.tpl ${PREFIX}.est ${PREFIX}_jointMAFpop1_0.obs ${PREFIX}_run$SLURM_ARRAY_TASK_ID"/"
   cd ${PREFIX}_run$SLURM_ARRAY_TASK_ID
   /home/asingh3/TOOLS/fsc27_linux64/fsc27093 -t ${PREFIX}.tpl -n200000 -m -e ${PREFIX}.est -M -L 40  -C 10 -c 4 --removeZeroSFS
   cd ..
