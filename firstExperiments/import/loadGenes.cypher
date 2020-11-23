LOAD CSV with HEADERS from 'file:///genes.tsv' AS line FIELDTERMINATOR '\t'
     CREATE (:Gene {id: line.id,
                     name: line.name,  
                     symbol: line.symbol,
		     sboTerm: line.sboTerm});
