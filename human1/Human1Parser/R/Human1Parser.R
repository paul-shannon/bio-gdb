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

        #' @description
        #' learn the elements and their count
        #' @returns a names list of counts
      getCounts = function(){
          model <- xmlRoot(private$doc)[["model"]]
          list(reactions=length(xmlChildren(model[["listOfReactions"]])),
               species=length(xmlChildren(model[["listOfSpecies"]])))
         }

     ) # public
  ) # class

