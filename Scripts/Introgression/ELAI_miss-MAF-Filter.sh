#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth
#SBATCH -o /scratch/asingh3/Indian_Amaranth/logs/ELAI-misMAF-Log-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/logs/ELAI-misMAF-Log-%j.err
#SBATCH -t 20-24:00:00
#SBATCH -J ELAI_misMAF
#SBATCH --partition=smp-rh7
#SBATCH --mem 96g
#SBATCH --array=1-16
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with update


for POP in Hypochondriacus_mix_India Hybrid_India Caudatus_India Hypochondriacus_India Cruentus_India;
do
for rep in {1..10};
do

	ELAI/ELAI/src/elai -g InputFiles/Scaffold_${SLURM_ARRAY_TASK_ID}/Caudatus_source-unadmixed_Scaffold${SLURM_ARRAY_TASK_ID}_plink_bimbam.geno.txt -p 10 -g InputFiles/Scaffold_${SLURM_ARRAY_TASK_ID}/Hypochondriacus_source-unadmixed_Scaffold${SLURM_ARRAY_TASK_ID}_plink_bimbam.geno.txt -p 11 -g InputFiles/Scaffold_${SLURM_ARRAY_TASK_ID}/Cruentus_source-unadmixed_Scaffold${SLURM_ARRAY_TASK_ID}_plink_bimbam.geno.txt -p 12 -g InputFiles/Scaffold_${SLURM_ARRAY_TASK_ID}/${POP}_Scaffold${SLURM_ARRAY_TASK_ID}_plink_bimbam.geno.txt -p 1 -pos InputFiles/Scaffold_${SLURM_ARRAY_TASK_ID}/Caudatus_India_Scaffold${SLURM_ARRAY_TASK_ID}_plink_bimbam.pos.txt -s 30 -C 3 -c 15 -o ${POP}_Scaffold${SLURM_ARRAY_TASK_ID}_misMAF_replicate${rep} -mixgen 100 --exclude-nopos --exclude-miss1 --exclude-maf 0.01 --exclude-miss 0.05

done
done
