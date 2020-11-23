LOAD CSV with HEADERS from 'file:///reactions.tsv' AS line FIELDTERMINATOR '\t'
     create (:Reaction {id: line.id,
                        reversible: line.reversible,
 			fast: line.reversible,
                        lowerFluxBound: line.lowerFluxBound,
                        upperFluxBound: line.upperFluxBound});

CREATE INDEX ON :Reaction(id);