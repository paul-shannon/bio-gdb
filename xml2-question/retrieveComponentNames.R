library(xml2)
f <- "Human-GEM-noNamespaces.xml"
doc <- read_xml(f)

system.time(xml_path(xml_find_all(doc, ".//listOfCompartments")))           # 31 seconds
system.time(node <- xml_find_first(doc, "/sbml/model/listOfCompartments"))  # 34 secons

system.time(print(xml_children(node)))                                      # 0.03
system.time(print(xml_find_all(node, "/compartment/@name")))                # 31 seconds, empty result
system.time(print(xml_find_all(node, "./compartment/@name")))               # 45 seconds, full result
system.time(print(xml_find_all(node, "..//compartment/@name")))             # 47 seconds, full result
system.time(print(xml_find_all(doc, "/sbml/model/listOfCompartments/compartment/@name")))  # 31 secs, full result
system.time(print(xml_find_all(node, "compartment/@name")))                # 31.52 seconds, empty result


