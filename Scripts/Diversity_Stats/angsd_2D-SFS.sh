#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth/  
#SBATCH -o /scratch/asingh3/Indian_Amaranth/logs/2D-SFS-Log-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/logs/2D-SFS-Log-%j.err
#SBATCH -t 2-24:00:00
#SBATCH -J angsd-2D-SFS
#SBATCH --partition=smp-rh7
#SBATCH --mem 200g
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with updates

#### 1. First calculate the saf for each population (11 populations) -already calculated for angsd Stats
### 2. Calculate 2D-sfs for each population pair - all pairwise SFS- 55 sfs(2D)

IFS=$'\n' array1=($(cat PopulationLists/Pairs-1.txt))
IFS=$'\n' array2=($(cat PopulationLists/Pairs-2.txt))

 for ((i=2;i<${#array1[@]};++i));
    do

/home/asingh3/TOOLS/angsd/bin/realSFS \
SFS/${array1[i]}_folded.saf.idx  SFS/${array2[i]}_folded.saf.idx \
-fold 1 > FST-ml/${array1[i]}_${array2[i]}_folded.ml
done

#/home/asingh3/TOOLS/angsd/bin/realSFS SFS/Caudatus_India.txt_folded.saf.idx SFS/Caudatus_Native.txt_folded.saf.idx -fold 1 > 2D-SFS/Caudatus_India-Native_2dsfs.sfs
