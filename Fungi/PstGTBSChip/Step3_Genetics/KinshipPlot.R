#kinship
#calculate the kinship based on the kinship matrix file through tassel

library(pheatmap)
kinship <- read.table("file.filter.kinship.txt", header = F, row.names = 1, skip=3)
colnames(kinship) <- row.names(kinship)
#diag(kinship) <- NA
hist_data <- hist(as.matrix(kinship), xlab = "Kinship", col = "red", main = "Histogram of Kinship")
pheatmap(kinship, fontsize_row = 1, fontsize_col = 1)
