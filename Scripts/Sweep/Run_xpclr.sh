

INPUT_VCF=./All_Samples_India-MBE_MAF_filter005_Missing-80percent-MAF002.vcf.gz
mkdir RESULTS

##### India Vs Native comparisons
for PopA in Hypochondriacus_India Hypochondriacus_mix_India Hybrid_India; 
do 
 for PopB in Hypochondriacus_Native;
  do
   mkdir RESULTS/${PopA}_${PopB}
   for CHR in {1..16};
   do
     xpclr --out RESULTS/${PopA}_${PopB}/${PopA}_${PopB}_Scaffold_${CHR} --input $INPUT_VCF --samplesA SampleFiles/${PopA}.txt --samplesB SampleFiles/${PopB}.txt --chr Scaffold_${CHR} --size 10000 --maxsnps 500 -V 40 --ld 0.8 
   done
  done
done


# Caudatus-Native
PopA=Caudatus_India
PopB=Caudatus_Native

   mkdir RESULTS/${PopA}_${PopB}
   for CHR in {1..16};
   do
     xpclr --out RESULTS/${PopA}_${PopB}/${PopA}_${PopB}_Scaffold_${CHR} --input $INPUT_VCF --samplesA SampleFiles/${PopA}.txt --samplesB SampleFiles/${PopB}.txt --chr Scaffold_${CHR} --size 10000 --maxsnps 500 -V 40 --ld 0.8 
   done

