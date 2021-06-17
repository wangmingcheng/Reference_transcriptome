library(DESeq2)
library(pheatmap)
library(ggplot2)
library(RColorBrewer)
#library(xlsx)
library(openxlsx)
#library(writexl)

args=commandArgs(T)
rawcount <- as.matrix(read.csv(args[1], row.names="gene_id"))
anno <- read.csv(args[2], sep=" ", row.names=1)
all(rownames(anno) %in% colnames(rawcount))
countData <- rawcount[, rownames(anno)]
all(rownames(anno) == colnames(countData))
dds <- DESeqDataSetFromMatrix(countData = countData,colData = anno, design = ~condition )
dds <- DESeq(dds)
res <- results(dds)
#write.csv(as.data.frame(res),file=paste(args[3],".csv",sep=""))
write.csv(as.data.frame(res),file=paste(args[3],".csv",sep=""),quote=F)
#write.xlsx(as.data.frame(res),file=paste(args[3],".xlsx",sep=""),,quote=F)
#write.xlsx(as.data.frame(res),file=paste(args[3],".xlsx",sep=""),)
#write_xlsx(as.data.frame(res),path=paste(args[3],".xlsx",sep=""),format_headers=FALSE)

resDE <- subset(res, padj <= 0.05 & abs(log2FoldChange) >= 1)
#colnames(resDE) <- c("geneID","baseMean","log2FoldChange","lfcSE","stat","pvalue","adj")
#write.csv(as.data.frame(resDE), file=paste(args[3],"_DE.csv",sep=""))
write.csv(resDE, file=paste(args[3],"_DE.csv",sep=""),quote=F)
#write.xlsx(resDE, file=paste(args[3],"_DE.xlsx",sep=""),)
#saveWorkbook(as.data.frame(res),file=paste(args[3],"_DE.xlsx",sep=""),overwrite = TRUE)
#write_xlsx(as.data.frame(res,col.names=c("geneID","baseMean","log2FoldChange","lfcSE","stat","pvalue","adj")),path=paste(args[3],"_DE.xlsx",sep=""))

coef <- as.vector(resultsNames(dds))[2]
#print (coef)
#resLFC <- lfcShrink(dds, coef=coef, type="apeglm")
#resNorm <- lfcShrink(dds, coef=2, type="normal")
pdf(paste(args[3],"_MA.pdf",sep=""))
#a <-dev.cur()
#png(paste(args[3],"_MA.png",sep=""))
#dev.control("enable")
resAsh <- lfcShrink(dds, coef=2, type="ashr")
#plotMA(resAsh, ylim=c(-10,10))
plotMA(resAsh)
#dev.copy(which=a)
#ggsave(paste(args[3],"_MA.pdf",sep=""), p)
#ggsave(paste(args[3],"_MA.png",sep=""), p)
#dev.off()
dev.off()

data <- as.data.frame(res)
#de[complete.cases(final),]
de <- na.omit(data)

cut_off_pvalue <- 0.05      #统计显著性
cut_off_logFC <- 1          #差异倍数值
de$threshold <- as.factor( ifelse(de$padj < cut_off_pvalue & abs(de$log2FoldChange) >= cut_off_logFC,
                        ifelse( de$log2FoldChange > cut_off_logFC ,'Up','Down' ),'Stable') )
p <- ggplot(data=de, aes(x=log2FoldChange, y=-log10(padj), colour=threshold, fill=threshold )) +
    scale_color_manual(values=c("blue", "grey","red")) +    
    geom_point(alpha=0.4, size=0.5) +
    labs(x="log2(fold change)", y="-log10 (p-value)", title="Volcano Plot") +   
    geom_vline(xintercept=c(-1, 1), col="black",linetype ="dotted") +
    geom_hline(yintercept=-log10(0.05), col="red",linetype ="dotted") +
    theme_bw() +
    theme(legend.title = element_blank(), plot.title = element_text(hjust = 0.5)) 
ggsave(paste(args[3],"_volcano.pdf",sep=""), p)
#ggsave(paste(args[3],"_volcano.png",sep=""), p)

#pdf(paste(args[3],"_cor.pdf",sep=""))
vsd <- vst(dds, blind=FALSE)
sampleDists <- dist(t(assay(vsd)))
sampleDistMatrix <- as.matrix(sampleDists)
rownames(sampleDistMatrix) <- paste(vsd$condition, vsd$type, sep="-")
colnames(sampleDistMatrix) <- NULL
colors <- colorRampPalette( rev(brewer.pal(9, "Blues"))   )(255)
p <- pheatmap(sampleDistMatrix,clustering_distance_rows=sampleDists,clustering_distance_cols=sampleDists,col=colors)
ggsave(paste(args[3],"_cor.pdf",sep=""), p)
#ggsave(paste(args[3],"_cor.png",sep=""), p)

#dev.off()

p <- plotPCA(vsd, intgroup="condition") + theme_bw()
ggsave(paste(args[3],"_PCA.pdf",sep=""), p, width=8, height=14)
#ggsave(paste(args[3],"_PCA.png",sep=""), p, width=4, height=7)


#pdf(paste(args[3],"_DE_heatmap.pdf",sep=""))
ddsNorm <- estimateSizeFactors(dds)
#sizeFactors(ddsNorm)
normalized_counts <- counts(ddsNorm, normalized=TRUE)
DE_counts <- normalized_counts[which(rownames(normalized_counts) %in% rownames(resDE)),]
colnames(DE_counts) <- rownames(anno)
write.csv(DE_counts, file=paste(args[3],"_DE.counts.csv",sep=""), quote=F)
DE <- as.matrix(DE_counts)
p <- pheatmap(log2(DE+1), cluster_rows=TRUE, show_rownames=FALSE, cluster_cols=FALSE,scale = "row",color = colorRampPalette(c("navy", "white", "firebrick3"))(100))
ggsave(paste(args[3],"_DE_heatmap.pdf",sep=""),p)
#ggsave(paste(args[3],"_DE_heatmap.png",sep=""),p)

#dev.off()

#ntd <- normTransform(dds)
#select <- order(results(dds, lfcThreshold=1, altHypothesis="greaterAbs",alpha=0.05))
#select <- order(rowMeans(counts(dds,normalized=TRUE)),decreasing=TRUE)[1:20]
#df <- as.data.frame(colData(dds)[,c("condition")])
#pdf("heatmap.pdf")
#pheatmap(assay(ntd)[select,], cluster_rows=TRUE, show_rownames=FALSE, cluster_cols=FALSE, annotation_col=df)
#dev.off()

