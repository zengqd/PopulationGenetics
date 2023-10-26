#PCA
library(ggpubr)
library(tidyverse)
library(data.table)
library(ggplot2)
rela = fread("file.filter.eigenval")
relb = fread("file.filter.eigenvec")
a <- relb
a <- a[,1:4]
write.csv(a,file='K4fz.csv')
b <- read.csv('K4fz.csv')
b <- b[,2:6]
rela$por = rela$V1/sum(rela$V1)*100
ggplot(relb,aes(x = V3,y = V4,color=Group))  +
  xlab(paste0("PC1(",round(rela$por[1],2),"%)")) +
  ylab(paste0("PC2(",round(rela$por[2],2),"%)")) +
  geom_point(size=1.0)+
  scale_colour_manual(values = c("green","red","blue"))+
  theme(panel.grid = element_blank(), panel.background = element_rect(color = 'black', fill = 'transparent'), 
        legend.key = element_rect(fill = 'transparent'))
