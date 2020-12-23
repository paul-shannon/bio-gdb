library(Human1Parser)
library(RUnit)
library(RCyjs)
library(EnsDb.Hsapiens.v79)
library(later)
#------------------------------------------------------------------------------------------------------------------------
filename <- "../extdata/nons.xml"
filename <- "../extdata/Human-GEM-noNamespaces.xml"
hp <- Human1Parser$new(filename)

#------------------------------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_ctor()
   test_counts()
   test_getCompartment()
   test_getReaction()
   test_getSpecies()
   test_getGroups()
   test_getEdgeAndNodeTables()

} # runTests
#------------------------------------------------------------------------------------------------------------------------
test_ctor <- function()
{
   message(sprintf("--- test_ctor"))
   checkTrue("Human1Parser" %in% class(hp))

} # test_ctor
#------------------------------------------------------------------------------------------------------------------------
test_counts <- function()
{
   message(sprintf("--- test_counts"))
   counts <- hp$getCounts()
  checkTrue(all(c("compartments", "geneProducts", "groups", "reactions", "species") %in% names(counts)))
   checkEquals(counts$reactions, 13096)
   checkEquals(counts$species, 8400)
   checkEquals(counts$compartments, 9)
   checkEquals(counts$geneProducts, 3626)
   checkEquals(counts$groups, 142)

} # test_counts
#------------------------------------------------------------------------------------------------------------------------
test_getCompartment <- function()
{
   message(sprintf("--- test_getCompartment"))

   checkEquals(hp$getCompartment("s"),  "Extracellular")
   checkEquals(hp$getCompartment("p"),  "Peroxisome")
   checkEquals(hp$getCompartment("m"),  "Mitochondria")
   checkEquals(hp$getCompartment("c"),  "Cytosol")
   checkEquals(hp$getCompartment("l"),  "Lysosome")
   checkEquals(hp$getCompartment("r"),  "Endoplasmic reticulum")
   checkEquals(hp$getCompartment("g"),  "Golgi apparatus")
   checkEquals(hp$getCompartment("n"),  "Nucleus")
   checkEquals(hp$getCompartment("c_i"), "Inner mitochondria")
   checkTrue(is.na(hp$getCompartment("")))
   checkTrue(is.na(hp$getCompartment("x")))
   checkTrue(is.na(hp$getCompartment("bogus")))

} # test_getCompartment
#------------------------------------------------------------------------------------------------------------------------
# the drug acarbose inhibits this reaction, making it interesting to longevity researchers
test_getReaction <- function()
{
   message(sprintf("--- test_getReaction"))

   r <- hp$getReaction(8531)
   checkTrue(all(c("reaction", "reactionRefs", "reactants", "products", "genes") %in% names(r)))
   checkEquals(r$reaction$id, "R_O16G1e")
   # checkEquals(r$reaction$name, "Oligo-1, 6-Glucosidase (Glygn4 -> Glygn5), Extracellular")
   tbl.refs <- r$reactionRefs
   checkEquals(dim(tbl.refs), c(3, 2))
   checkEquals(sort(tbl.refs$value), c("3.2.1.10", "MNXR102083","O16G1e"))
   checkEquals(r$reactants$species, c("M_m02040s", "M_glygn4_s"))
   checkEquals(r$products$species, c("M_m01965s", "M_glygn5_s"))
   checkEquals(r$genes, "ENSG00000090402")

   r2 <- hp$getReaction("R_O16G1e")
   checkTrue(all(c("reaction", "reactionRefs", "reactants", "products", "genes") %in% names(r2)))
   checkEquals(r2$reaction$id, "R_O16G1e")
   # checkEquals(r$reaction$name, "Oligo-1, 6-Glucosidase (Glygn4 -> Glygn5), Extracellular")
   tbl.refs <- r2$reactionRefs
   checkEquals(dim(tbl.refs), c(3, 2))
   checkEquals(sort(tbl.refs$value), c("3.2.1.10", "MNXR102083","O16G1e"))
   checkEquals(r2$reactants$species, c("M_m02040s", "M_glygn4_s"))
   checkEquals(r2$products$species, c("M_m01965s", "M_glygn5_s"))
   checkEquals(r2$genes, "ENSG00000090402")

} # test_getReaction
#------------------------------------------------------------------------------------------------------------------------
# M_m01965s, extracellular glucose C6H12O6
test_getSpecies <- function()
{
   message(sprintf("--- test_getSpecies"))

   r <- hp$getSpecies(3359)
   checkEquals(sort(names(r)), c("species", "speciesRefs"))
   checkEquals(r$species$id, "M_m01965s")
   checkEquals(r$species$name, "glucose")
   checkEquals(r$species$compartment, "s")  # extracellular
   checkEquals(r$species$chemicalFormula, "C6H12O6")
   checkTrue(all(c("bigg.metabolite", "kegg.compound", "hmdb", "chebi", "pubchem.compound", "metanetx.chemical", "metanetx.chemical")
                 %in% r$speciesRefs$ref))
   checkTrue(all(c("glc__D", "C00031", "HMDB00122", "CHEBI:4167", "5793", "MNXM41", "MNXM99") %in% r$speciesRefs$value))

} # test_getSpecies
#------------------------------------------------------------------------------------------------------------------------
# M_m01965s, extracellular glucose C6H12O6
test_getGroups <- function()
{
   message(sprintf("--- test_getGroups"))

   tbl.groups <- hp$getGroupsMap()
   tbl.distribution <- as.data.frame(sort(table(tbl.groups$name)))
   colnames(tbl.distribution) <- c("groupName", "count")
   checkEquals(subset(tbl.distribution, groupName == "Glycolysis / Gluconeogenesis")$count, 41)
   checkEquals(subset(tbl.distribution, groupName == "Bile acid biosynthesis")$count, 264)

} # test_getGroups
#------------------------------------------------------------------------------------------------------------------------
test_getEdgeAndNodeTables <- function()
{
    message(sprintf("--- test_toEdgeAndNodeTables"))
     # 17: phosphopyruvate hydratase, 1 reactant, 2 products 3 catalyzers
     #  eno1, eno3, eno2
    reactionNumber <- 17
    x <- hp$getEdgeAndNodeTables(reactionNumber, excludeUbiquitousSpecies=TRUE, includeComplexMembers=TRUE)
    checkTrue(is.list(x))
    checkEquals(names(x), c("edges", "nodes"))
    checkTrue(all(unlist(lapply(x, is.data.frame))))
    checkTrue(all(c("reactantFor", "produces", "catalyzes") %in% x$edges$interaction))
    checkEquals(colnames(x$edges), c("source", "target", "interaction"))
    checkEquals(unique(as.character(lapply(x$edges, class))), "character")

} # test_toEdgeAndNodeTables
#------------------------------------------------------------------------------------------------------------------------
displayReaction <- function(i, exclude=TRUE, deleteExistingGraph=TRUE, includeComplexMembers=FALSE)
{
   if(!exists("rcy")){
      rcy <<- RCyjs()
      setBrowserWindowTitle(rcy, "Human1")
      }

   reactionNumber <- 8531 #
   reactionNumber <- 1
   reactionNumber <- 2
   x <- hp$getEdgeAndNodeTables(reactionNumber, excludeUbiquitousSpecies=TRUE, includeComplexMembers=TRUE)

   g.json <- toJSON(dataFramesToJSON(x$edges, x$nodes))

   if(deleteExistingGraph)
      deleteGraph(rcy)

   addGraph(rcy, g.json)
   later(function(){
      #setBrowserWindowTitle(rcy, sprintf("%d: %s", i, parser$getName()))
      loadStyleFile(rcy, "style.js")
      layout(rcy, "cose-bilkent")
      fit(rcy)
      }, 2)

} # displayReaction
#------------------------------------------------------------------------------------------------------------------------
displayManyReactions <- function(r.many)
{
   if(!exists("rcy")){
      rcy <<- RCyjs()
      setBrowserWindowTitle(rcy, "Human1")
      }

   for(r in r.many){
     r <- hp$getReaction(r)
     x <- hp$getEdgeAndNodeTables(r, excludeUbiquitousSpecies=TRUE, includeComplexMembers=TRUE)
     g.json <- toJSON(dataFramesToJSON(x$edges, x$nodes))
     addGraph(rcy, g.json)
     }

   later(function(){
      #setBrowserWindowTitle(rcy, sprintf("%d: %s", i, parser$getName()))
      loadStyleFile(rcy, "style.js")
      layout(rcy, "cose-bilkent")
      fit(rcy)
      }, 2)

} # displayManyReactions
#------------------------------------------------------------------------------------------------------------------------
displayGlycolysisGlucogenesis <- function()
{
   tbl.groups <- hp$getGroupsMap()
   reactions <- subset(tbl.groups, name=="Glycolysis / Gluconeogenesis")$reaction
   checkEquals(length(reactions), 41)
   colnames(tbl.distribution) <- c("groupName", "count")

   displayManyReactions(reactions[1:3])

} # displayGlycolysisGlucogenesis
#------------------------------------------------------------------------------------------------------------------------
if(!interactive())
    runTests()
