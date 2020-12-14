library(RMySQL)
db <- dbConnect(MySQL (), dbname='reactome', user="root", password="tril0byt")
tbl.names <- dbListTables(db)

tbl.dbid <- dbGetQuery(db, sprintf("select * from %s", "DatabaseIdentifier"))
subset(tbl.dbid, identifier=="ENSG00000198793-MTOR")
#           DB_ID           identifier referenceDatabase referenceDatabase_class
# 349456 11603978 ENSG00000198793-MTOR          10778802       ReferenceDatabase
