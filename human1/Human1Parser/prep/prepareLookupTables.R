library(XML)
library(RUnit)
filename <- "../inst/extdata/Human-GEM-noNamespaces.xml"
file.exists(filename)
doc <- xmlParse(filename)

#----------------------------------------------------------------------------------------------------
extractGeneProductMap = function(i)
{
   if((i %% 100) == 0) printf("extracting geneProduct entry %d", i)

   principal.id.path <- sprintf("//listOfGeneProducts/geneProduct[%d]/@id", i)
   principal.id <- as.character(getNodeSet(doc, principal.id.path))
   path <- sprintf("//listOfGeneProducts/geneProduct[%d]//li/@resource", i)
   id.uris <- as.character(getNodeSet(doc, path))
   hgnc <- grep("hgnc.symbol", id.uris)
   ensembl <- grep("ensembl", id.uris)
   uniprot <- grep("uniprot", id.uris)
   geneSymbol.id <- NA
   ensembl.id <- NA
   uniprot.id <- NA
   if(length(hgnc) == 1)
       geneSymbol.id <- strsplit(id.uris[hgnc], "/", fixed=TRUE)[[1]][5]
   if(length(ensembl) == 1)
       ensembl.id <- strsplit(id.uris[ensembl], "/", fixed=TRUE)[[1]][5]
   if(length(uniprot) == 1)
       uniprot.id <- strsplit(id.uris[uniprot], "/", fixed=TRUE)[[1]][5]
   data.frame(id=principal.id,
              geneSymbol=geneSymbol.id,
              ensembl=ensembl.id,
              uniprot=uniprot.id,
              stringsAsFactors=FALSE)

} # extractGeneProductMap
#----------------------------------------------------------------------------------------------------
run.extractGeneProductMap <- function()
{
   count <-  length(getNodeSet(doc, "//listOfGeneProducts/geneProduct"))
   printf("geneProductMap count: %d", count)
   maps <- lapply(seq_len(count), extractGeneProductMap)
   printf("id maps returned: %d", length(maps))
   tbl.geneProductIdMap <- do.call(rbind, maps)

} # run.extractGeneProductMap
#----------------------------------------------------------------------------------------------------
extractSpeciesMap = function(i)
{
   if((i %% 100) == 0) printf("extracting species entry %d", i)

   path <- sprintf("//listOfSpecies/species[%d]/@id", i)
   principal.id <- as.character(getNodeSet(doc, path))


   path <- sprintf("//listOfSpecies/species[%d]/@name", i)
   name <- as.character(getNodeSet(doc, path))

   path <- sprintf("//listOfSpecies/species[%d]/@compartment", i)
   compartment <- as.character(getNodeSet(doc, path))

   path <- sprintf("//listOfSpecies/species[%d]//li/@resource", i)
   id.uris <- as.character(getNodeSet(doc, path))
   bigg <- grep("bigg.metabolite", id.uris)
   kegg <- grep("kegg.compound", id.uris)
   chebi <- grep("CHEBI", id.uris)
   metanetx <- grep("metanetx", id.uris)

   bigg.id <- NA
   kegg.id <- NA
   chebi.id <- NA
   metanetx.id <- NA

   if(length(bigg) == 1)
       bigg.id <- strsplit(id.uris[bigg], "/", fixed=TRUE)[[1]][5]
   if(length(kegg) == 1)
       kegg.id <- strsplit(id.uris[kegg], "/", fixed=TRUE)[[1]][5]
   if(length(chebi) == 1)
       chebi.id <- strsplit(id.uris[chebi], "/", fixed=TRUE)[[1]][5]
   if(length(metanetx) == 1)
       metanetx.id <- strsplit(id.uris[metanetx], "/", fixed=TRUE)[[1]][5]
   data.frame(id=principal.id,
              name=name,
              compartment=compartment,
              bigg=bigg.id,
              kegg=kegg.id,
              chebi=chebi.id,
              metanetx=metanetx.id,
              stringsAsFactors=FALSE)

} # extractSpeciesMap
#----------------------------------------------------------------------------------------------------
test_extractSpeciesMap <- function()
{
    message(sprintf("--- test_extractSpeciesMap"))
    tbl <- extractSpeciesMap(1)
    checkTrue(is.data.frame(tbl))
    checkEquals(dim(tbl), c(1, 5))
    checkEquals(colnames(tbl), c("id", "bigg", "kegg", "chebi", "metanetx"))

} # test_extractSpeciesMap
#----------------------------------------------------------------------------------------------------
run.extractSpeciesMap <- function()
{
   count <-  length(getNodeSet(doc, "//listOfSpecies/species"))
   printf("speciesMap count: %d", count)
   maps <- lapply(seq_len(count), extractSpeciesMap)
   #maps <- lapply(seq_len(10), extractSpeciesMap)
   printf("id maps returned: %d", length(maps))
   tbl.speciesMap <- do.call(rbind, maps)
   browser()
   print(dim(tbl.speciesMap))
   out.file <- "~/github/bio-gdb/human1/Human1Parser/inst/extdata/tbl.speciesIdMap.RData"
   save(tbl.speciesMap, file=out.file)

} # run.extractSpeciesProductMap
#----------------------------------------------------------------------------------------------------
extractReactionMap = function(i)
{
   if((i %% 100) == 0) printf("extracting reaction entry %d", i)

   path <- sprintf("//listOfReactions/reaction[%d]/@id", i)
   principal.id <- as.character(getNodeSet(doc, path))

   path <- sprintf("//listOfReactions/reaction[%d]/@reversible", i)
   reversible <- as.logical(as.character(getNodeSet(doc, path)))

   path <- sprintf("//listOfReactions/reaction[%d]//li/@resource", i)
   id.uris <- as.character(getNodeSet(doc, path))

   ec <- grep("ec-code", id.uris)
   kegg <- grep("kegg", id.uris)
   bigg <- grep("bigg", id.uris)
   metanetx <- grep("metanetx", id.uris)

   ec.id <- NA
   bigg.id <- NA
   kegg.id <- NA
   metanetx.id <- NA

   if(length(ec) >= 1)
       ec.id <- paste(unlist(lapply(ec, function(id)  strsplit(id.uris[id], "/", fixed=TRUE)[[1]][5])),
                      collapse=";")
   if(length(bigg) == 1)
       bigg.id <- strsplit(id.uris[bigg], "/", fixed=TRUE)[[1]][5]
   if(length(kegg) == 1)
       kegg.id <- strsplit(id.uris[kegg], "/", fixed=TRUE)[[1]][5]
   if(length(metanetx) == 1)
       metanetx.id <- strsplit(id.uris[metanetx], "/", fixed=TRUE)[[1]][5]
   data.frame(id=principal.id,
              ec=ec.id,
              bigg=bigg.id,
              kegg=kegg.id,
              metanetx=metanetx.id,
              stringsAsFactors=FALSE)

} # extractReactionMap
#----------------------------------------------------------------------------------------------------
test_extractReactionMap <- function()
{
    message(sprintf("--- test_extractReactionMap"))
    tbl <- extractReactionMap(1)
    checkTrue(is.data.frame(tbl))
    checkEquals(dim(tbl), c(1, 5))
    checkEquals(colnames(tbl), c("id", "ec", "bigg", "kegg", "metanetx"))

} # test_extractReactionMap
#----------------------------------------------------------------------------------------------------
run.extractReactionMap <- function()
{
   count <-  length(getNodeSet(doc, "//listOfReactions/reaction")) # 13096
   printf("reactionMap count: %d", count)
   #count <- 10
   maps <- lapply(seq_len(count), extractReactionMap)
   #maps <- lapply(seq_len(10), extractReactionMap)
   printf("id maps returned: %d", length(maps))
   tbl.reactionMap <- do.call(rbind, maps)
   browser()
   print(dim(tbl.reactionMap))  # 13096 5
   out.file <- "~/github/bio-gdb/human1/Human1Parser/inst/extdata/tbl.reactionIdMap.RData"
   save(tbl.reactionMap, file=out.file)

} # run.extractReactionMap
#----------------------------------------------------------------------------------------------------
extractGroupMap <- function(i)
{
   if((i %% 100) == 0) printf("extracting group entry %d", i)

   path <- sprintf("//listOfGroups/group[%d]/@id", i)
   principal.id <- as.character(getNodeSet(doc, path))

   path <- sprintf("//listOfGroups/group[%d]/@name", i)
   name <- as.character(getNodeSet(doc, path))

   path <- sprintf("//listOfGroups/group[%d]//member/@idRef", i)
   members <- as.character(getNodeSet(doc, path))

   list(id=principal.id, name=name, members=members)

} # extractGroupMap
#----------------------------------------------------------------------------------------------------
test_extractGroupMap <- function()
{
    message(sprintf("--- test_extractGroupMap"))
    x <- extractGroupMap(1)
    checkTrue(is.list(x))
    checkEquals(names(x), c("id", "name", "members"))

} # test_extractGroupMap
#----------------------------------------------------------------------------------------------------
run.extractGroupMap <- function()
{
   count <-  length(getNodeSet(doc, "//listOfGroups/group")) # 142
   printf("groupMap count: %d", count)
   #count <- 10
   maps <- lapply(seq_len(count), extractGroupMap)
   #maps <- lapply(seq_len(10), extractGroupMap)
   printf("id maps returned: %d", length(maps))
   sum(unlist(lapply(maps, function(map) length(map$members)))) # [1] 13096: no dual group membership
   x <- lapply(maps, function(map) data.frame(reaction = map$members, group=map$id, name=map$name,
                                              stringsAsFactors=FALSE))
   tbl.groups <- do.call(rbind, x)
   dim(tbl.groups)   # 13096

   head(as.data.frame(sort(table(tbl.groups$name), decreasing=TRUE)))
     #                        Var1 Freq
     # 1       Transport reactions 4197
     # 2 Exchange/demand reactions 1656
     # 3           Drug metabolism  573
     # 4      Fatty acid oxidation  524
     # 5    Bile acid biosynthesis  264
     # 6        Peptide metabolism  242

   out.file <- "~/github/bio-gdb/human1/Human1Parser/inst/extdata/tbl.groups.RData"
   save(tbl.groups, file=out.file)

} # run.extractGroupMap
#----------------------------------------------------------------------------------------------------
extractCompartmentMap <- function(i)
{
   path <- sprintf("//listOfCompartments/compartment[%d]/@id", i)
   id <- as.character(getNodeSet(doc, path))
   path <- sprintf("//listOfCompartments/compartment[%d]/@name", i)
   name <- as.character(getNodeSet(doc, path))
   list(id=id, name=name)

} # extractCompartmentMap
#----------------------------------------------------------------------------------------------------
test_extractCompartmentMap <- function()
{
    message(sprintf("--- test_extractCompartmentMap"))
    x <- extractCompartmentMap(1)
    checkTrue(is.list(x))
    checkEquals(names(x), c("id", "name"))

} # test_extractCompartmentMap
#----------------------------------------------------------------------------------------------------
run.extractCompartmentMap <- function()
{
   count <-  length(getNodeSet(doc, "//listOfCompartments/compartment")) # 9
   printf("compartmentMap count: %d", count)
   maps <- lapply(seq_len(count), extractCompartmentMap)

   long.names <- as.list(unlist(lapply(maps, function(map) map[["name"]])))
   short.names <- unlist(lapply(maps, function(map) map[["id"]]))
   names(long.names) <- short.names
   compartments.map <- long.names

   out.file <- "~/github/bio-gdb/human1/Human1Parser/inst/extdata/compartments.RData"
   save(compartments.map, file=out.file)

} # run.extractCompartmentMap
#----------------------------------------------------------------------------------------------------
