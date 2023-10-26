#!/usr/bin/env bash
##This script is utilized to filter the VCF file generated in the initial GATK step.

#software depended
#vcftools
#bcftools
#plink

vcftools --vcf file.vcf --max-alleles 2  --recode --recode-INFO-all --out file.ma2
vcftools --vcf file.ma2.recode.vcf --max-missing 0.75  --recode --recode-INFO-all --out file.ma2.mm0.75
bcftools filter file.ma2.mm0.75.recode.vcf  -i 'FMT/DP>3'  --output file.ma2.mm0.75.tDP3.vcf
vcftools --vcf file.ma2.mm0.75.tDP3.vcf --maf 0.05 --mac 3 --recode --recode-INFO-all --out file.ma2.mm0.75.tDP3.mac3.maf0.05

plink --vcf file.ma2.mm0.75.tDP3.mac3.maf0.05.recode.vcf \
--indep-pairwise 100kb 50 0.2 \
--out ld_100kb_50_0.2 \
--allow-extra-chr

#Extract the sites after LD
plink --vcf file.ma2.mm0.75.tDP3.mac3.maf0.05.recode.vcf  \
--make-bed \
--extract ld_100kb_50_0.2.prune.in  \
--out file.ma2.mm0.75.tDP3.mac3.maf0.05.ld_100kb_50_0.2 \
--recode vcf-iid  \
--keep-allele-order  \
--allow-extra-chr
