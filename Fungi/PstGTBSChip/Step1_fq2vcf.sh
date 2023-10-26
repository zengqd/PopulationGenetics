#!/usr/bin/env bash

# This script performs a series of operations on genomic data, including indexing, alignment, variant calling, and filtering.
#software depended
## samtools
##GATK > 4 
##BWA


# Set reference directory and change working directory
RefDir="/path/to/reference"
CleanDataDir="/path/to/clean/data"
Bam="/path/to/output/bam/files"
sample="sample_ID"

# Indexing the reference genome
cd "$RefDir"
# BWA index
time bwa index -a bwtsw -p "${RefDir}/Ref" "${RefDir}/Ref.fa"

# Create FAIDX index
samtools faidx "${RefDir}/Ref.fa"

# Create reference dictionary
gatk --java-options "-Xmx20G -Djava.io.tmpdir=./" CreateSequenceDictionary -R "${RefDir}/Ref.fa" -O "${RefDir}/Ref.dict"

# Change directory to clean data
cd "$CleanDataDir"

# Align to reference using BWA
bwa mem -t 10 -M -R "@RG\tID:${sample}\tSM:${sample}\tLB:WGS\tPL:Illumina" "${RefDir}/Ref" "${CleanDataDir}/${i}_clean_1.fq.gz" "${CleanDataDir}/${i}_clean_2.fq.gz" 1>"${Bam}/${sample}.sam" 2>/dev/null

# Convert SAM to BAM and sort BAM file
samtools view -Sb -@ 40 -o "$Bam/$sample.bam" "$Bam/$sample.sam"
samtools sort -@ 40 -o "$Bam/$sample.sort.bam" "$Bam/$sample.bam"

# Mark PCR duplicated regions
gatk --java-options "-Xmx20G -Djava.io.tmpdir=./" MarkDuplicates -I "$Bam/$sample.sort.bam" -O "$Bam/$sample.sort.marked.bam" -M "$Bam/$sample.metrics"

# Fix mate information and create index
gatk --java-options "-Xmx20G -Djava.io.tmpdir=./" FixMateInformation -I "$Bam/$sample.sort.marked.bam" -O "$Bam/$sample.sort.marked.fixed.bam" -SO coordinate --CREATE_INDEX true
samtools index "$Bam/$sample.sort.marked.fixed.bam"

# Variant calling using HaplotypeCaller
gatk --java-options "-Xmx80G -Djava.io.tmpdir=./" HaplotypeCaller -R "${RefDir}/Ref.fa" -I "$Bam/$sample.sort.marked.fixed.bam" -ERC GVCF -O "$Bam/${sample}.g.vcf"

# Combine individual GVCF files
gatk --java-options "-Xmx20G -Djava.io.tmpdir=./" CombineGVCFs -R "${RefDir}/Ref.fa" \
"$Bam/sample1.g.vcf" \
… # Add other sample GVCF files here
"$Bam/samplen.g.vcf" \
-O V.vcf

# Genotype GVCFs to create raw variant calls
gatk --java-options "-Xmx80G -Djava.io.tmpdir=./" GenotypeGVCFs -R "${RefDir}/Ref.fa" -V V.vcf -O variants.gatk.raw1.vcf

# Filter variants based on specified criteria
gatk --java-options "-Xmx80G -Djava.io.tmpdir=./" VariantFiltration -R "${RefDir}/Ref.fa" -V variants.gatk.raw1.vcf --filter-name FilterQual --filter-expression "QUAL < 60.0" --filter-name FilterQD --filter-expression "QD < 20.0" --filter-name FilterFS --filter-expression "FS > 13.0" --filter-name FilterMQ --filter-expression "MQ < 30.0" --filter-name FilterMQRankSum --filter-expression "MQRankSum < -1.65" --filter-name FilterReadPosRankSum --filter-expression "ReadPosRankSum < -1.65" -O variants.concordance.flt1.vcf

# Remove filtered variants and create separate SNP and INDEL VCF files
grep -vP "\tFilter" variants.concordance.flt1.vcf > variants.concordance.filter1.vcf
time gatk --java-options "-Xmx80G -Djava.io.tmpdir=./" SelectVariants -R "${RefDir}/Ref.fa" -V variants.concordance.filter1.vcf --select-type-to-include INDEL -O INDEL.vcf
time gatk --java-options "-Xmx80G -Djava.io.tmpdir=./" SelectVariants -R "${RefDir}/Ref.fa" -V variants.concordance.filter1.vcf --select-type-to-include SNP -O SNP.vcf
