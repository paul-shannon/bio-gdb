LOAD CSV with HEADERS from 'file:///metabolites.tsv' AS line FIELDTERMINATOR '\t'
     CREATE (:Metabolite {id: line.id,
                          name: line.name,  
                          compartment: line.compartment,
                          chemicalFormula: line.chemicalFormula});
