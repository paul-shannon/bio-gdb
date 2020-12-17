# ReactionParser.R
#
#' import R6
#' import xml2
#'
#' @title ReactionParser
#' @description an R6 class which parses xml Reactome reactions into data.frames
#' @name ReactionParser
#'
library(R6)

#' @export
ReactionParser = R6Class("ReactionParser",

    private = list(
        doc = NULL,
        xml.node = NULL,
        molecularSpeciesMap = NULL,

        createMolecularSpeciesMap = function(doc){
           private$molecularSpeciesMap <- list()
           all.species <- xml_find_all(private$doc, "..//listOfSpecies/species")
           for(species in all.species){
              id <- xml_text(xml_find_all(species, ".//@id"))
              name.raw <- xml_text(xml_find_all(species, ".//@name"))
              tokens <- strsplit(name.raw, " [", fixed=TRUE)[[1]]
              name <- tokens[1]
              moleculeType <- "molecule"
              compartment <- sub("]", "", tokens[2], fixed=TRUE)
              members <- xml_find_all(species, ".//bqbiol:hasPart//rdf:li/@rdf:resource")
              #browser()
              if(length(members) == 0)
                members <- c()
              if(length(members) > 0){
                moleculeType <- "complex"
                members <- xml_text(members)
                members <- sub("http://purl.uniprot.org/uniprot/", "uniprotkb:", members, fixed=TRUE)
                members <- sub("http://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:", "ChEBI:", members, fixed=TRUE)
                members <- sub("http://www.guidetopharmacology.org/GRAC/LigandDisplayForward?ligandId=",
                               "ligandId:", members, fixed=TRUE)
                }
              new.entry <- list(name=name, moleculeType=moleculeType, compartment=compartment, members=members)
              private$molecularSpeciesMap[[id]] <- new.entry
              xyz <- 99
              } # for species
           } # createSpeciesMap

        ), # private

        #' @description
        #' Create a new parser
        #' @param xml.node an XMLInternalNode
        #' @return A new `ReactionParser` object.


   public = list(
       initialize = function(doc, xml.node){
          private$doc <- doc
          private$createMolecularSpeciesMap()
          private$xml.node <- xml.node
          },

        #' @description
        #' extracts all molecular species from xml hierarchy into a usable list
        #' @returns a named list, indexed by species ids, with reactome data in each element
      getMolecularSpeciesMap = function(){
         private$molecularSpeciesMap
         },

        #' @description
        #' easy access to the entire xml element
        #' @returns an XMLInternalNode
        #' @description
        #' XPath from document root for the reaction
        #' @returns a character string, e.g, "/sbml/model/listOfReactions/reaction[5]"
      getXPath = function(){
         xml_path(private$xml.node)
         },

        #' @description
        #' easy access to the entire xml element
        #' @returns an XMLInternalNode
      getXml = function(){
         private$xml.node
         },

        #' @description
        #' every reaction has a reactome identifier
        #' @returns a character string, the id for this reaction node
      getID = function(){
         xml_attr(private$xml.node, "id")
         },

        #' @description
        #' every reaction has a name
        #' @returns a character string, the name of this reaction node
      getName = function(){
         xml_attr(private$xml.node, "name")
         },

        #' @description
        #' a reaction is specific to a cellular compartmentevery reaction has a name
        #' @returns a character string, the compartment in which  this reaction takes place
      getCompartment = function(){
         xml_attr(private$xml.node, "compartment")
         },

        #' @description
        #' every (most?) reactions are accompanied by explanatory notes
        #' @returns a character string, the short-to-mediums account of the reaction
      getNotes = function(){
         xml_text(xml_find_all(private$xml.node, ".//notes/p"))
         },

        #' @description
        #' one (zero?) or more reactants contribute to each reaction
        #' @returns an integer count
      getReactantCount = function(){
         length(xml_find_all(private$xml.node, ".//listOfReactants/speciesReference"))
         },

        #' @description
        #' get the species identifiers for all reactants
        #' @returns reactant (species) ids
      getReactants = function(){
         xml_text(xml_find_all(private$xml.node, ".//listOfReactants/speciesReference/@species"))
         },

        #' @description
        #' one (zero?) or more products are produced by each reaction
        #' @returns an integer count
      getProductCount = function(){
         length(xml_find_all(private$xml.node, ".//listOfProducts/speciesReference"))
         },

        #' @description
        #' get the species identifiers for all modifiers
        #' @returns modifier (species) ids
      getProducts = function(){
         xml_text(xml_find_all(private$xml.node, ".//listOfProducts/speciesReference/@species"))
         },

        #' @description
        #' one (zero?) or more modifiers are produced by each reaction
        #' @returns an integer count
      getModifierCount = function(){
         length(xml_find_all(private$xml.node, ".//listOfModifiers/modiferSpeciesReference"))
         },

        #' @description
        #' cytoscape.js various databases (sql, neo4j, dc) represent data in tables.
        #' create them here
        #' @returns a named list, edges and nodes, each a data.frame
      toEdgeAndNodeTables = function(){
          edge.count <- self$getReactantCount() + self$getProductCount()
          tbl.in <- data.frame(source=self$getReactants(),
                               target=rep(self$getID(), self$getReactantCount()),
                               interaction=rep("reactantFor", self$getReactantCount()),
                               stringsAsFactors=FALSE)
          tbl.out <- data.frame(source=rep(self$getID(), self$getProductCount()),
                                target=self$getProducts(),
                                interaction=rep("produces", self$getProductCount()),
                                stringsAsFactors=FALSE)

          tbl.edges <- rbind(tbl.in, tbl.out) # , tbl.complexes)

          species <- grep("species_", unique(c(tbl.edges$source, tbl.edges$target)), v=TRUE)
          map <- self$getMolecularSpeciesMap()

          nodes.all <- with(tbl.edges, unique(c(source, target)))
          nodes.species <- intersect(nodes.all, names(map))
          nodes.other   <- setdiff(nodes.all, names(map))
          assignNodeType <- function(node.id){
              if(node.id == "species_9678687")
                  return("drug")
              if(grepl("^reaction_", node.id))
                  return("reaction")
              if(grepl("^uniprotkb:", node.id))
                  return("protein")
              if(grepl("^ligandId:", node.id))
                  return("ligand")
              if(grepl("^species_", node.id))
                  return(map[[node.id]]$moleculeType)
              return("unrecognized")
          } # assignNodeType

          assignNodeName <- function(node.id){
              if(node.id %in% c("species_9678687", "ligandId:6031"))
                  return("rapamycin")
              if(grepl("^reaction_", node.id))
                  return(self$getName())
              if(grepl("^uniprotkb:", node.id))
                  return(select(EnsDb.Hsapiens.v79,
                                key=sub("uniprotkb:", "", node.id),
                                keytype="UNIPROTID",
                                columns=c("SYMBOL"))$SYMBOL)
              if(grepl("^ligandId:", node.id))
                  return(node.id)
              if(grepl("^species_", node.id))
                  return(map[[node.id]]$name)
              return(node.id)
          } # addingNodeName

          tbl.nodes <- data.frame(id=nodes.all,
                                  type=unlist(lapply(nodes.all, assignNodeType)),
                                  label=unlist(lapply(nodes.all, assignNodeName)),
                                  stringsAsFactors=FALSE)
          return(list(edges=tbl.edges, nodes=tbl.nodes))
          }
     ) # public
  ) # class

