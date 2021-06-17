library(edgeR)

args=commandArgs(T)
rawcount <- as.data.frame(read.csv(args[1], row.names="gene_id"))
anno <- read.csv(args[2], sep=" ")
group <- as.factor(anno$condition)
df <- rawcount[,as.vector(anno$sample)]
deglist <- DGEList(counts=df, group=group)
deglist <- deglist[rowSums(cpm(deglist) > 1) >= 2,]
deglist <- calcNormFactors(deglist)
deglist <- estimateCommonDisp(deglist)
deglist <- estimateTagwiseDisp(deglist)
et <- exactTest(deglist)
tTag <- topTags(et, n=nrow(deglist))
tTag <- as.data.frame(tTag)
write.csv(tTag,file = args[3])
#write.table(res,file=args[3], append = FALSE, quote = TRUE, sep = "\t",)
