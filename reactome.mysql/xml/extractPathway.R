library(EnsDb.Hsapiens.v79)
library(XML)
# replace rdf:li with li
# remove bqbiol
# provide explicit name "sbml" for the default namespace

#----------------------------------------------------------------------------------------------------
assignCommonNames <- function(tbl.nodes)
{
   entities <- tbl.nodes$name
   uniprot.indices <- grep("uniprotkb", entities)
   chebi.indices <- grep("ChEBI", entities)
   ligand.entries <- grep("ligandId", entities)

   tbl.ensembl <- select(EnsDb.Hsapiens.v79,
                         key=sub("uniprotkb:", "", entities[uniprot.indices]),
                         keytype="UNIPROTID",
                         columns=c("SYMBOL"))
   tbl.nodes$name[uniprot.indices] <- tbl.ensembl$SYMBOL
   chebi.indices

   tbl.chebi <- read.table("~/github/bio-gdb/reactome.mysql/xml/chebi-names.tsv", sep="\t",
                           as.is=TRUE, fill=TRUE, header=TRUE)
   chebi.numbers <- sub("ChEBI:", "", tbl.nodes$name[chebi.indices], fixed=TRUE)

   chebi.names <- tbl.chebi$NAME[match(chebi.numbers, tbl.chebi$COMPOUND_ID)]
   chebi.names <- unlist(lapply(strsplit(chebi.names, "\t"), "[", 1))
   tbl.nodes$name[chebi.indices] <- chebi.names

   tbl.nodes

} # assignCommonNames
#----------------------------------------------------------------------------------------------------
ns <- c(sbml="http://www.sbml.org/sbml/level3/version1/core",
        bqbiol="http://biomodels.net/biology-qualifiers",
        dc="http://purl.org/dc/elements/1.1/")



pathwayID <- "R-HSA-165159-trimmed"
file <- sprintf("~/github/bio-gdb/reactome.mysql/xml/%s.sbml", pathwayID)
file.exists(file)

text <- paste(readLines(file), collapse="\n")
nchar(text)
text <- gsub("rdf:", "", text)
text <- gsub("bqbiol:", "", text)
doc <- xmlParse(text)

as.character(getNodeSet(doc, "//model/@id"))      # pathway_165159
as.character(getNodeSet(doc, "//model/@name"))    # MTOR signalling

printf("species: %d", length(getNodeSet(doc, "//species")))           # 66
printf("reactions: %d", length(getNodeSet(doc, "//reaction")))        # 29
printf("compartments: %d", length(getNodeSet(doc, "//compartment")))  # 4


max <- length(getNodeSet(doc, "//species"))
# max <- 3

tbls.nodes <- list()
tbls.edges <- list()

for(i in seq_len(max)){
   id <- as.character(getNodeSet(doc, sprintf("//species[%d]/@id", i), namespaces=ns))
   id <- sub("species_", "R-HSA-", id)
   name <- as.character(getNodeSet(doc, sprintf("//species[%d]/@name", i), namespaces=ns))
   compartment <- as.character(getNodeSet(doc, sprintf("//species[%d]/@compartment", i), namespaces=ns))
   members <- as.character(getNodeSet(doc, sprintf("//species[%d]//hasPart//li/@resource", i), namespaces=ns))
   members <- sub("http://purl.uniprot.org/uniprot/", "uniprotkb:", members, fixed=TRUE)
   members <- sub("http://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:", "ChEBI:", members, fixed=TRUE)
   members <- sub("http://www.guidetopharmacology.org/GRAC/LigandDisplayForward?ligandId=",
                  "ligandId:", members, fixed=TRUE)
   printf("species %d had %d members: %s, %s", i, length(members), name, id)
   print(members)
   species.type <- "protein"
   tbl.edges <- data.frame()
   if(length(members) > 0){
      species.type <- "complex"
      tbl.edges <- data.frame(a=members, b=rep(id, length(members)),
                              type=rep("memberOfComplex", length(members)),
                              stringsAsFactors=FALSE)
      }

   compartment <- gsub(".* \\[(.*)\\]", "\\1", name, perl=TRUE)
   name.simple <- gsub(" \\[.*\\]", "", name, perl=TRUE)
   tbl.node.main <- data.frame(id=id,
                               name=name.simple,
                               type=species.type,
                               compartment=compartment,
                               stringsAsFactors=FALSE)
   tbl.node.members <- data.frame(id=members,
                                  name=members,
                                  type=rep("complexMember", length(members)),
                                  compartment=rep(NA, length(members)),
                                  stringsAsFactors=FALSE)
   tbls.nodes[[i]] <- rbind(tbl.node.main, tbl.node.members)
   tbls.edges[[i]] <- tbl.edges
   #browser()
   xyz <- 99
   }

tbl.edges <- unique(do.call(rbind, tbls.edges))
tbl.nodes <- unique(do.call(rbind, tbls.nodes))
dim(tbl.edges)
dim(tbl.nodes)

tbl.nodes <- assignCommonNames(tbl.nodes)

save(tbl.edges, tbl.nodes, file=sprintf("tables/%s-tables.RData", pathwayID))
