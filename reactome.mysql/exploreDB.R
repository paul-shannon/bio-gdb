library(RMySQL)
db <- dbConnect(MySQL (), dbname='reactome', user="root", password="tril0byt")
tbl.names <- dbListTables(db)
for(name in tbl.names){
    tbl <- dbGetQuery(db, sprintf("select * from %s", name))
    printf("%50s: %d x %d", name, nrow(tbl), ncol(tbl))
    if(nrow(tbl) > 0)
        write.table(tbl, file=sprintf("tables/%s.tsv", name),
                    sep="\t",
                    row.names=FALSE,
                    col.names=TRUE,
                    quote=FALSE)
    } # for

tbl.dbid <-
# 198 tables, including "ReferenceGeneProduct", Reaction
tbl.reaction <- dbGetQuery(db, "select * from Reaction")
dim(tbl.reaction) # 72518
tbl.pathway <- dbGetQuery(db, "select * from Pathway")
dim(tbl.pathway)  # 20987
tbl.pathway2.hasEvent <- dbGetQuery(db, "select * from Pathway_2_hasEvent")
dim(tbl.pathway2.hasEvent) # 104524


