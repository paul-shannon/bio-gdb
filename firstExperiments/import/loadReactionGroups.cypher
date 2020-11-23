LOAD CSV with HEADERS from 'file:///groups.tsv' AS line FIELDTERMINATOR '\t'
     CREATE (:ReactionGroup {id: line.id,
                             name: line.name,  
                             kind: line.kind,
                             sboTerm: line.sboTerm});
