#calculate the kinship matrix file through tassel
run_pipeline.pl -Xms5g -Xmx50g -importGuess file.filter.vcf -KinshipPlugin -method Centered_IBS -endPlugin -export file.filter.kinship.txt -exportType SqrMatrix

Rscript KinshipPlot.R
