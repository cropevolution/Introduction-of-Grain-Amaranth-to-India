#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth
#SBATCH -o /scratch/asingh3/Indian_Amaranth/logs/Heterozygosity-Log-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/logs/Heterozygosity-Log-%j.err
#SBATCH -t 24:00:00
#SBATCH -J SFS-Heterozygosity
#SBATCH --partition=smp-rh7
#SBATCH --cpus-per-task=5
#SBATCH --mem 24g
#SBATCH --array=0-300
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with updates

#mkdir Analysis/Angsd
#mkdir Analysis/Angsd/SFS
FILES=(Analysis/bam_files/*.final.bam)
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}

############# all files would be in Analysis/bam_files
echo processing ${FILE}
######## SFS calculation #####
/home/asingh3/TOOLS/angsd/bin/angsd \
-i ${FILE} \
-ref /home/asingh3/Reference_Genomes/Ahypochondriacus/V2_2/Ahypochondriacus_2.2_polished.softmasked.fasta \
-anc /home/asingh3/Reference_Genomes/Ahypochondriacus/V2_2/Ahypochondriacus_2.2_polished.softmasked.fasta \
-GL 2 \
-out ${FILE}_folded \
-nThreads 12 \
-dosaf 1 \
-minMapQ 30 \
-minQ 20 \
-uniqueOnly 1 \
-remove_bads 1 \
-only_proper_pairs 1 \
-trim 0 \
-c 50 

/home/asingh3/TOOLS/angsd/bin/realSFS \
${FILE}_folded.sfs.idx \
> ${FILE}_folded.sfs.est.ml

