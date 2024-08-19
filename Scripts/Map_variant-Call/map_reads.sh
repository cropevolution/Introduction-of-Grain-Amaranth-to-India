#!/bin/bash -l
#SBATCH -D /scratch/asingh3/Indian_Amaranth/  
#SBATCH -o /scratch/asingh3/Indian_Amaranth/logs/mappingLog-%j.txt
#SBATCH -e /scratch/asingh3/Indian_Amaranth/logs/mappingLog-%j.err
#SBATCH -t 15:00:00
#SBATCH -J Indian_amaranth_Mapping
#SBATCH --nodes=1
#SBATCH --ntasks 8
#SBATCH --mem 12g
#SBATCH --mail-type=ALL # if you want emails, otherwise remove
#SBATCH --account=UniKoeln
#SBATCH --mail-user=asingh3@uni-koeln.de # receive an email with updates



# Load modules
module use /opt/rrzk/modules/experimental
module load bwamem2/2.2.1
module load samtools/1.13


REFERENCE=/home/asingh3/Reference_Genomes/Ahypochondriacus/V2_2/Ahypochondriacus_2.2_polished.softmasked.fasta
#bwa-mem2 index $REFERENCE


PROVIDER=NOVOGENE

OUTPUTPATH=Analysis/bam_files 
FASTQPATH=/scratch/asingh3/Indian_Amaranth/FastqFiles
mkdir -p $OUTPUTPATH
mkdir -p $OUTPUTPATH/metrics/


IFS=$'\n' SAMPLES=($(cat Accessions.txt))

for ((i=0;i<${#SAMPLES[@]};++i));

do 
	echo Maping reads of ${SAMPLES[i]}
SORTED_NAME=${OUTPUTPATH}/${SAMPLES[i]}.bam
echo $SORTED_NAME

bwa-mem2 mem -t 8 -R '@RG\tID:'${SAMPLES[i]}'\tSM:'${SAMPLES[i]}'\tCN:'${PROVIDER}'\tPL:illumina' $REFERENCE ${FASTQPATH}/${SAMPLES[i]}_L4L3_R1.fq.gz ${FASTQPATH}/${SAMPLES[i]}_L4L3_R2.fq.gz | samtools sort -O bam -o ${SORTED_NAME}


#echo mark duplicates
DEDUP_NAME=${OUTPUTPATH}/${SAMPLES[i]}.final.bam
METRICS_FILE=${OUTPUTPATH}/metrics/${SAMPLES[i]}.txt
java -Xmx4g -jar /home/asingh3/TOOLS/picard.jar MarkDuplicates INPUT=$SORTED_NAME OUTPUT=$DEDUP_NAME METRICS_FILE=$METRICS_FILE
samtools index $DEDUP_NAME

echo calculate samtools flagstat
samtools flagstat ${DEDUP_NAME} > ${OUTPUTPATH}/metrics/${SAMPLES[i]}.flagstat

echo removing sorted bam
rm $SORTED_NAME


done
