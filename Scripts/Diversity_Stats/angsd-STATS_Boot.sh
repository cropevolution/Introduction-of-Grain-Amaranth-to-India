#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth/Diversity_Bootstrap/
#SBATCH -o /scratch/asingh3/Indian_Amaranth/logs/STATSLog-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/logs/STATSLog-%j.err
#SBATCH -t 5-24:00:00
#SBATCH -J angsd-STATS-Bootstrap
#SBATCH --partition=smp-rh7
#SBATCH --mem 200g
#SBATCH --array=0-9
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with updates



FILES=(PopDetailFiles/*.txt)
FILE="$(basename ${FILES[$SLURM_ARRAY_TASK_ID]})"
#FILE="$(basename ${FILES})"
echo processing ${FILE}
# random subsample 10 accessions
for i in {1..50}
do
shuf -n 10 ${FILE} > ${FILE}_suf_${i}

######## SFS calculation #####
/home/asingh3/TOOLS/angsd/bin/angsd \
-bam ${FILE}_suf_${i} \
-ref /home/asingh3/Reference_Genomes/Ahypochondriacus/V2_2/Ahypochondriacus_2.2_polished.softmasked.fasta \
-anc /home/asingh3/Reference_Genomes/Ahypochondriacus/V2_2/Ahypochondriacus_2.2_polished.softmasked.fasta \
-GL 2 \
-out ${FILE}_suf_${i}_folded-NEW \
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
${FILE}_suf_${i}_folded-NEW.saf.idx \
-fold 1 > ${FILE}_suf_${i}_folded-NEW.sfs

#### Diversity Stats ###### theta per site
/home/asingh3/TOOLS/angsd/bin/realSFS saf2theta ${FILE}_suf_${i}_folded-NEW.saf.idx -sfs ${FILE}_suf_${i}_folded-NEW.sfs -outname ${FILE}_suf_${i}_folded-NEW -fold 1
### Theta estimates
/home/asingh3/TOOLS/angsd/bin/thetaStat do_stat ${FILE}_suf_${i}_folded-NEW.thetas.idx -win 10000 -step 10000 -outnames ${FILE}_suf_${i}_folded-NEW.thetas.windows.gz
done




