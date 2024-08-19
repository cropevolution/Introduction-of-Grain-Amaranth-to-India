#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth/Demography/Caudatus/BestModel_CI/2PopSplit_maxL/
#SBATCH -o /scratch/asingh3/Indian_Amaranth/Demography/Caudatus/logs/Boot_CI-fs-Log-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/Demography/Caudatus/logs/Boot_CI-fs-Log-%j.err
#SBATCH -t 29-20:00:00
#SBATCH -J Caudatus-BootCI
#SBATCH --partition=smp-rh7
#SBATCH --array=1-100
#SBATCH --mem 1g
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with updates

PREFIX="2PopSplit_maxL"
   #mkdir ${PREFIX}_$SLURM_ARRAY_TASK_ID
   cp ${PREFIX}.tpl ${PREFIX}.est ${PREFIX}.pv ${PREFIX}_$SLURM_ARRAY_TASK_ID"/"
   cd ${PREFIX}_$SLURM_ARRAY_TASK_ID
   for Rep in {1..100}
     do   
    mkdir run${Rep}
       cp ${PREFIX}.tpl ${PREFIX}.est ${PREFIX}.pv ${PREFIX}_jointMAFpop2_1.obs run${Rep}"/"
       cd run${Rep}
   /home/asingh3/TOOLS/fsc27_linux64/fsc27093 -t ${PREFIX}.tpl -n200000 -m -e ${PREFIX}.est -M -L 40  -C 10 -c 4 --removeZeroSFS --–initvalues ${PREFIX}.pv
   cd ..
   done
   cd ..

 
