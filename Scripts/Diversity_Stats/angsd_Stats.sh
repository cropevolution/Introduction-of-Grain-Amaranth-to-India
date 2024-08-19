#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth/  
#SBATCH -o /scratch/asingh3/Indian_Amaranth/logs/STATSLog-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/logs/STATSLog-%j.err
#SBATCH -t 4-24:00:00
#SBATCH -J angsd-STATS
#SBATCH --partition=smp-rh7
#SBATCH --mem 250g
#SBATCH --array=0-10
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with updates

#FILES=(Analysis/Population_Stats/*.txt)
FILES=(PopulationLists/*.txt)
#NAME="$(basename ${FILES})"
#FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
FILE="$(basename ${FILES[$SLURM_ARRAY_TASK_ID]})"
echo processing ${FILE}
######## SFS calculation #####
/home/asingh3/TOOLS/angsd/bin/angsd \
-bam PopulationLists/${FILE} \
-ref /home/asingh3/Reference_Genomes/Ahypochondriacus/V2_2/Ahypochondriacus_2.2_polished.softmasked.fasta \
-anc /home/asingh3/Reference_Genomes/Ahypochondriacus/V2_2/Ahypochondriacus_2.2_polished.softmasked.fasta \
-GL 2 \
-out Analysis/SFS/${FILE}_folded \
-nThreads 12 \
-dosaf 1 \
-minMapQ 30 \
-minQ 30 \
-uniqueOnly 1 \
-remove_bads 1 \
-only_proper_pairs 1 \
-trim 0 \
-c 50 \
-doCounts 1


/home/asingh3/TOOLS/angsd/bin/realSFS \
Analysis/SFS/${FILE}_folded.saf.idx \
-fold 1 > Analysis/SFS/${FILE}_folded.sfs

#### Diversity Stats ###### theta per site
/home/asingh3/TOOLS/angsd/bin/realSFS saf2theta Analysis/SFS/${FILE}_folded.saf.idx -sfs Analysis/SFS/${FILE}_folded.sfs -outname Analysis/SFS/${FILE}_folded -fold 1
### Theta estimates
/home/asingh3/TOOLS/angsd/bin/thetaStat do_stat Analysis/SFS/${FILE}_folded.thetas.idx -win 10000 -step 10000 -outnames Analysis/SFS/${FILE}_folded.thetas.windows.gz
