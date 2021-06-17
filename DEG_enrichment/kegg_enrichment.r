library("clusterProfiler")
library("ggplot2")
library("stringr")
library("AnnotationHub")
library("biomaRt")
library("pathview")
library("KEGGREST")
library("png")
library("enrichplot")

args=commandArgs(T)
DE_gene_info <- read.csv(args[1])
DE_gene <- as.vector(DE_gene_info[,1])

gene_info <- read.csv(args[1])
geneList <- gene_info$log2FoldChange
#names(geneList) = as.character(gene_info$Symbol)
names(geneList) = as.character(gene_info$ID)
geneList <- sort(geneList,decreasing=TRUE)

DE_gene_ID <- as.vector(gene_info[,1])

ekegg <- enrichKEGG(gene=names(geneList),
    organism="onl",
    keyType="kegg",
    pvalueCutoff = 0.05,
)
write.csv(ekegg,file=paste(args[2],"_kegg_enrichment.txt",sep=""))

suffix <- args[2]
pathways <- ekegg$ID
for (pathway in pathways){
    url <- browseKEGG(ekegg,pathway)
    html <- str_c("<!doctype html>", "<html>", "<head>", paste("<script language=\"javascript\"> location.replace(\"",url,"\") </script>", sep=""), "</head>", "</html>",sep="\n")
    cat(html, file=paste(pathway, "_", args[2], ".html", sep=""))

    png <- keggGet(pathway, "image")
    writePNG(png,paste(pathway,".png",sep=""))

    res <- keggGet(pathway, "kgml")
    write(res,paste(pathway,".xml",sep=""))
}

for (pathway in pathways){
            p <- pathview(gene.data = geneList,
            pathway.id = pathway,
            species    = "onl",
            out.suffix = suffix,
    )
}
