#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth
#SBATCH -o /scratch/asingh3/Indian_Amaranth/logs/angsd-VCF-all-missFilter-Log-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/logs/angsd-VCF-all-missFilter-Log-%j.err
#SBATCH -t 2-07:00:00
#SBATCH -J angsd_VCF_all-missFilter
#SBATCH --partition=smp-rh7
#SBATCH --cpus-per-task=5
#SBATCH --mem 250g
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with updates

### Get genotype likelihoos in beagle format
/home/asingh3/TOOLS/angsd/bin/angsd \
-bam BamFileList-4vcf.txt \
-out Analysis/Angsd/VCF/All_samples_MBE-Indian_full_genome-missFilter \
-P 5 \
-ref /home/asingh3/Reference_Genomes/Ahypochondriacus/V2_2/Ahypochondriacus_2.2_polished.softmasked.fasta \
-doCounts 1 \
-doGeno 3 \
-dopost 2 \
-domajorminor 1 \
-domaf 1 \
-dovcf 1 \
-snp_pval 1e-6 \
-remove_bads 1 \
-minMapQ 30 \
-minQ 30 \
-gl 2 \
-checkBamHeaders 0 \
-minInd 88 \
-only_proper_pairs 1 \
-trim 0 \
-setMinDepth 88 \
-setMaxDepthInd 150 
