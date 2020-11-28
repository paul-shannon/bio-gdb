match (n)-[r]-(m) delete n, r, m;
match (n) delete n;
DROP INDEX ON :Reaction(id);
DROP INDEX ON :Gene(id);
DROP INDEX ON :Metabolite(id);
DROP INDEX ON :ReactionGroup(id);
