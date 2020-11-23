default:

start:
	docker run \
          -d \
          --name mets \
          --publish=7474:7474 --publish=7687:7687 \
          --volume=$$HOME/github/human1-for-graphDatabases/firstExperiments/neo4j:/data \
          --volume=$$HOME/github/human1-for-graphDatabases/firstExperiments/import:/import \
          --env=NEO4J_AUTH=none \
          --env=NEO4J_dbms_active__database=mets \
          neo4j:3.5

bash:
	docker exec -it mets bash 
