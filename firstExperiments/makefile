default:

start:
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

bash:
	docker exec -it mets bash 


stop:
	- docker stop mets; docker rm mets;


start4:
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
          --env='NEO4JLABS_PLUGINS=["apoc"]' \
          neo4j:latest

#          --env='NEO4JLABS_PLUGINS=["apoc"]' \
#          --env='NEO4J_dbms_security_procedures_unrestricted=apoc.\*' \
#          -e NEO4J_apoc_export_file_enabled=true \
#          -e NEO4J_apoc_import_file_enabled=true \
#          -e NEO4J_apoc_import_file_use__neo4j__config=true \
#          --volume=$$HOME/github/human1-for-graphDatabases/firstExperiments/plugins:/plugins \

bash4:
	docker exec -it mets4 bash 


stop4:
	- docker stop mets4; docker rm mets4;

logs4:
	docker logs mets4


#          --env='NEO4JLABS_PLUGINS=["apoc"]' \
#          --env='NEO4J_dbms_security_procedures_unrestricted=apoc.\*,algo.\*' \


# docker run -it --rm \
#    --publish=7474:7474 \
#    --publish=7687:7687 \
#    -e NEO4J_dbms_connector_https_advertised__address="localhost:7473" \
#    -e NEO4J_dbms_connector_http_advertised__address="localhost:7474" \
#    -e NEO4J_dbms_connector_bolt_advertised__address="localhost:7687" \
#    --env=NEO4J_AUTH=none \
#    neo4j

