# human1-for-graphDatabases
[Human1](https://www.chalmers.se/en/departments/bio/news/Pages/The-next-generation-of-human-metabolic-modelling.aspx) is a very recent synthesis of two landmark human metabolic networks:

 - [recon2](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4896983/)
 - [Recon3D](https://www.nature.com/articles/nbt.4072)
 
This repo translates Human1's SBML distribution into flat tsv files which can be used to fill
databases.  Our emphasis at present is on filling to graph databases, neo4j and the google
biomedical data commons.

The first version is, of course, only preliminary.  Expect changes in the next few days and weeks.

## An SBML entry for one reaction
<pre&gt;
      &lt;reaction metaid="R_HMR_3905" sboTerm="SBO:0000176" id="R_HMR_3905" reversible="false" fast="false" lowerFluxBound="FB2N0" upperFluxBound="FB3N1000"&gt;
        &lt;notes&gt;
          &lt;body xmlns="http://www.w3.org/1999/xhtml"&gt;
            &lt;p&gt;Confidence Level: 0&lt;/p&gt;
            &lt;p&gt;AUTHORS: PMID:10868354;PMID:12491384;PMID:12818203;PMID:14674758;PMID:15289102;PMID:15299346;PMID:15327949;PMID:15682493;PMID:15713978&lt;/p&gt;
          &lt;/body&gt;
        &lt;/notes&gt;
        &lt;annotation&gt;
          &lt;RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:vCard4="http://www.w3.org/2006/vcard/ns#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/"&gt;
            &lt;Description about="#R_HMR_3905"&gt;
              &lt;bqbiol:is&gt;
                &lt;Bag&gt;
                  &lt;li resource="http://identifiers.org/ec-code/1.1.1.1"/&gt;
                  &lt;li resource="http://identifiers.org/ec-code/1.1.1.71"/&gt;
                  &lt;li resource="http://identifiers.org/kegg.reaction/R00754"/&gt;
                  &lt;li resource="http://identifiers.org/bigg.reaction/ALCD2x"/&gt;
                  &lt;li resource="http://identifiers.org/metanetx.reaction/MNXR95725"/&gt;
                &lt;/Bag&gt;
              &lt;/bqbiol:is&gt;
            &lt;/Description&gt;
          &lt;/RDF&gt;
        &lt;/annotation&gt;
        &lt;listOfReactants&gt;
          &lt;speciesReference species="M_m01796c" stoichiometry="1" constant="true"/&gt;
          &lt;speciesReference species="M_m02552c" stoichiometry="1" constant="true"/&gt;
        &lt;/listOfReactants&gt;
        &lt;listOfProducts&gt;
          &lt;speciesReference species="M_m01249c" stoichiometry="1" constant="true"/&gt;
          &lt;speciesReference species="M_m02039c" stoichiometry="1" constant="true"/&gt;
          &lt;speciesReference species="M_m02553c" stoichiometry="1" constant="true"/&gt;
        &lt;/listOfProducts&gt;
        &lt;geneProductAssociation&gt;
          &lt;or&gt;
            &lt;geneProductRef geneProduct="ENSG00000147576"/&gt;
            &lt;geneProductRef geneProduct="ENSG00000172955"/&gt;
            &lt;geneProductRef geneProduct="ENSG00000180011"/&gt;
            &lt;geneProductRef geneProduct="ENSG00000187758"/&gt;
            &lt;geneProductRef geneProduct="ENSG00000196344"/&gt;
            &lt;geneProductRef geneProduct="ENSG00000196616"/&gt;
            &lt;geneProductRef geneProduct="ENSG00000197894"/&gt;
            &lt;geneProductRef geneProduct="ENSG00000198099"/&gt;
            &lt;geneProductRef geneProduct="ENSG00000248144"/&gt;
          &lt;/or&gt;
        &lt;/geneProductAssociation&gt;
      &lt;/reaction&gt;

</pre>


