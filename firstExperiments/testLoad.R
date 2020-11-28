library(neo4r)
library(RUnit)
#------------------------------------------------------------------------------------------------------------------------
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
