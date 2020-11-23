# Human1 for graph databases
[Human1](https://www.chalmers.se/en/departments/bio/news/Pages/The-next-generation-of-human-metabolic-modelling.aspx) is a very recent synthesis of two landmark human metabolic networks:

 - [recon2](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4896983/)
 - [Recon3D](https://www.nature.com/articles/nbt.4072)
 
This repo translates Human1's SBML distribution into flat tsv files which can be used to fill
databases.  Our emphasis at present is on filling to graph databases, neo4j and the google
biomedical data commons.

The first version is, of course, only preliminary.  Expect changes in the next few days and weeks.

## An SBML entry for one reaction

 - <b>firstExperiments/readSBML.R</b> parses the xml into R data structures
 - <b>firstExperiments/toTSV.R</b> writes them out in language-neutral tab-delimited text
 - <b>firstExperiments/import/loadAll.cypher</b> loads these structures into a neo4j graph database
 - expect schema revisions as we work with - start to query - these data

<img src="https://github.com/paul-shannon/human1-for-graphDatabases/blob/main/human1-sbml-1-reaction.png">
