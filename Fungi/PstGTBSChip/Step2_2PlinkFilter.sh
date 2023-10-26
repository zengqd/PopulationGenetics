#!/usr/bin/env bash
##This script is utilized to filter the Plink file generated in the first step.

#software depended
#plink

​plink --file file --geno 0.25 ​--maf 0.05 --mind 0.05 --keep-allele-order --export vcf --out file.geno0.25.maf0.05.mind0.05 --allow-extra-chr​​


plink --vcf file.geno0.25.maf0.05.mind0.05.vcf \
--indep-pairwise 100kb 50 0.2 \
--out ld_100kb_50_0.2 \
--allow-extra-chr

#Extract the sites after LD
plink --vcf file.geno0.25.maf0.05.mind0.05.vcf \
--make-bed \
--extract ld_100kb_50_0.2.prune.in \
--out file.geno0.25.maf0.05.mind0.05.ld_100kb_50_0.2 \
--recode vcf-iid \
--keep-allele-order \
--allow-extra-chr
