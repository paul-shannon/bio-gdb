# Human1Parser
#
#' import R6
#' import XML
#'
#' @title Human1Parser
#' @description an R6 class which parses xml Human1 reactions into data.frames
#' @name Human1Parser
#'
library(R6)

#' @export
Human1Parser = R6Class("Human1Parser",

    private = list(
        doc = NULL,
        xml.node = NULL,
        molecularSpeciesMap = NULL

        ), # private

        #' @description
        #' Create a new parser
        #' @param xml.filename
        #' @return a new `Human1Parser` object.

    public = list(
      initialize = function(xml.filename){
         stopifnot(file.exists(xml.filename))
         private$doc <- xmlParse(filename)
         },

      #----------------------------------------------------------------------------------------------------
      #' @description
      #' learn the elements and their count
      #' @returns a names list of counts
      getCounts = function(){
         model <- xmlRoot(private$doc)[["model"]]
         list(reactions=length(xmlChildren(model[["listOfReactions"]])),
              species=length(xmlChildren(model[["listOfSpecies"]])),
              compartments=length(xmlChildren(model[["listOfCompartments"]])),
              geneProducts=length(xmlChildren(model[["listOfGeneProducts"]])),
              groups=length(xmlChildren(model[["listOfGroups"]]))
              )
         }, # getCounts

      #----------------------------------------------------------------------------------------------------
      #' @description
      #' extract one molecular species
      #' @param n integer the index of the reaction
      #' @returns two data.frames: species and speciesRefs
      getSpecies = function(n){
         species <- getNodeSet(private$doc, sprintf("(//species)[%d]", n))
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
         annotation <- getNodeSet(private$doc, sprintf("(//species)[%d]/annotation/*/*/*/*/li", n))
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

         }, # getSpecies
      #----------------------------------------------------------------------------------------------------
      #' @description
      #' extract one reaction
      #' @param n integer the index of the reaction
      #' @returns a list of data.frames: reaction, reactionrefs, reactants, products, a list of genes
      getReaction = function(n){
         reaction <- getNodeSet(private$doc, sprintf("(//reaction)[%d]", n))
         tbl.reaction <- with(as.list(xmlAttrs(reaction[[1]])),
                              data.frame(id=id,
                                         name=name,
                                         reversible=reversible,
                                         fast=fast,
                                         lowerFluxBound=lowerFluxBound,
                                         upperFluxBound=upperFluxBound,
                                         stringsAsFactors=FALSE))

           #       metaid        sboTerm             id     reversible           fast lowerFluxBound  upperFluxBound
           #  "R_HMR_3905"  "SBO:0000176"   "R_HMR_3905"        "false"        "false"        "FB2N0"    "FB3N1000"

         annotation <- getNodeSet(private$doc, sprintf("(//reaction)[%d]/annotation/*/*/*/*/li", n))
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
         reactants <- getNodeSet(private$doc, sprintf("(//reaction)[%d]/listOfReactants/speciesReference", n))
         tbls.reactants <- lapply(reactants, function(reactant) {
            attrs <- xmlAttrs(reactant)
            with(as.list(attrs),
                 data.frame(species=species, stoichiometry=stoichiometry, constant=constant,
                            stringsAsFactors=FALSE))
            })
         tbl.reactants <- do.call(rbind, tbls.reactants)
         products  <- getNodeSet(private$doc, sprintf("(//reaction)[%d]/listOfProducts/speciesReference", n))
         tbls.products <- lapply(products, function(product) {
            attrs <- xmlAttrs(product)
            with(as.list(attrs),
                 data.frame(species=species, stoichiometry=stoichiometry, constant=constant,
                            stringsAsFactors=FALSE))
            })
          tbl.products <- do.call(rbind, tbls.products)
            # todo: distinguish "and" genes from "or" genes from single-item geneProductRef
        genes.raw.chosen  <- getNodeSet(private$doc, sprintf("(//reaction)[%d]/geneProductAssociation//geneProductRef", n))
        printf(" reaction %d,    genes found: %d", n, length(genes.raw.chosen))
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
        } # getReaction
     ) # public
  ) # class

