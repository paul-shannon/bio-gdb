library(neo4r)
library(RUnit)
library(RCyjs)
#------------------------------------------------------------------------------------------------------------------------
if(!exists("rcy")){
   title <- "rcy Human1"
   rcy <- RCyjs(title=title, quiet=TRUE)
   }

if(!exists("con"))
   con <- neo4j_api$new(url = "http://localhost:7474",
                        user = "neo4j",
                        password = "neo4j")
#------------------------------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_connection()
   test_nodeAndEdgeLabels()
   test_nodeCount()
   test_simpleReaction()

} # runTests
#------------------------------------------------------------------------------------------------------------------------
test_connection <- function()
{
   message(sprintf("--- test_connection"))

   checkTrue(con$ping())

   log <- capture.output(
      checkTrue(con$get_version())   # prints "Found Neo4j 4.x" to stdout
      )

} # test_connection
#------------------------------------------------------------------------------------------------------------------------
test_nodeAndEdgeLabels <- function()
{
   message(sprintf("--- test_nodeAndEdgeLabels"))

   node.types <- con$get_labels()$label$value
   checkEquals(sort(node.types), sort(c("Reaction", "Gene", "Metabolite", "ReactionGroup")))
   edge.types <- as.data.frame(con$get_relationships())$value
   checkEquals(sort(edge.types), sort(c("catalyzes","contains", "produces", "substrateOf")))

} # test_nodeAndEdgeLabels
#------------------------------------------------------------------------------------------------------------------------
test_nodeCount <- function()
{
   message(sprintf("--- test_nodeCount"))

   x <- as.integer(call_neo4j("match(n) return count(n)", con)[[1]][1,1])
   checkTrue(x > 25000)
   checkTrue(x < 30000)

} # test_nodeCount
#------------------------------------------------------------------------------------------------------------------------
# R_HMR_4365 is step 8 of glycolysis
# catalyzed by PGM, phosphoglycerate mutase
# converts 3-phosphoglycerate (3PG) to 2-phosphoglycerate (2PG) through a 2,3-bisphosphoglycerate intermediate
# thus just one substrate, one product, one enzyme (
test_simpleReaction <- function()
{
   message(sprintf("--- test_simpleReaction"))

      #----------------------------------------------------
      # first query: just get substrate, reaction, product
      #----------------------------------------------------

   query <- "match(n)-[r:substrateOf]-(m:Reaction{id: 'R_HMR_4365'})-[q:produces]->(p) return n, r, m, q, p;"
   x <- lapply(call_neo4j(query, con), function(element) unique(as.data.frame(element)))
   checkEquals(names(x), c("n", "r", "m", "q", "p"))
   checkEquals(x$n$id,   "M_m00674c")
   checkEquals(x$r$type, "substrateOf")
   checkEquals(x$m$id,   "R_HMR_4365")
   checkEquals(x$q$type, "produces")
   checkEquals(x$p$id,   "M_m00913c")

      #---------------------------------------------------------------
      # second query: just get all the nodes hanging off the reaction
      #---------------------------------------------------------------

   query <- "match(n)-[r:substrateOf]-(m:Reaction{id: 'R_HMR_4365'})-[q]-(p) return n, r, m, q, p;"
   x <- lapply(call_neo4j(query, con), function(element) unique(as.data.frame(element)))
      # if multiple targets (p, for example) then preceding edge type plurality should be preserved
   x2 <- lapply(call_neo4j(query, con), function(element) (as.data.frame(element)))

   checkEquals(names(x), c("n", "r", "m", "q", "p"))
   checkEquals(x$n$id,   "M_m00674c")
   checkEquals(x$r$type, "substrateOf")
   checkEquals(x$m$id,   "R_HMR_4365")
   checkEquals(x2$q$type, c("produces", "contains", "catalyzes", "catalyzes", "catalyzes", "catalyzes"))
   checkEquals(x$p$id,   c("M_m00913c", "group72", "ENSG00000172331", "ENSG00000226784", "ENSG00000164708","ENSG00000171314"))

} # test_simpleReaction
#------------------------------------------------------------------------------------------------------------------------
# two substrates, three products
test_moderatelyComplexReaction <- function()
{
   message(sprintf("--- test_moderatelyComplexReaction"))
    "M_m00674c" ->  "substrateOf" ->  "R_HMR_4365" ->  "produces" ->  "M_m00913c"

  # R_HMR_4365 produces M_m00913c substrateRor "R_HMR_3839" produces "M_m02553c" substrateFor R_HMR_3856"
  # R_HMR_3839 has two substrates, 3 products, and 2 or-enzymes

   query <- "match(n)-[r:substrateOf]-(m:Reaction{id: 'R_HMR_3839'})-[q:produces]->(p) return n, r, m, q, p;"
   x <- lapply(call_neo4j(query, con), function(element) unique(as.data.frame(element)))
   checkEquals(names(x), c("n", "r", "m", "q", "p"))
   checkEquals(sort(x$n$id), sort(c("M_m02552c", "M_m00913c")))
   checkEquals(x$r$type, "substrateOf")
   checkEquals(x$m$id,   "R_HMR_3839")
   checkEquals(x$q$type, "produces")
   checkEquals(x$p$id,   c("M_m02553c", "M_m02039c", "M_m00914c"))

} # test_moderatelyComplexReaction
#------------------------------------------------------------------------------------------------------------------------
# from the preceeding test ("moderatelyComplexReaction") we now that
#   M_m00674c and M_m00914c are substrate and product, respectively, of two reactions
#   connected via M_m00913c as a bridging product/substrate of an intervening reaction:
#    M_m00674c -> R_HMR_4365 -> M_m00913c -> R_HMR_3839 -> M_m00914c
# this function tests and demonstrates finding this path
test_simpleShortestPath <- function()
{
   message(sprintf("--- test_simpleShortestPath"))

   query <-
"match(start:Metabolite{id:'M_m00674c'}), (end:Metabolite{id:'M_m00914c'})
call gds.alpha.shortestPath.stream({
  nodeProjection: ['Reaction', 'Metabolite'],
  relationshipProjection: {
     produces:    {orientation: 'UNDIRECTED'},
     substrateOf: {orientation: 'UNDIRECTED'}
    },
  startNode: start,
  endNode: end,
  relationshipWeightProperty: null
})
YIELD nodeId, cost
RETURN gds.util.asNode(nodeId).id AS name, cost;"

   x <- lapply(call_neo4j(query, con), function(element) unique(as.data.frame(element)))
   checkEquals(x$name$value, c("M_m00674c", "R_HMR_4365", "M_m00913c",  "R_HMR_3839", "M_m00914c"))

} # test_simpleShortestPath
#------------------------------------------------------------------------------------------------------------------------
test_toCytoscapeDataFrames <- function()
{
   message(sprintf("--- toCytoscapeDataFrames"))
     # from test_moderatelyComplexReaction above
   query <- "match(n)-[r:substrateOf]-(m:Reaction{id: 'R_HMR_3839'})-[q:produces]->(p) return n, r, m, q, p;"
   x <- lapply(call_neo4j(query, con), function(element) unique(as.data.frame(element)))

   tbl.edges <- data.frame(source=c(x$n$id[1], x$n$id[2], rep(x$m$id, 3)),
                           target=c(x$m$id, x$m$id, x$p$id[1], x$p$id[2], x$p$id[3]),
                           interaction=c(x$r$type[1],x$r$type[1], rep(x$q$type[1], 3)),
                           stringsAsFactors=FALSE)

   g.json <- toJSON(dataFramesToJSON(tbl.edges))
   addGraph(rcy, g.json)
   layout(rcy, "cose")
   fit(rcy)
   selectNodes(rcy, c(x$n$id[1], x$n$id[2], rep(x$m$id, 3))) #rep(x$m$id, 3))

} # test_toCytoscapeDataFrames
#------------------------------------------------------------------------------------------------------------------------
