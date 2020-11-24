tbl.hargh <- get(load("~/github/regulatoryHAR/work/firstLook/tbl.hargh.RData"))
length(intersect(tbl.genes$symbol, tbl.hargh$gene)) # 294
length(unique(tbl.genes$symbol)) # [1] 3626

genes.har.postancient <- subset(tbl.hargh, ghScore > 10 & postAncient == 1)$gene  # 167
intersect(tbl.genes$symbol, genes.har.postancient) # 19
 #  [1] "CREBBP"   "AKR7A2"   "ALDH18A1" "MGRN1"    "NUP98"    "GPAT3"    "DUSP6"    "PPIP5K2"
 #  [9] "HNMT"     "PRKCA"    "RRM1"     "NSUN3"    "DHFR2"    "UBE2E2"   "URAD"     "PLA2G6"
 # [17] "CDK10"    "HS3ST5"   "GALNT4"

# cypher commands
# match(n) where n.symbol="DHFR2" return n.id;    "ENSG00000178700"
# match(n)-[e:Interaction]-[m] where r.


