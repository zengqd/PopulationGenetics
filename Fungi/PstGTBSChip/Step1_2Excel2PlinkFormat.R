# 加载openxlsx包
library(openxlsx)

# 读取Excel文件
dat <- read.xlsx("All.GT.xlsx")

# 提取特定列，并设置CM列的值为0
map <- data.frame(dat[, c(2, 1, 3, 3)])
colnames(map) <- c("FID", "IID", "cM", "pos")
map$cM <- 0

# 提取除去前4列之外的所有列，并设置x3、x4、x5、x6的初始值为0
ped <- as.data.frame(t(dat[, -c(1:4)]))
rownames(ped) <- 1:nrow(ped)
ped <- cbind(ID = rownames(ped), x3 = 0, x4 = 0, x5 = 0, x6 = 0, ped)

# 写入文件
write.table(map, "file.map", col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\t")
write.table(ped, "file.ped", col.names = FALSE,  quote = FALSE, sep = "\t", na = "00")
