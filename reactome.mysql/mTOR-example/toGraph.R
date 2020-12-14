library(RCyjs)
library(RUnit)
library(EnsDb.Hsapiens.v79)
library(XML)
#----------------------------------------------------------------------------------------------------
if(!exists("rcy")){
   title <- "mTOR"
   rcy <- RCyjs(title=title, quiet=TRUE)
   setBrowserWindowTitle(rcy, title)
   }
#----------------------------------------------------------------------------------------------------
tbl.pwid <- read.table("~/github/bio-gdb/reactome.mysql/xml/pathwayLabels.tsv",
                       sep="\t", header=TRUE, as.is=TRUE, quote="")
dim(tbl.pwid) # 2477 2
tbl.speciesID <- get(load("tbl.species-R-HSA-165159.RData"))

#----------------------------------------------------------------------------------------------------
# v1:  uniprot.A
# v2:  uniprot.B
# v3:  identifiers.A: reactome, refseq_NP, reseq_XP, ENSEMbl SP, ST, SG
# v4:  identifiers.B: reactome, refseq_NP, reseq_XP, ENSEMbl SP, ST, SG
# v5:  reactomeName.A: MTOR(name) (short and long)
# v6:  reactomeName.B: short and long (sometimes many aliases)
# v7:  method
# v8:  reference (author, year)
# v9:  pubmed id
# v10: taxid.A
# v11: taxid.B
# v12: interaction type: e.g., "physical association"
# v13: not sure, e.g, psi-mi:"MI:0467"(reactome)
# v14: complex
# v15: reactome-score
# v16: detection method?  e.g., "matrix expansion" in which coip are distributed across all pairs
# v17:
# v21: moleculeType.A  always protein?
# v22: moleculeType.B  always protein?
# v23: GO cellular component A?
# v24: GO cellular component B?
# v28: pathways
# x <- tbl.ppi[1,]
#----------------------------------------------------------------------------------------------------
digest.mitab <- function(tbl)
{
   coa <- c("uniprot.A",
            "uniprot.B",
            "alt.A",
            "alt.B",
            "alias.A",
            "alias.B",
            "detectionMethod",
            "firstAuthor",
            "pmid",
            "taxon.A",
            "taxon.B",
            "interactionType",
            "sourceDB",
            "complexIDs",
            "confidenceScore",
            "V16",
            "V17",
            "V18",
            "V19",
            "V20",
            "V21",
            "V22",
            "V23",
            "V24",
            "V25",
            "V26",
            "V27",
            "pathways",
            "V29",
            "V30",
            "V31",
            "V32",
            "V33",
            "V34",
            "V35",
            "V36",
            "V37",
            "V38",
            "V39",
            "V40",
            "V41",
            "V42")
   colnames(tbl.ppi) <- coa
   coi <- c("uniprot.A",
            "uniprot.B",
            "detectionMethod",
            "pmid",
            "interactionType",
            "complexIDs",
            "confidenceScore",
            "pathways")
   tbl <- tbl.ppi[, coi]
   tbl$organisms <- "Homo sapiens"
   tbl$compartment <- "cytosol"
   dim(tbl)
   tbl$uniprot.A <- sub("uniprotkb:", "", tbl$uniprot.A, fixed=TRUE)
   tbl$uniprot.B <- sub("uniprotkb:", "", tbl$uniprot.B, fixed=TRUE)
   tbl$detectionMethod <- gsub("psi.*\\((.*?)\\)", "\\1", tbl$detectionMethod)
   tbl$pmid <- sub("pubmed:", "", tbl$pmid, fixed=TRUE)
   tbl$interactionType <- gsub("psi.*\\((.*?)\\)", "\\1", tbl$interactionType)
   tbl$complexIDs <- gsub("reactome:", "", tbl$complexIDs, fixed=TRUE)
   tbl$confidenceScore <- as.numeric(gsub("reactome-score:", "", tbl$confidenceScore, fixed=TRUE))
   tbl$pathways <- gsub("pathway:", "", tbl$pathways, fixed=TRUE)

   tbl

} # digest.mitab
#----------------------------------------------------------------------------------------------------
# grep "R-HSA-165662" ../idMapping/reactome.homo_sapiens.interactions.psi-mitab.txt > R-HSA-165662.psi-mitab.txt
# this is an EWAS protein, "EntityWithAccessionedSequence", mTOR in the cytosol
test_digest.mitab <- function()
{
    f.interactions <- "R-HSA-165662.psi-mitab.txt"
    checkTrue(file.exists(f.interactions))
    tbl.ppi <- read.table(f.interactions, sep="\t", as.is=TRUE, nrow=-1, quote="")
    dim(tbl.ppi)
    tbl <- digest.mitab(tbl.ppi)
    checkEquals(dim(tbl), c(98, 10))

} # test_digest.mitab
#----------------------------------------------------------------------------------------------------
toGraph <- function(tbl)
{
   proteins <- unique(c(tbl$uniprot.A, tbl$uniprot.B))
   complexes <- unique(tbl$complexIDs)
   pathways <- unique(unlist(lapply(tbl$pathways, function(s){
       if(grepl("|", s, fixed=TRUE))
          return (strsplit(s, split="|", fixed=TRUE))
       return(s)
       })))
   length(proteins)   # 31
   length(complexes)  # 40
   length(pathways)   # 12

   tbl.nodes <- data.frame(id=c(proteins, complexes, pathways),
                           type=c(rep("protein", length(proteins)),
                                  rep("complex", length(complexes)),
                                  rep("pathway", length(pathways))),
                           stringsAsFactors=FALSE)

   tbl.edges.ppi <- data.frame(source=tbl$uniprot.A,
                               target=tbl$uniprot.B,
                               interaction=tbl$interactionType,
                               stringsAsFactors=FALSE)
   tbl.edges.complexes.1 <- data.frame(source=tbl$uniprot.A,
                                       target=tbl$complexIDs,
                                       interaction=rep("memberOfComplex", length(tbl$uniprot.A)),
                                       stringsAsFactors=FALSE)
   tbl.edges.complexes.2 <- data.frame(source=tbl$uniprot.B,
                                       target=tbl$complexIDs,
                                       interaction=rep("memberOfComplex", length(tbl$uniprot.B)),
                                       stringsAsFactors=FALSE)

   tbl.cpw <- unique(tbl[, c("complexIDs", "pathways")])
   # tbl.x <- head(tbl.cpw)
   pws.by.complex <- strsplit(tbl.cpw$pathways, "|", fixed=TRUE)
   names(pws.by.complex) <- tbl.cpw$complexIDs
   tbls.complexToPathway <- lapply(names(pws.by.complex), function(complexID){
      pathways <- pws.by.complex[[complexID]]
      data.frame(source=rep(complexID, length(pathways)),
                 target=pathways,
                 interaction="memberOrPathway",
                 stringsAsFactors=FALSE)})

   tbl.complexToPathway <- do.call(rbind, tbls.complexToPathway)

   tbl.edges <- rbind(tbl.edges.complexes.1, tbl.edges.complexes.2,
                      tbl.complexToPathway)

   noi <- c("P42345", "Q15382", "R-HSA-165678")
   tbl.edges.sub <- subset(tbl.edges, source %in% noi & target %in% noi)
   tbl.nodes.sub <- subset(tbl.nodes, id %in% noi)
   tbl.geneSymbols <- select(EnsDb.Hsapiens.v79,
                             key=tbl.nodes.sub$id,
                             keytype="UNIPROTID",
                             columns=c("SYMBOL"))
   tbl.nodes.sub$label <- tbl.nodes.sub$id  # the default


   g.json <- toJSON(dataFramesToJSON(tbl.edges.sub, tbl.nodes.sub))
   deleteGraph(rcy)
   addGraph(rcy, g.json)
   loadStyleFile(rcy, "cy-style.js")
   layout(rcy, "cose")
     # should more-or-less match layout seen in ./galactose_metabolism.svg
   restoreLayout(rcy, "galactoseMetabolism-layout.Rdata")
   fit(rcy)

} # toGraph
#----------------------------------------------------------------------------------------------------
assignNodeLabels <- function(ids)
{
   uniprot.ids <- grep("[PQO][0-9][0-9][0-9][0-9][0-9]", ids, v=TRUE)
   reactome.ids <- grep("R-HSA-", tail(ids), v=TRUE)

   uniprot.syms <- select(EnsDb.Hsapiens.v79, uniprot.ids, keytype="UNIPROTID", columns=c("SYMBOL"))

} # assignNodeLabels
#----------------------------------------------------------------------------------------------------
test_assignNodeLabels <- function()
{
   printf("--- test_assignNodeLabels")
   ids <- c("P42345", "Q15382", "R-HSA-165678", "R-HSA-165159")   # 2 proteins, complex and pathway
   checkEquals(assignNodeLabels("P42345"), "MTOR")

} # test_assignNodeLabels
#----------------------------------------------------------------------------------------------------
# pathway and complex labels (display names?). mtor signaling 165159
biopax <- function()
{
  filename <- "../xml/Homo_sapiens.owl"
  doc <- xmlParse(filename)
  length(getNodeSet(doc, "//bp:Pathway"))  # 2477
  getNodeSet(doc, "//bp:Pathway[@rdf:ID='Pathway2439']")  # 2477
  getNodeSet(doc, "//bp:Pathway[@rdf:ID='Pathway2439']//bp:displayName")  # 2477

   #   <bp:Pathway rdf:ID="Pathway2439">

} # # biopax
#----------------------------------------------------------------------------------------------------
# change second line of the sbml pathway file to read:
#   <sbml xmlns:sbml="http://www.sbml.org/sbml/level3/version1/core" level="3" version="1">
#              ^^^^^
# which makes parsing simply work.  don't really understand why
getSpecies <- function(pathwayID)
{
   doc <- xmlParse(sprintf("~/github/bio-gdb/reactome.mysql/xml/%s.sbml", pathwayID))
   count <- length(getNodeSet(doc, "//species"))
   tbl.species <- do.call(rbind , lapply(seq_len(count), function(i){
                      data.frame(id=as.character(getNodeSet(doc, sprintf("//species[%d]/@id", i))),
                      name=as.character(getNodeSet(doc, sprintf("//species[%d]/@name", i))),
                      stringsAsFactors=FALSE)}))
   tbl.species$id <- sub("species_", "R-HSA-", tbl.species$id)
   tokens <- strsplit(tbl.species$name, " \\[")
   tbl.species$name <- unlist(lapply(tokens, "[", 1))
   tbl.species$compartment <- sub("\\]", "", unlist(lapply(tokens, "[", 2)))

   tbl.species

} # getSpecies
#----------------------------------------------------------------------------------------------------
test_getSpecies <- function()
{
   tbl.species <- getSpecies("R-HSA-165159")
   save(tbl.species, file="tbl.species-R-HSA-165159.RData")


} # test_getSpecies
#----------------------------------------------------------------------------------------------------
