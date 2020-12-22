library(xml2)
f <- "Human-GEM-noNamespaces.xml"
doc <- read_xml(f)
xml_path(xml_find_all(doc, ".//listOfCompartments")) # "/sbml/model/listOfCompartments"
node <- xml_find_first(doc, "/sbml/model/listOfCompartments")

system.time(print(xml_children(node)))

system.time(print(xml_find_all(node, "/compartment/@name")))


f <- "../extdata/Human-GEM-noNS.xml"
doc <- read_xml(f)
system.time(print(xml_find_all(node, "..//compartment/@name"))
xml_find_all(doc, "/sbml/model/listOfCompartments/compartment/@name")

# way too slow.  try XML
library(XML)
f <- "nons.xml"
file.exists(f)
doc <- xmlParse(f)
