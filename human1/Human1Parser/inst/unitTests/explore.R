library(xml2)
f <- "../extdata/tmp-GEM-noNS.xml"
doc <- read_xml(f)
xml_path(xml_find_all(doc, ".//listOfCompartments")) # "/sbml/model/listOfCompartments"

node <- xml_find_first(doc, "/sbml/model/listOfCompartments")
xml_children(node) # nine compartment nodes
xml_find_all(node, ".//compartment/@name")


f <- "../extdata/Human-GEM-noNS.xml"
doc <- read_xml(f)
xml_find_all(doc, "..//compartment/@name")
xml_find_all(doc, "/sbml/model/listOfCompartments/compartment/@name")

# way too slow.  try XML
library(XML)
