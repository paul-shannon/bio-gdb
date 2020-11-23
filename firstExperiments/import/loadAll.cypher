LOAD CSV with HEADERS from 'file:///reactions.tsv' AS line FIELDTERMINATOR '\t'
     create (:Reaction {id: line.id,
                        reversible: line.reversible,
 			fast: line.reversible,
                        lowerFluxBound: line.lowerFluxBound,
                        upperFluxBound: line.upperFluxBound});
CREATE INDEX ON :Reaction(id);

LOAD CSV with HEADERS from 'file:///genes.tsv' AS line FIELDTERMINATOR '\t'
     CREATE (:Gene {id: line.id,
                     name: line.name,  
                     symbol: line.symbol,
		     sboTerm: line.sboTerm});
CREATE INDEX ON :Gene(id);


LOAD CSV with HEADERS from 'file:///metabolites.tsv' AS line FIELDTERMINATOR '\t'
     CREATE (:Metabolite {id: line.id,
                          name: line.name,  
                          compartment: line.compartment,
                          chemicalFormula: line.chemicalFormula});
CREATE INDEX ON :Metabolite(id);


LOAD CSV with HEADERS from 'file:///groups.tsv' AS line FIELDTERMINATOR '\t'
     CREATE (:ReactionGroup {id: line.id,
                             name: line.name,  
                             kind: line.kind,
                             sboTerm: line.sboTerm});
CREATE INDEX ON :ReactionGroup(id);


LOAD CSV WITH HEADERS FROM  "file:///geneRoles.tsv" AS line FIELDTERMINATOR '\t'
      MATCH (reaction:Reaction {id: line.reactionID}), (gene:Gene {id: line.geneID})
      CREATE (gene)-[:Interaction {type: 'catalyzes'}]->(reaction);

LOAD CSV WITH HEADERS FROM  "file:///groupMemberships.tsv" AS line FIELDTERMINATOR '\t'
      MATCH (reaction:Reaction {id: line.reactionID}), (group:ReactionGroup {id: line.groupID})
      CREATE (reaction)-[:Interaction {type: 'belongsTo'}]->(group);

LOAD CSV WITH HEADERS FROM  "file:///productRoles.tsv" AS line FIELDTERMINATOR '\t'
      MATCH (metabolite:Metabolite {id: line.speciesID}), (reaction:Reaction {id: line.reactionID})
      CREATE (metabolite)-[:Interaction {type: 'productOf'}]->(reaction);

LOAD CSV WITH HEADERS FROM  "file:///reactantRoles.tsv" AS line FIELDTERMINATOR '\t'
      MATCH (metabolite:Metabolite {id: line.speciesID}), (reaction:Reaction {id: line.reactionID})
      CREATE (metabolite)-[:Interaction {type: 'reactantFor'}]->(reaction);


