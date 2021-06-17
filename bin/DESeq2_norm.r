library(DESeq2)

args=commandArgs(T)
rawcount <- as.matrix(read.csv(args[1], row.names="gene_id"))
anno <- read.csv(args[2], sep=" ", row.names=1)
all(rownames(anno) %in% colnames(rawcount))
countData <- rawcount[, rownames(anno)]
all(rownames(anno) == colnames(countData))
dds <- DESeqDataSetFromMatrix(countData = countData,colData = anno, design = ~condition )
dds <- estimateSizeFactors(dds)
sizeFactors(dds)
normalized_counts <- counts(dds, normalized=TRUE)

#dds <- DESeq(dds)
write.csv(normalized_counts, file="gene_normalized_count_matrix.csv", quote=F)
#res <- results(dds)
#write.table(res,file=args[3], append = FALSE, quote = TRUE, sep = "\t",)

#library(EnhancedVolcano)
#EnhancedVolcano(res, lab = rownames(res), x = 'log2FoldChange',  y = 'pvalue')
