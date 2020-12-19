default:
	@echo nons: strip namespaces from small sample human1 file
	@echo full: strip namesapces from full human1 file

nons:
	sed -f sed.commands tmp-GEM.xml > nons.xml

full:
	sed -f sed.commands Human-Gem.xml > Human-GEM-noNamespaces.xml

