library("AnnotationHub")
library("ensembldb")

hub <- AnnotationHub()
query(hub, "tilapia")
OrgDb <- hub[["AH89489"]]
columns(OrgDb)
head(keys(OrgDb, keytype = "GENEID"))
