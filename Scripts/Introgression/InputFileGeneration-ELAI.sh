#Steps:
#generate vcf per chr
#convert vcf to plink ped map
#convert plink to bimbam using fcgene


mkdir logs
for Chr in {1..16};
do
	mkdir InputFiles/Scaffold_${Chr}
	vcftools --gzvcf All_Samples_India-MBE_MAF_filter005_Missing-80percent-MAF002.vcf.gz \
	--chr Scaffold_${Chr} \
	--keep SampleFiles/AllSelectedSamples \
	--recode --recode-INFO-all \
	--stdout | bgzip -c > AllSelected_Samples_Scaffold_${Chr}.vcf.gz
	
	for INDV in SampleFiles/*.txt;  ### add basename to clarify directory substructure
	do 
		echo ${INDV}
		POP=$(basename ${INDV} .txt)
		echo starting for population ${POP}
	
	   	vcftools --gzvcf AllSelected_Samples_Scaffold_${Chr}.vcf.gz --keep ${INDV} --plink --out ${POP}_Scaffold${Chr}_plink 
	   	fcgene --map ${POP}_Scaffold${Chr}_plink.map --ped ${POP}_Scaffold${Chr}_plink.ped --oformat bimbam --out InputFiles/Scaffold_${Chr}/${POP}_Scaffold${Chr}_plink_bimbam
	
		echo remove intermediate files for ${POP}
		rm ${POP}_Scaffold${Chr}_plink.map
		rm ${POP}_Scaffold${Chr}_plink.ped
		mv ${POP}_Scaffold${Chr}_plink.log logs/
	done
	
	echo remove intermediate vcf file for Scaffold_${Chr}
	rm AllSelected_Samples_Scaffold_${Chr}.vcf.gz 
done

#sed -i '2 c\1948609' ELAI/InputFiles/Scaffold_5/Hybrid_India_Scaffold5_plink_bimbam.geno.txt 
