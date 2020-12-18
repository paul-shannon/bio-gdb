library(PathwayParser)
library(RUnit)
library(RCyjs)
library(EnsDb.Hsapiens.v79)
library(later)
#------------------------------------------------------------------------------------------------------------------------
# 2nd reaction to test, #3
#   <reaction compartment="compartment_17938"  id="reaction_165718"
#      name="mTORC1 phosphorylation of RPS6KB1 (S6K)" reversible="false">
#------------------------------------------------------------------------------------------------------------------------
if(!exists("doc")){
   file <- "../extdata/R-HSA-165159.sbml"
   stopifnot(file.exists(file))
   text <- paste(readLines(file), collapse="\n")
   checkTrue(nchar(text) > 300000)   # 315493
   doc <- read_xml(text)
   xml_ns_strip(doc)
   }

#------------------------------------------------------------------------------------------------------------------------
# note that the whole docuent is returned, but some mysterious internal state records
# the selection made here.  good to check this by calling xml_path, which should
# return /sbml/model/listOfReactions/reaction[i]
getReactionForTesting <- function(i)
{
    xml_find_all(doc, sprintf("//reaction[%d]", i))

} # getReactionForTesting
#------------------------------------------------------------------------------------------------------------------------
if(!exists("reaction"))
   reaction <- getReactionForTesting(5) #    # "FKBP1A binds sirolimus"
if(!exists("parser"))
   parser <- ReactionParser$new(doc, reaction)
#------------------------------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_ctor()
   test_getReactants()
   test_getProducts()
   test_getModifiers()
   test_molecularSpeciesMap()
   test_eliminateUbiquitiousSpecies()
   test_toEdgeAndNodeTables()

} # runTests
#------------------------------------------------------------------------------------------------------------------------
test_ctor <- function()
{
   message(sprintf("--- test_ctor"))
   checkEquals(xml_path(reaction), "/sbml/model/listOfReactions/reaction[5]")

   checkEquals(parser$getXPath(), "/sbml/model/listOfReactions/reaction[5]")
   checkEquals(parser$getID(), "reaction_9679044")
   checkEquals(parser$getName(), "FKBP1A binds sirolimus")
   checkEquals(parser$getCompartment(), "compartment_70101")
   notes <- parser$getNotes()
   checkTrue(nchar(notes) > 1100)
   checkEquals(substring(notes, 1, 33), "Sirolimus is a macrolide compound")

} # test_ctor
#------------------------------------------------------------------------------------------------------------------------
test_getReactants <- function()
{
   message(sprintf("--- test_getReactants"))
   checkEquals(parser$getReactantCount(), 2)
   checkEquals(sort(parser$getReactants()), sort(c("species_2026007", "species_9678687")))

} # test_getReactants
#------------------------------------------------------------------------------------------------------------------------
test_getProducts <- function()
{
   message(sprintf("--- test_getProducts"))
   checkEquals(parser$getProductCount(), 1)
   checkEquals(sort(parser$getProducts()), "species_9679098")

} # test_getProducts
#------------------------------------------------------------------------------------------------------------------------
# reaction 2 in mTOR signaling hsa a modifier
#   "Phosphorylation and activation of eIF4B by activated S6K1"
# make sure we can find it here
test_getModifiers <- function()
{
   message(sprintf("--- test_getModifiers"))

   reaction.2 <- getReactionForTesting(2)
   parser.2 <- ReactionParser$new(doc, reaction.2)
   checkEquals(parser.2$getModifierCount(), 1)
   checkEquals(sort(parser.2$getModifiers()), "species_165714")

     # get the name - though it is an awkward one, not the simple "S6K1" we'd like
     # wikipedia:
     #   Ribosomal protein S6 kinase beta-1 (S6K1),
     #   also known as p70S6 kinase (p70S6K, p70-S6K)
     #   The phosphorylation of p70S6K at threonine 389 has been used as a hallmark of activation
     #   by mTOR and correlated with autophagy inhibition in various situations. However, several
     # recent studies suggest that the activity of p70S6K plays a more positive role in the increase
     # of autophagy.

   map <- parser.2$getMolecularSpeciesMap()
   checkEquals(map[["species_165714"]]$name, "p-S371,T389-RPS6KB1")
   checkEquals(map[["species_165714"]]$moleculeType, "molecule")
   checkEquals(map[["species_165714"]]$compartment, "cytosol")
   checkTrue(is.null(map[["species_165714"]]$members))

} # test_getProducts
#------------------------------------------------------------------------------------------------------------------------
test_molecularSpeciesMap <- function()
{
   message(sprintf("--- test_molecularSpeciesMap"))
   x <- parser$getMolecularSpeciesMap()
   checkTrue(is.list(x))
   checkEquals(length(x), 66)
   moleculeTypes <- unlist(lapply(x, "[", "moleculeType"))
   counts <- as.list(table(moleculeTypes))

   checkEquals(counts$complex, 30)
   checkEquals(counts$molecule, 36)

} # test_getProducts
#------------------------------------------------------------------------------------------------------------------------
test_toEdgeAndNodeTables <- function()
{
   message(sprintf("--- test_toEdgeAndNodeTables"))
      # user reaction 2 in R-HSA-165159.sbml: 1 each of reactant, product, modifier
   reaction.2 <- getReactionForTesting(2)
   parser.tmp <- ReactionParser$new(doc, reaction.2)
   checkEquals(parser.tmp$getReactantCount(), 2)
   checkEquals(parser.tmp$getProductCount(), 2)
   checkEquals(parser.tmp$getModifierCount(), 1)
   checkEquals(sort(parser.tmp$getModifiers()), "species_165714")

   x <- parser.tmp$toEdgeAndNodeTables()
   checkEquals(sort(names(x)), c("edges", "nodes"))

   checkEquals(dim(x$nodes), c(4, 3))
   checkTrue("species_165714" %in% x$nodes$id)
   checkTrue("p-S371,T389-RPS6KB1" %in% x$nodes$label)

     # keep in mind that excludeUbiquitousSpecies is default TRUE
   checkEquals(dim(x$edges), c(3, 3))
   checkEquals(x$edges[3, "source"], "species_165714")
   checkEquals(x$edges[3, "target"], "reaction_165777")
   checkEquals(x$edges[3, "interaction"], "modifies")

      # now get all species, including water, atp, adp if present
   x <- parser.tmp$toEdgeAndNodeTables(excludeUbiquitousSpecies=FALSE)
   checkEquals(sort(names(x)), c("edges", "nodes"))

   checkEquals(dim(x$nodes), c(6, 3))
   checkTrue(all(c("ATP", "ADP") %in% x$nodes$label))

     # keep in mind that excludeUbiquitousSpecies is default TRUE
   checkEquals(dim(x$edges), c(5, 3))

} # test_toEdgeAndNodeTables
#------------------------------------------------------------------------------------------------------------------------
renderReaction <- function()
{
   x <- parser$toEdgeAndNodeTables()
   g.json <- toJSON(dataFramesToJSON(x$edges, x$nodes))
   deleteGraph(rcy)
   addGraph(rcy, g.json)
   loadStyleFile(rcy, "style.js")
   layout(rcy, "cose")
   fit(rcy)

} # renderReaction
#------------------------------------------------------------------------------------------------------------------------
test_reaction_1 <- function()
{
   message(sprintf("--- test_reaction_1"))
   reaction <- getReactionForTesting(1) #    # "FKBP1A binds sirolimus"
   parser <- ReactionParser$new(doc, reaction)
   x <- parser$toEdgeAndNodeTables()

   g.json <- toJSON(dataFramesToJSON(x$edges, x$nodes))
   deleteGraph(rcy)
   addGraph(rcy, g.json)
   loadStyleFile(rcy, "style.js")
   layout(rcy, "cose")
   fit(rcy)

} # test_reaction_1
#------------------------------------------------------------------------------------------------------------------------
test_eliminateUbiquitiousSpecies <- function()
{
   message(sprintf("--- test_eliminateUbiquitousSpecies"))

   reaction <- getReactionForTesting(3) #    # "FKBP1A binds sirolimus"
   parser <- ReactionParser$new(doc, reaction)
   x <- parser$toEdgeAndNodeTables(excludeUbiquitousSpecies=FALSE)
   checkEquals(nrow(x$nodes), 5)
   checkEquals(nrow(x$edges), 4)

   x <- parser$toEdgeAndNodeTables(excludeUbiquitousSpecies=TRUE)
   checkEquals(nrow(x$nodes), 3)
   checkEquals(nrow(x$edges), 2)

   x <- parser$toEdgeAndNodeTables()
   checkEquals(nrow(x$nodes), 3)
   checkEquals(nrow(x$edges), 2)

} # test_eliminateUbiquitousSpecies
#------------------------------------------------------------------------------------------------------------------------
displayReaction <- function(i, exclude=TRUE, deleteExistingGraph=TRUE, includeComplexMembers=FALSE)
{
   if(!exists("rcy")){
      rcy <<- RCyjs()
      setBrowserWindowTitle(rcy, "ReactionParser")
      }

   reaction <- getReactionForTesting(i)
   parser <- ReactionParser$new(doc, reaction)
   x <- parser$toEdgeAndNodeTables(excludeUbiquitousSpecies=TRUE, includeComplexMembers)

   g.json <- toJSON(dataFramesToJSON(x$edges, x$nodes))

   if(deleteExistingGraph)
      deleteGraph(rcy)

   addGraph(rcy, g.json)
   later(function(){
      setBrowserWindowTitle(rcy, sprintf("%d: %s", i, parser$getName()))
      loadStyleFile(rcy, "style.js")
      layout(rcy, "cose-bilkent")
      fit(rcy)
      }, 2)

} # displayReaction
#------------------------------------------------------------------------------------------------------------------------
if(!interactive())
    runTests()
