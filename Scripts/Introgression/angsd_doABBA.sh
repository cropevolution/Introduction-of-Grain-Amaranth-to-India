#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth/  
#SBATCH -o /scratch/asingh3/Indian_Amaranth/logs/angsd-ABBA_POP-Log-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/logs/angsd-ABBA_POP-Log-%j.err
#SBATCH -t 3-24:00:00
#SBATCH -J angsd-ABBA-POP
#SBATCH --partition=smp-rh7
#SBATCH --mem 168g
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with updates


INPUT_BAM='GeneFlow-PopBamList.txt'
SIZE_FILE='GeneFlow-PopSize.txt'
OUTPUT_FILE='Analysis/Introgression/ABBA-BABA_full_Genome_India-MBE_POP_maf002.Angsd'


/home/asingh3/TOOLS/angsd/bin/angsd -doAbbababa2 1 \
-bam $INPUT_BAM \
-sizeFile $SIZE_FILE \
-out $OUTPUT_FILE \
-ref /home/asingh3/Reference_Genomes/Ahypochondriacus/V2_2/Ahypochondriacus_2.2_polished.softmasked.fasta \
-doCounts 1 \
-doMaf 1 \
-domajorminor 1 \
-useLast 1 \
-remove_bads 1 \
-minMapQ 30 \
-minQ 30 \
-gl 2 \
-checkBamHeaders 0 \
-minInd 88 \
-only_proper_pairs 1 \
-trim 0 \
-setMinDepth 88 \
-setMaxDepthInd 150 \
-minMaf 0.02 
