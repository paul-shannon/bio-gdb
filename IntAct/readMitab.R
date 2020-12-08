f <- "incoming/intact.txt"
tbl.orig <- read.table(f, sep="\t", header=FALSE, as.is=TRUE, nrow=-1, fill=TRUE, quote="")
tbl.all <- tbl.orig
dim(tbl.all) # 1,123,041  42
colnames(tbl.all) <- c("A",
                       "B",
                       "alt.A",
                       "alt.B",
                       "aliases.A",
                       "aliases.B",
                       "method",
                       "Publication 1st author(s)",
                       "Publication Identifier(s)",
                       "taxid.A",
                       "taxid.B",
                       "type",
                       "Source database(s)",
                       "Interaction identifier(s)",
                       "confidence",
                       "Expansion method(s)",
                       "Biological role(s) interactor A",
                       "Biological role(s) interactor B",
                       "Experimental role(s) interactor A",
                       "Experimental role(s) interactor B",
                       "type.A",
                       "type.B",
                       "Xref(s) interactor A",
                       "Xref(s) interactor B",
                       "Interaction Xref(s)",
                       "Annotation(s) interactor A",
                       "Annotation(s) interactor B",
                       "Interaction annotation(s)",
                       "Host organism(s)",
                       "Interaction parameter(s)",
                       "Creation date",
                       "Update date",
                       "Checksum(s) interactor A",
                       "Checksum(s) interactor B",
                       "Interaction Checksum(s)",
                       "Negative",
                       "Feature(s) interactor A",
                       "Feature(s) interactor B",
                       "Stoichiometry(s) interactor A",
                       "Stoichiometry(s) interactor B",
                       "idMethod.A",
                       "idMethod.B")


    #------------------------------------------------------------
    # create a representative but tractable subset, for
    # experimentation, methods development
    #------------------------------------------------------------

set.seed(17)
both.human <- intersect(grep("taxid:9606", tbl.all$taxid.A), grep("taxid:9606", tbl.all$taxid.B))
length(both.human)
tbl.2 <- tbl.all[both.human,]
dim(tbl.2)  # 583450 42
coi <- c("A", "B", "method", "type", "idMethod.A", "idMethod.B", "confidence")
all(coi %in% colnames(tbl.2))
tbl.3 <- tbl.2[, coi]
dim(tbl.3)   # 583k  7

  # 561k/583k offer uniprotkb ids for both A and B
uniprot.both.ids <- intersect(grep("uniprotkb", tbl.3$A), grep("uniprotkb", tbl.3$B))
length(uniprot.both.ids) 560755
nrow(tbl.3) #  583450

tbl.4 <- tbl.3[uniprot.both.ids,]
tbl.4$A <- sub("-PRO.*$", "", tbl.4$A)
tbl.4$B <- sub("-PRO.*$", "", tbl.4$B)

tbl.4$A <- sub("uniprotkb:", "", tbl.4$A, fixed=TRUE)
tbl.4$B <- sub("uniprotkb:", "", tbl.4$B, fixed=TRUE)

methods <-   gsub("psi.*\\((.*?)\\)", "\\1", tbl.4$method)
methods <- to_lower_camel_case(methods)

types <-   gsub("psi.*\\((.*?)\\)", "\\1", tbl.4$type)
types <- to_lower_camel_case(types)

idMethods.A <- gsub("psi.*\\((.*?)\\)", "\\1", tbl.4$idMethod.A)
idMethods.A <- to_lower_camel_case(idMethods.A)

idMethods.B <- gsub("psi.*\\((.*?)\\)", "\\1", tbl.4$idMethod.B)
idMethods.B <- to_lower_camel_case(idMethods.B)

tbl.5 <- tbl.4
tbl.5$method <- methods
tbl.5$type <- types
tbl.5$idMethod.A <- idMethods.A
tbl.5$idMethod.B <- idMethods.B

confidence <- tbl.4$confidence
  # pick off just the trailing numeric string
conf2 <- as.numeric(sub(".*?([0-9]*\\.[0-9]*)$", "\\1", confidence))
tbl.5$confidence <- conf2
rownames(tbl.5) <- NULL

library(EnsDb.Hsapiens.v79)

poi <- tbl.5$A
tbl.id <- select(EnsDb.Hsapiens.v79, key=poi,  columns=c("UNIPROTID", "SYMBOL", "ENTREZID", "GENEID"),
                 keytype="UNIPROTID")
colnames(tbl.id) <- paste(colnames(tbl.id), "A", sep=".")
dim(tbl.id)

tbl.6 <- merge(tbl.5, tbl.id, by.x="A", by.y="UNIPROTID.A")

poi <- tbl.5$B
tbl.id <- select(EnsDb.Hsapiens.v79, key=poi,  columns=c("UNIPROTID", "SYMBOL", "ENTREZID", "GENEID"),
                 keytype="UNIPROTID")
colnames(tbl.id) <- paste(colnames(tbl.id), "B", sep=".")
dim(tbl.id)

tbl.7 <- merge(tbl.6, tbl.id, by.x="B", by.y="UNIPROTID.B")

tbl.intact <- tbl.7
save(tbl.intact, file="tbl.intact.human.RData")
write.table(tbl.intact, quote=FALSE, row.names=FALSE, col.names=TRUE, sep="\t", file="intact-human.tsv")




# a <- sub("uniprotkb:", "", tbl.3$A, fixed=TRUE)
# b <- sub("uniprotkb:", "", tbl.3$B, fixed=TRUE)
# methods <- gsub("psi.*\\((.*?)\\)", "\\1", tbl.3$method)
# as.data.frame(sort(table(methods)))
# length(grep("homo|human", tbl.all[, "Taxid interactor A"], ignore.case=TRUE, v=TRUE))  # [1] 615538
#   # identify just the human/human ppi:
# length(intersect(grep("taxid:9606", tbl.all[, "Taxid interactor A"]), grep("taxid:9606", tbl.all[, "Taxid interactor B"])))  # [1] 583450


