#Conduct PCA analysis
plink --allow-extra-chr --threads 20 -vcf file.filter.vcf --pca 20 --out file.filter

Rscript PCAPlot.R
