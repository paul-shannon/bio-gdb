library(httr)
library(jsonlite)

# load the genes from human1
tbl.genes <- read.table("~/github/human1-for-graphDatabases/firstExperiments/import/genes.tsv",
                        sep="\t", as.is=TRUE, header=TRUE)

tbl.hargh <- get(load("~/github/regulatoryHAR/work/firstLook/tbl.hargh.RData"))
length(intersect(tbl.genes$symbol, tbl.hargh$gene)) # 294
length(unique(tbl.genes$symbol)) # [1] 3626

genes.har.postancient <- subset(tbl.hargh, ghScore > 10 & postAncient == 1)$gene  # 167
goi <- intersect(tbl.genes$symbol, genes.har.postancient) # 19
 #  [1] "CREBBP"   "AKR7A2"   "ALDH18A1" "MGRN1"    "NUP98"    "GPAT3"    "DUSP6"    "PPIP5K2"
 #  [9] "HNMT"     "PRKCA"    "RRM1"     "NSUN3"    "DHFR2"    "UBE2E2"   "URAD"     "PLA2G6"
 # [17] "CDK10"    "HS3ST5"   "GALNT4"

# cypher commands
# match(n) where n.symbol="DHFR2" return n.id;    "ENSG00000178700"
# match(n)-[e:Interaction]-[m] where r.

# match(n) where n.symbol="DHFR2" return n;
# | (:Gene {name: "ENSG00000178700", symbol: "DHFR2", id: "ENSG00000178700", sboTerm: "SBO:0000243"}) |

# in what reaction does this DHFR2 play a role?
# match(n)-[r]-(m) where n.symbol='DHFR2'return m.id;
#
# | "R_HMR_4333" |
# | "R_HMR_4335" |
# | "R_HMR_4654" |
# | "R_HMR_4656" |
# | "R_HMR_4655" |
# | "R_HMR_4332" |
#
# match(g:Gene {symbol: 'DHFR2'}) call apoc.neighbors.athop(g, ">", 2) yield node return node;
#
# (:ReactionGroup {name: "Folate metabolism", id: "group63", kind: "partonomy", sboTerm: "SBO:0000633"}) |

# match(g:Gene)-[r]-(m) where g.symbol in["DHFR2", "PRKCA","RRM1", "NSUN3","UBE2E2"] return g, r, m;

# shortest path between genes
MATCH (start:Gene {symbol: 'DHFR2'}), (end:Gene {symbol: 'NSUN3'})
CALL gds.alpha.shortestPath.stream({
  nodeProjection: 'Loc',
  relationshipProjection: {
    ROAD: {
      type: 'ROAD',
      properties: 'cost',
      orientation: 'UNDIRECTED'
    }
  },
  startNode: start,
  endNode: end,
  relationshipWeightProperty: 'cost'
})
YIELD nodeId, cost
RETURN gds.util.asNode(nodeId).name AS name, cost




# UniProtKB says:
#
# function
# Key enzyme in folate metabolism. Contributes to the de novo mitochondrial thymidylate biosynthesis
# pathway. Required to prevent uracil accumulation in mtDNA. Binds its own mRNA and that of DHFR.2
#
# Miscellaneous
# Humans have acquired two dihydrofolate reductase enzymes during their evolution, DHFR and DHFR2.
# In contrast to human, mice and brown rats have just one.1 Publication

goi <- intersect(tbl.genes$symbol, genes.har.postancient) # 19
length(goi)
# some gene symbols
uri <- sprintf("http://localhost:8000/goEnrich")
body.jsonString <- sprintf('%s', toJSON(list(geneSymbols=goi)))
r <- POST(uri, body=body.jsonString)
tbl.gobp <- fromJSON(content(r)[[1]])
dim(tbl.gobp)

uri <- sprintf("http://localhost:8000/keggEnrich")
body.jsonString <- sprintf('%s', toJSON(list(geneSymbols=goi)))
r <- POST(uri, body=body.jsonString)
tbl.kegg <- fromJSON(content(r)[[1]])
dim(tbl.kegg)

