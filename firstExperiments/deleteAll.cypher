match(n)-[r]-(m) delete r;
match(n) delete n;
match(n) return count(n);

