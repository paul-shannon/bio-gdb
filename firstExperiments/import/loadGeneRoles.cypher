LOAD CSV WITH HEADERS FROM  "file:///geneRoles.tsv" AS line FIELDTERMINATOR '\t'
      MATCH (reaction:Reaction {id: line.reactionID}), (gene:Gene {id: line.geneID})
      CREATE (gene)-[:Interaction {type: 'catalyzes'}]->(reaction);
