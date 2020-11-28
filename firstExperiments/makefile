default:

start3:
	docker run \
          -d \
          --name mets \
          --publish=7474:7474 --publish=7687:7687 \
          --volume=$$HOME/github/human1-for-graphDatabases/firstExperiments/neo4j:/data \
          --volume=$$HOME/github/human1-for-graphDatabases/firstExperiments/import:/import \
          --volume=$$HOME/github/human1-for-graphDatabases/firstExperiments/logs:/logs \
          --env=NEO4J_AUTH=none \
          --env=NEO4J_dbms_active__database=mets \
          --env='NEO4JLABS_PLUGINS=["apoc"]' \
          --env='NEO4J_dbms_security_procedures_unrestricted=apoc.\*' \
          neo4j:3.5

bash3:
	docker exec -it mets bash 


stop3:
	- docker stop mets; docker rm mets;


start:
	docker run \
          -d \
          --name mets4 \
          --publish=7474:7474 \
          --publish=7687:7687 \
          --volume=$$HOME/github/human1-for-graphDatabases/firstExperiments/neo4j_v4:/data \
          --volume=$$HOME/github/human1-for-graphDatabases/firstExperiments/import:/import \
          --volume=$$HOME/github/human1-for-graphDatabases/firstExperiments/logs_v4:/logs \
          --env=NEO4J_AUTH=none \
          --env=NEO4J_dbms.default_database=mets4 \
          --env='NEO4JLABS_PLUGINS=["apoc", "graph-data-science"]' \
          neo4j:latest

bash:
	docker exec -it mets4 bash 


stop:
	- docker stop mets4; docker rm mets4;

log:
	docker logs mets4


lsof:
	lsof -i -n -P | grep 7474
