library(plyr)  # for rbind.fill
#----------------------------------------------------------------------------------------------------
compartments <- get(load("compartments.RData"))
genes <- get(load("genes.RData"))
groups <- get(load("groups.RData"))
reactions <- get(load("reactions.RData"))
species <- get(load("species.RData"))

     #------------------------------------------------------------
     # create the reactions table, then the simpler "role" tables:
     #   reaction/gene      (these are the participating enzymes)
     #   reaction/reactant
     #   reaction/product
     #------------------------------------------------------------

tbl.reactions <- as.data.frame(do.call(rbind, lapply(reactions, function(r) r$reaction)),
                               stringsAsFactors=FALSE)
dim(tbl.reactions)
write.table(tbl.reactions, file="import/reactions.tsv", sep="\t", row.names=FALSE, quote=FALSE)


list.geneRoles <- lapply(reactions, function(r){
    if(all(is.null(r$genes)))
        return(data.frame())
    return(cbind(r$genes, r$reaction$id))
    })

tbl.geneRoles <- as.data.frame(do.call(rbind, list.geneRoles), stringsAsFactors=FALSE)
colnames(tbl.geneRoles) <- c("geneID", "reactionID")
dim(tbl.geneRoles)  # 24135 2
write.table(tbl.geneRoles, file="import/geneRoles.tsv", sep="\t", row.names=FALSE, quote=FALSE)

tbl.reactantRoles <- as.data.frame(do.call(rbind, lapply(reactions, function(r) cbind(r$reactants, r$reaction$id))),
                                   stringsAsFactors=FALSE)
tbl.reactantRoles <- tbl.reactantRoles[, c("species", "r$reaction$id")]
colnames(tbl.reactantRoles) <- c("speciesID", "reactionID")
dim(tbl.reactantRoles)  # 27851 2
write.table(tbl.reactantRoles, file="import/reactantRoles.tsv", sep="\t", row.names=FALSE, quote=FALSE)


list.productRoles <- lapply(reactions, function(r){
    products <- r$products
    reaction <- r$reaction$id
    if(length(products) == 0)
        return(data.frame())
    return(cbind(products, reaction))
    })

tbl.productRoles <- as.data.frame(do.call(rbind, list.productRoles), stringsAsFactors=FALSE)
tbl.productRoles <- tbl.productRoles[, c("species", "reaction")]
colnames(tbl.productRoles) <- c("speciesID", "reactionID")

write.table(tbl.productRoles, file="import/productRoles.tsv", sep="\t", row.names=FALSE, quote=FALSE)

     #------------------------------------------------------------
     # create the species (metabolite) and gene tables
     #------------------------------------------------------------

#tbl.species <- as.data.frame(do.call(rbind, lapply(species, function(x) x$species)),
#                             stringsAsFactors=FALSE)
#write.table(tbl.species, file="import/metabolites.tsv", sep="\t", row.names=FALSE, quote=FALSE)

transform.species <- function(species){
    tbl <- species$species
    x <- species$speciesRef
    if(nrow(x) == 0)
        return(tbl)
    #browser()
    tbl.refs <- t(x[,2])
    colnames(tbl.refs) <- x[,1]
    rownames(tbl.refs) <- NULL
    cbind(tbl, tbl.refs)
    }

tbls.species <- lapply(species, transform.species)
tbl.species <- rbind.fill(tbls.species)
dim(tbl.species) # 8400 11
length(which(!is.na(tbl.species$chebi)))  # [1] only 3331 chebi identifiers
# add chembl, using the unichem
#
tbl.cmap <- get(load("../idMapping/unichem/chembl-chebi-table.RData"))
matches <- match(tbl.species$chebi, tbl.cmap$chebi)
chembl.values <- unlist(lapply(matches,function(match)
    if(is.na(match))
      return (NA)
    else
      return(tbl.cmap$chembl[match])))

tbl.species$chembl <- chembl.values
coi <- c("id","name","compartment","chemicalFormula","bigg.metabolite","chebi","chembl","kegg.compound","metanetx.chemical","hmdb","pubchem.compound","lipidmaps")
tbl.species <- tbl.species[, coi]
write.table(tbl.species, file="import/metabolites.tsv", sep="\t", row.names=FALSE, quote=FALSE)



tbls.genes <-lapply(genes, function(gene) {
    tbl <- gene$gene
    symbol <- tbl$name   # fallback
    tbl.ref <- gene$refs
    symbol.row <- grep("hgnc.symbol", tbl.ref$ref)
    if(length(symbol.row) == 1)
        symbol <- tbl.ref$value[symbol.row]
    as.data.frame(cbind(tbl, symbol=symbol))
    })

tbl.genes <- do.call(rbind, tbls.genes)
dim(tbl.genes) # 3626 4
write.table(tbl.genes, file="import/genes.tsv", sep="\t", row.names=FALSE, quote=FALSE)

     #------------------------------------------------------------
     # now the groups table - pathways, more or less
     # then the groupMembership table
     #------------------------------------------------------------

tbls.groups <- lapply(groups, function(g) return(g$group))
tbl.groups <- do.call(rbind, tbls.groups)
dim(tbl.groups) # 142 4

write.table(tbl.groups, file="import/groups.tsv", sep="\t", row.names=FALSE, quote=FALSE)

createMembershipTable <- function(group){
    reactions <- group$members
    id <- rep(group$group$id, length(reactions))
    data.frame(groupID=id, reactionID=reactions, stringsAsFactors=FALSE)
    }

tbls.groupMembership <- lapply(groups, createMembershipTable)
tbl.groupMembership <- do.call(rbind, tbls.groupMembership)
dim(tbl.groupMembership) # 13096 2
length(unique(tbl.groupMembership$groupID))     # 142
length(unique(tbl.groupMembership$reactionID))  # 13096: no reactions occur in > 1 group.  suprising.

write.table(tbl.groupMembership, file="import/groupMemberships.tsv", sep="\t", row.names=FALSE, quote=FALSE)
