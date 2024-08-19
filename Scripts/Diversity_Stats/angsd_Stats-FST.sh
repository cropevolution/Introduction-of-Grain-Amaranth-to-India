#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth/Angsd/ 
#SBATCH -o /scratch/asingh3/Indian_Amaranth/logs/FSTLog-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/logs/FSTLog-%j.err
#SBATCH -t 1-24:00:00
#SBATCH -J angsd-FST
#SBATCH --partition=smp-rh7
#SBATCH --mem 96g
#SBATCH --array=0-55
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with updates


#Angsd/2D-SFS
#Angsd/FST
## optimise it with array

#mkdir Analysis/FST
#### 1. First calculate the saf for each population (10 populations) -already calculated for Stats
### 2. Calculate 2D-sfs for each population pair - all pairwise SFS- 55 sfs(2D)

IFS=$'\n' array1=($(cat Pair1.txt))
IFS=$'\n' array2=($(cat Pair2.txt))

/home/asingh3/TOOLS/angsd/bin/realSFS \ 
1D-SFS/${array1[$SLURM_ARRAY_TASK_ID]}_folded.saf.idx  1D-SFS/${array2[$SLURM_ARRAY_TASK_ID]}_folded.saf.idx \
-fold 1 > 2D-SFS/${array1[$SLURM_ARRAY_TASK_ID]}_${array2[$SLURM_ARRAY_TASK_ID]}_folded.ml

#### 3. Prepare the fst for easy analysis
/home/asingh3/TOOLS/angsd/bin/realSFS fst index \
1D-SFS/${array1[$SLURM_ARRAY_TASK_ID]}_folded.saf.idx  1D-SFS/${array2[$SLURM_ARRAY_TASK_ID]}_folded.saf.idx \
-sfs 2D-SFS/${array1[$SLURM_ARRAY_TASK_ID]}_${array2[$SLURM_ARRAY_TASK_ID]}_folded.ml \
-fstout FST/${array1[$SLURM_ARRAY_TASK_ID]}_${array2[$SLURM_ARRAY_TASK_ID]}_FST

### global FST
/home/asingh3/TOOLS/angsd/bin/realSFS fst stats FST/${array1[$SLURM_ARRAY_TASK_ID]}_${array2[$SLURM_ARRAY_TASK_ID]}_FST.fst.idx > FST/${array1[$SLURM_ARRAY_TASK_ID]}_${array2[$SLURM_ARRAY_TASK_ID]}_FST.EStimate-global

### Sliding window
/home/asingh3/TOOLS/angsd/bin/realSFS fst stats2 FST/${array1[$SLURM_ARRAY_TASK_ID]}_${array2[$SLURM_ARRAY_TASK_ID]}_FST.fst.idx -win 50000 -step 10000 > FST/${array1[$SLURM_ARRAY_TASK_ID]}_${array2[$SLURM_ARRAY_TASK_ID]}_FST_slidingwindow




