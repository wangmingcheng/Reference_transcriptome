library(ggplot2)
library(ggrepel)

#DEseq2 "baseMean"      "log2FoldChange"        "lfcSE" "stat"  "pvalue"        "padj"
args <- commandArgs(trailingOnly = TRUE)
data <- as.data.frame(read.table(args[1],header=TRUE))

#de[complete.cases(final),]
de <- na.omit(data)

cut_off_pvalue <- 0.05      #统计显著性
cut_off_logFC <- 1          #差异倍数值
de$threshold <- as.factor( ifelse(de$padj < cut_off_pvalue & abs(de$log2FoldChange) >= cut_off_logFC,
                                  ifelse( de$log2FoldChange > cut_off_logFC ,'Up','Down'),
                                  'Stable'))

#pdf("Volcano_plot.pdf")
p <- ggplot(data=de, aes(x=log2FoldChange, y=-log10(padj), colour=threshold, fill=threshold )) +
    scale_color_manual(values=c("blue", "grey","red")) +    
    geom_point(alpha=0.4, size=0.5) +
    labs(x="log2(fold change)", y="-log10 (p-value)", title="Volcano Plot") +   
    geom_vline(xintercept=c(-1, 1), col="black",linetype ="dotted") +
    geom_hline(yintercept=-log10(0.05), col="red",linetype ="dotted") +
    theme_bw() +
    theme(legend.title = element_blank(), plot.title = element_text(hjust = 0.5)) 
ggsave("Volcano_plot.pdf", p)
