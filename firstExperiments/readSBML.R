library(XML)
library(RUnit)
#--------------------------------------------------------------------------------------------------------------
filename <- "./Human-GEM-noNamespaces.xml"
# doc <- xmlTreeParse(filename, getDTD = FALSE)
doc <- xmlParse(filename)
#--------------------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_counts()
   test_readCompartment()
   test_readSpecies()
   test_readReaction()
   test_readGroup()
   test_readGene()

} # runTests
#--------------------------------------------------------------------------------------------------------------
test_counts <- function()
{
   message(sprintf("--- test_counts"))

   model <- xmlRoot(doc)[["model"]]
   names(xmlChildren(model))

      # the length of these elements is probably unchanging

   checkEquals(length(xmlChildren(model[["notes"]])), 1)
   checkEquals(length(xmlChildren(model[["annotation"]])), 1)
   checkEquals(length(xmlChildren(model[["listOfUnitDefinitions"]])), 1)
   checkEquals(length(xmlChildren(model[["listOfCompartments"]])), 9)
   checkEquals(length(xmlChildren(model[["listOfParameters"]])), 3)
   checkEquals(length(xmlChildren(model[["listOfObjectives"]])), 1)

   checkTrue(length(xmlChildren(model[["listOfSpecies"]])) >= 8400)
   checkTrue(length(xmlChildren(model[["listOfReactions"]])) >= 13096)
   checkTrue(length(xmlChildren(model[["listOfGeneProducts"]])) >= 3626)
   checkTrue(length(xmlChildren(model[["listOfGroups"]])) >= 142)

} # test_counts
#--------------------------------------------------------------------------------------------------------------
readCompartment <- function(i, quiet=TRUE)
{
   if(!quiet) printf("readGroup(%d)", i)

   compartment <- getNodeSet(doc, sprintf("(//compartment)[%d]", i))

   compartment.asList <- as.list(xmlAttrs(compartment[[1]]))
   tbl.compartment <- with(compartment.asList,
                           data.frame(id=id,
                                      name=name,
                                      spatialDimensions=spatialDimensions,
                                      size=size,
                                      constant=constant,
                                      sboTerm=sboTerm,
                                      stringsAsFactors=FALSE))

   tbl.compartment

} # readCompartment
#--------------------------------------------------------------------------------------------------------------
test_readCompartment <- function()
{
   message(sprintf("--- test_readCompartment"))

   tbl <- readCompartment(1)
   checkEquals(dim(tbl), c(1, 6))
   checkEquals(colnames(tbl), c("id", "name", "spatialDimensions", "size", "constant", "sboTerm"))

} # test_readCompartment
#--------------------------------------------------------------------------------------------------------------
readSpecies <- function(n, quiet=TRUE)
{
  if(!quiet) printf("readSpecies(%d)", n)

  species <- getNodeSet(doc, sprintf("(//species)[%d]", n))
  speciesAsList <- as.list(xmlAttrs(species[[1]]))

  id <- speciesAsList[["id"]]
  name <- speciesAsList[["name"]]
  compartment <- speciesAsList[["compartment"]]
  chemicalFormula <- ""
  if("chemicalFormula" %in% names(speciesAsList))   # sometimes (rarely) missing
    chemicalFormula <- speciesAsList[["chemicalFormula"]]

  tbl.species <- data.frame(id=id,
                            name=name,
                            compartment=compartment,
                            chemicalFormula=chemicalFormula,
                            stringsAsFactors=FALSE)
  annotation <- getNodeSet(doc, sprintf("(//species)[%d]/annotation/*/*/*/*/li", n))
  external.ids <- as.character(lapply(annotation, xmlAttrs))
  external.ids <- sub("http://identifiers.org/", "", external.ids)
     # <li resource="http://identifiers.org/ec-code/1.1.1.1"/>
     # <li resource="http://identifiers.org/ec-code/1.1.1.71"/>
     # <li resource="http://identifiers.org/kegg.reaction/R00754"/>
     # <li resource="http://identifiers.org/bigg.reaction/ALCD2x"/>
     # <li resource="http://identifiers.org/metanetx.reaction/MNXR95725"/>
  tokens <- strsplit(external.ids, "/", fixed=TRUE)
  tbl.refs <- data.frame();

  for(token in tokens)
    tbl.refs <- rbind(tbl.refs, data.frame(ref=token[1], value=token[2], stringsAsFactors=FALSE))

  return(list(
      species=tbl.species,
      speciesRefs=tbl.refs)
      )

} # readSpecies
#--------------------------------------------------------------------------------------------------------------
test_readSpecies <- function()
{
   message(sprintf("--- test_readSpecies"))

   x <- readSpecies(1)
   checkEquals(names(x), c("species", "speciesRefs"))
   checkTrue(all(unlist(lapply(x, is.data.frame))))
   tbl.species <- x$species
   checkEquals(dim(tbl.species), c(1, 4))
   tbl.refs <- x$speciesRefs
   checkEquals(dim(tbl.refs), c(4, 2))

     #------------------------------------------------------------
     # a number of minimally annotated species are found near
     # the end of ths set.  and used in reactions.  make sure
     # we handle them, however useless they appear to be
     #------------------------------------------------------------

   chemicalFormulaMissing <- 8314
   x <- readSpecies(chemicalFormulaMissing)
   checkEquals(x$species$id, "M_m10000s")
   checkEquals(x$species$name, "others")
   checkEquals(x$species$chemicalFormula, "")

   xx <- lapply(1:40, function(n) readSpecies(n))
   species.ids <- unlist(lapply(xx, function(x) x$species$id))
   checkEquals(length(species.ids), length(unique(species.ids)))
   checkEquals(length(grep("M_", species.ids)), 40)

   xx.late <- lapply(8300:8400, function(n) readSpecies(n))
   species.ids <- unlist(lapply(xx.late, function(x) x$species$id))
   checkEquals(length(species.ids), length(unique(species.ids)))
   checkEquals(length(grep("M_", species.ids)), 101)

} # test_readSpecies
#--------------------------------------------------------------------------------------------------------------
#  doc <- xmlParse("./Human-GEM-noNamespaces.xml")
readReaction <- function(n, quiet=TRUE)
{
  if(!quiet) printf("readReaction(%d)", n)

  reaction <- getNodeSet(doc, sprintf("(//reaction)[%d]", n))
  tbl.reaction <- with(as.list(xmlAttrs(reaction[[1]])),
                       data.frame(id=id, reversible=reversible, fast=fast,
                                  lowerFluxBound=lowerFluxBound,
                                  upperFluxBound=upperFluxBound,
                                  stringsAsFactors=FALSE))

   #       metaid        sboTerm             id     reversible           fast lowerFluxBound  upperFluxBound
   #  "R_HMR_3905"  "SBO:0000176"   "R_HMR_3905"        "false"        "false"        "FB2N0"    "FB3N1000"

  annotation <- getNodeSet(doc, sprintf("(//reaction)[%d]/annotation/*/*/*/*/li", n))
  external.ids <- as.character(lapply(annotation, xmlAttrs))
  external.ids <- sub("http://identifiers.org/", "", external.ids)
     # <li resource="http://identifiers.org/ec-code/1.1.1.1"/>
     # <li resource="http://identifiers.org/ec-code/1.1.1.71"/>
     # <li resource="http://identifiers.org/kegg.reaction/R00754"/>
     # <li resource="http://identifiers.org/bigg.reaction/ALCD2x"/>
     # <li resource="http://identifiers.org/metanetx.reaction/MNXR95725"/>
  tokens <- strsplit(external.ids, "/", fixed=TRUE)
  tbl.refs <- data.frame();

  for(token in tokens)
    tbl.refs <- rbind(tbl.refs, data.frame(ref=token[1], value=token[2], stringsAsFactors=FALSE))

  reactants <- getNodeSet(doc, sprintf("(//reaction)[%d]/listOfReactants/speciesReference", n))
  tbls.reactants <- lapply(reactants, function(reactant) {
      attrs <- xmlAttrs(reactant)
      with(as.list(attrs),
                   data.frame(species=species, stoichiometry=stoichiometry, constant=constant,
                              stringsAsFactors=FALSE))
      })
  tbl.reactants <- do.call(rbind, tbls.reactants)

  products  <- getNodeSet(doc, sprintf("(//reaction)[%d]/listOfProducts/speciesReference", n))
  tbls.products <- lapply(products, function(product) {
      attrs <- xmlAttrs(product)
      with(as.list(attrs),
                   data.frame(species=species, stoichiometry=stoichiometry, constant=constant,
                              stringsAsFactors=FALSE))
      })
  tbl.products <- do.call(rbind, tbls.products)


    # todo: distinguish "and" genes from "or" genes from single-item geneProductRef

  genes.raw.chosen  <- getNodeSet(doc, sprintf("(//reaction)[%d]/geneProductAssociation//geneProductRef", n))
  printf(" reaction %d,    genes found: %d", n, length(genes.raw.chosen))
  #genes.raw.simple  <- getNodeSet(doc, sprintf("(//reaction)[%d]/geneProductAssociation/geneProductRef", n))
  #genes.raw.and     <- getNodeSet(doc, sprintf("(//reaction)[%d]/geneProductAssociation/and/geneProductRef", n))
  #genes.raw.or      <- getNodeSet(doc, sprintf("(//reaction)[%d]/geneProductAssociation/or/geneProductRef", n))
  #genes.raw.allPossibilities <- list(genes.raw.simple, genes.raw.and, genes.raw.or)
  #good.genes.raw <- which(unlist(lapply(genes.raw.allPossibilities, function(x) length(x) > 0)))
  #genes.raw.chosen  <- genes.raw.allPossibilities[[good.genes.raw]]


  genes <- unlist(lapply(genes.raw.chosen, function(gene) {
      attrs <- xmlAttrs(gene)
      attrs[["geneProduct"]]
      }))

  return(list(
      reaction=tbl.reaction,
      reactionRefs=tbl.refs,
      reactants=tbl.reactants,
      products=tbl.products,
      genes=genes
      ))

} # readReaction
#--------------------------------------------------------------------------------------------------------------
test_readReaction <- function()
{
   message(sprintf("--- test_readReaction"))

   x.1 <- readReaction(1)   # has 9 "or" associated geneAssocation
   x.2 <- readReaction(2)   # has just 1
   x.85 <- readReaction(85) # has none

   checkEquals(length(x.1$genes), 9)
   checkEquals(length(x.2$genes), 1)
   checkEquals(length(x.85$genes), 0)

   x <- x.1
   checkEquals(names(x), c("reaction", "reactionRefs", "reactants", "products", "genes"))

   checkTrue(is.data.frame(x$reaction))
   checkEquals(colnames(x$reaction), c("id", "reversible", "fast", "lowerFluxBound", "upperFluxBound"))
   checkEquals(dim(x$reaction), c(1, 5))

   checkTrue(is.data.frame(x$reactionRefs))
   checkEquals(colnames(x$reactionRefs), c("ref", "value"))
   checkEquals(dim(x$reactionRefs), c(5, 2))

   checkTrue(is.data.frame(x$reactants))
   checkEquals(colnames(x$reactants), c("species","stoichiometry", "constant"))
   checkEquals(dim(x$reactants), c(2, 3))

   checkTrue(is.data.frame(x$products))
   checkEquals(colnames(x$products), c("species","stoichiometry", "constant"))
   checkEquals(dim(x$products), c(3, 3))

   checkTrue(is.character(x$genes))
   checkEquals(length(x$genes), 9)
   checkTrue(all(grepl("^ENSG", x$genes)))

} # test_readReaction
#--------------------------------------------------------------------------------------------------------------
readGroup <- function(n, quiet=TRUE)
{
  if(!quiet) printf("readGroup(%d)", n)

  group <- getNodeSet(doc, sprintf("(//group)[%d]", n))
  tbl.group <- with(as.list(xmlAttrs(group[[1]])),
                    data.frame(id=id,
                               name=name,
                               kind=kind,
                               sboTerm=sboTerm,
                               stringsAsFactors=FALSE))
  members.raw  <- getNodeSet(doc, sprintf("(//group)[%d]/listOfMembers/member", n))
  memberReactions <- unlist(lapply(members.raw, function(member) {
      attrs <- xmlAttrs(member)
      attrs[["idRef"]]
      }))

  return(list(
      group=tbl.group,
      members=sort(memberReactions)
      ))

} # readGroup
#--------------------------------------------------------------------------------------------------------------
test_readGroup <- function()
{
   message(sprintf("--- test_readGroup"))

   x <- readGroup(1)
   checkEquals(names(x), c("group", "members"))
   checkTrue(is.data.frame(x$group))
   checkEquals(dim(x$group), c(1, 4))
   checkEquals(colnames(x$group), c("id", "name", "kind", "sboTerm"))
   checkTrue(all(grepl("R_H", x$members)))
   checkTrue(length(x$members) > 60)
   checkTrue(length(x$members) < 80)

} # test_readGroup
#--------------------------------------------------------------------------------------------------------------
readGene <- function(n, quiet=TRUE)
{
  if(!quiet) printf("readGene(%d)", n)

  gene <- getNodeSet(doc, sprintf("(//geneProduct)[%d]", n))
  tbl.gene <- with(as.list(xmlAttrs(gene[[1]])),
                    data.frame(id=id,
                               name=label,
                               sboTerm=sboTerm,
                               stringsAsFactors=FALSE))
  resources <- getNodeSet(doc, sprintf("(//geneProduct)[%d]/*/*/*/*/*/li", n))
  external.ids <- as.character(lapply(resources, xmlAttrs))
  external.ids <- sub("http://identifiers.org/", "", external.ids)
     # <li resource="http://identifiers.org/ec-code/1.1.1.1"/>
     # <li resource="http://identifiers.org/ec-code/1.1.1.71"/>
     # <li resource="http://identifiers.org/kegg.reaction/R00754"/>
     # <li resource="http://identifiers.org/bigg.reaction/ALCD2x"/>
     # <li resource="http://identifiers.org/metanetx.reaction/MNXR95725"/>
  tokens <- strsplit(external.ids, "/", fixed=TRUE)
  tbl.refs <- data.frame();

  for(token in tokens)
    tbl.refs <- rbind(tbl.refs, data.frame(ref=token[1], value=token[2], stringsAsFactors=FALSE))

  return(list(
      gene=tbl.gene,
      refs=tbl.refs
      ))

} # readGene
#--------------------------------------------------------------------------------------------------------------
test_readGene <- function()
{
   message(sprintf("--- test_readGene"))

   x <- readGene(1)
   checkEquals(names(x), c("gene", "refs"))
   checkTrue(all(unlist(lapply(x, is.data.frame))))
   checkEquals(colnames(x$gene), c("id", "name", "sboTerm"))
   checkEquals(nrow(x$gene), 1)
   checkEquals(colnames(x$refs), c("ref", "value"))
   checkEquals(nrow(x$refs), 4)
   checkEquals(sort(c("hgnc.symbol", "ensembl", "ncbigene", "uniprot")), sort(x$refs$ref))

   set.seed(37)
   x <- lapply(sample(1:1000, 10), readGene)


} # test_readGene
#--------------------------------------------------------------------------------------------------------------
extractAll <- function()
{
   model <- xmlRoot(doc)[["model"]]

      #-----------------
      # compartments
      #-----------------

   compartmentCount <- length(xmlChildren(model[["listOfCompartments"]]))
   x <- lapply(seq_len(compartmentCount), readCompartment)
   tbl.compartment <- do.call(rbind, x)
   checkEquals(dim(tbl.compartment), c(9, 6))
   save(x, file="compartments.RData")

      #-----------------
      # species
      #-----------------

   speciesCount <- length(xmlChildren(model[["listOfSpecies"]]))
   x <- lapply(seq_len(speciesCount), function(i) readSpecies(i, quiet=FALSE))
   save(x, file="species.RData")

      #-----------------
      # reactions
      #-----------------

   reactionCount <- length(xmlChildren(model[["listOfReactions"]]))
   printf("reading %d reactions", reactionCount)
   x <- lapply(seq_len(reactionCount), function(i) readReaction(i, quiet=FALSE))
   save(x, file="reactions.RData")

      #-----------------------------------------------------------------
      # genes (proteins, referenced via the genes which code for them)
      #-----------------------------------------------------------------

   geneCount <- length(xmlChildren(model[["listOfGeneProducts"]]))
   printf("reading %d genes", geneCount)
   x <- lapply(seq_len(geneCount), function(i) readGene(i, quiet=FALSE))
   save(x, file="genes.RData")

      #----------------------------------
      # groups (pathways, more or less
      #-----------------------------------

   groupCount <- length(xmlChildren(model[["listOfGroups"]]))
   printf("reading %d groups", groupCount)
   x <- lapply(seq_len(groupCount), function(i) readGroup(i, quiet=FALSE))
   save(x, file="groups.RData")

} # extractAll
#--------------------------------------------------------------------------------------------------------------
