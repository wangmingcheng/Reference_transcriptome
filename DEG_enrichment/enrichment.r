library("clusterProfiler")
library("ggplot2")
library("stringr")
library("AnnotationHub")
library("biomaRt")
library("enrichplot")
library("pathview")
library("KEGGREST")
library("png")

args=commandArgs(T)
DE_gene_info <- read.csv(args[1])
DE_gene <- as.vector(DE_gene_info[,1])

gene_info <- read.csv(args[1])
geneList <- gene_info$log2FoldChange
names(geneList) = as.character(gene_info$ID)
geneList <- sort(geneList,decreasing=TRUE)

DE_gene_ID <- as.vector(gene_info[,1])

hub <- AnnotationHub::AnnotationHub()
annoOrgDb <- hub[["AH85947"]]

###go analyse
ego <- enrichGO(gene = DE_gene_ID,
    OrgDb = annoOrgDb,
    keyType = 'ENTREZID',
    ont= "ALL",
    pvalueCutoff = 0.05,
    qvalueCutoff = 0.5,
    readable     = T
)

write.csv(ego,file=paste(args[2],"_go_enrichment.csv",sep=""))
#write.xlsx(ego,file=paste(args[2],"_go_enrichment.xlsx",sep=""))

p <- barplot(ego, showCategory=20) + ggtitle("Bar plot of enriched terms")
ggsave(paste(args[2],"_go_enrichment_barplot.pdf",sep=""), p)
ggsave(paste(args[2],"_go_enrichment_barplot.png",sep=""), p, height=7,width=14)

p <- dotplot(ego, showCategory = 20 , orderBy="GeneRatio", title = "dotplot for ORA")
ggsave(paste(args[2],"_go_enrichment_dotplot.pdf",sep=""), p)
ggsave(paste(args[2],"_go_enrichment_dotplot.png",sep=""), p, height=7, width=14)

p <- cnetplot(ego, categorySize="pvalue", foldChange=geneList,cex_label_gene=0.4,cex_label_category=0.6)
ggsave(paste(args[2],"_go_enrichment_cnetplot.pdf",sep=""), p)
ggsave(paste(args[2],"_go_enrichment_cnetplot.png",sep=""), p)

p <- cnetplot(ego, foldChange=geneList, circular = TRUE, colorEdge = TRUE,cex_label_gene=0.4,cex_label_category=0.6)
ggsave(paste(args[2],"_go_enrichment_cnetplot_circular.pdf",sep=""), p)
ggsave(paste(args[2],"_go_enrichment_cnetplot_circular.png",sep=""), p)

p <- heatplot(ego, foldChange=geneList,showCategory=20)
ggsave(paste(args[2],"_go_enrichment_heatplot.pdf",sep=""), p, width=28)
ggsave(paste(args[2],"_go_enrichment_heatplot.png",sep=""), p, width=28)

ego2 <-pairwise_termsim(ego)
p <- emapplot(ego2,cex_label_category=0.6,cex_line=0.4,layout="kk") 
ggsave(paste(args[2],"_go_enrichment_emapplot.pdf",sep=""), p)
ggsave(paste(args[2],"_go_enrichment_emapplot.png",sep=""), p)

###kegg analyse
ekegg <- enrichKEGG(gene=DE_gene_ID,
    organism="cic",
    keyType='ncbi-geneid',
    pvalueCutoff = 0.05,
)
write.csv(ekegg,file=paste(args[2],"_kegg_enrichment.csv",sep=""))
#write.xlsx(ekegg,file=paste(args[2],"_kegg_enrichment.xlsx",sep=""))

suffix <- args[2]
pathways <- ekegg$ID
for (pathway in pathways){
            p <- pathview(gene.data = geneList,
            pathway.id = pathway,
            species    = "cic",
            kegg.native= FALSE,
            pdf.size   = c(12,12),
            out.suffix = suffix,
    )
}

for (pathway in pathways){
            p <- pathview(gene.data = geneList,
            pathway.id = pathway,
            species    = "cic",
            out.suffix = suffix,
    )
    html <- str_c("<!doctype html>", "<html>", "<head>", paste("<script language=\"javascript\"> location.replace(\"https://www.genome.jp/pathway/",pathway,"\") </script>", sep=""), "</head>", "</html>",sep="\n")
    cat(html, file=paste(pathway, ".html", sep=""))
}
