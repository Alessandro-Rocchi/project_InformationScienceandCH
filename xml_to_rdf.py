from lxml import etree as ET
from rdflib import DCTERMS, Graph, Namespace, URIRef, RDF, OWL

def extract_rdf_from_tei(xml_file_path):
    # 1. Inizializzazione del Grafo RDF
    g = Graph()
    
    # 2. Definizione dei Namespace (estratti dal <listPrefixDef> del file TEI)
    DCTERMS = Namespace("http://purl.org/dc/terms/")
    CBO = Namespace("http://comicmeta.org/cbo/")
    FRBROO = Namespace("http://iflastandards.info/ns/fr/frbr/frbroo/")
    SCHEMA = Namespace("http://schema.org/")
    DBO = Namespace("http://dbpedia.org/ontology/")
    DD = Namespace("https://alessandro-rocchi.github.io/project_InformationScienceandCH/ontology/DDOntology#")
    CRM = Namespace("http://www.cidoc-crm.org/cidoc-crm/")
    SKOS = Namespace("http://www.w3.org/2004/02/skos/core#")
    FOAF = Namespace("http://xmlns.com/foaf/0.1/")
    
    # Namespace fittizio per gli identificatori locali (es. #d_dog, #t_sclavi)
    LOCAL = Namespace("https://alessandro-rocchi.github.io/project_InformationScienceandCH/rdf_dataset/")    
    # Dizionario di supporto per legare i prefissi in rdflib
    namespaces_dict = {
        "dcterms": DCTERMS,
        "cbo": CBO,
        "frbroo": FRBROO,
        "schema": SCHEMA,
        "dbo": DBO,
        "dd": DD,
        "crm": CRM,
        "skos": SKOS,
        "foaf": FOAF,
        "rdf": RDF,
        "owl": OWL
    }
    
    # Binding dei prefissi per un output in formato Turtle pulito e leggibile
    for prefix, uri in namespaces_dict.items():
        g.bind(prefix, uri)
    g.bind("dd_data", LOCAL)
    
    # 3. Parsing del file XML con lxml
    tree = ET.parse(xml_file_path)
    root = tree.getroot()
    
    # Dizionario dei Namespace XML per le query XPath in lxml
    nsmap = {
        'tei': 'http://www.tei-c.org/ns/1.0',
        'xml': 'http://www.w3.org/XML/1998/namespace'
    }
    
    # 4. Estrazione automatica dei sameAs (Generazione di triple owl:sameAs)
    # Sfruttiamo XPath per trovare in un colpo solo TUTTI gli elementi che hanno 
    # sia l'attributo xml:id che l'attributo sameAs
    elements_with_sameas = root.xpath('//*[@xml:id and @sameAs]', namespaces=nsmap)
    
    for el in elements_with_sameas:
        # lxml espande gli attributi coi namespace nella forma {URI}attributo
        xml_id = el.get('{http://www.w3.org/XML/1998/namespace}id')
        same_as = el.get('sameAs')
        
        subj = LOCAL[xml_id]
        obj = URIRef(same_as)
        g.add((subj, OWL.sameAs, obj))
            
    # Funzione Helper per convertire le stringhe XML in Nodi RDF
    def resolve_uri(value):
        if value.startswith('#'):
            return LOCAL[value[1:]] 
        elif ':' in value and not value.startswith('http'):
            prefix, local_name = value.split(':', 1)
            if prefix in namespaces_dict:
                return namespaces_dict[prefix][local_name]
        return URIRef(value)
        
    # 5. Iterazione sulle <relation> per la generazione delle Triple principali
    # XPath setaccia l'albero scendendo direttamente fino ai tag relation corretti
    relations = root.xpath('.//tei:listRelation/tei:relation', namespaces=nsmap)
    
    for relation in relations:
        active = relation.get('active')
        name = relation.get('name')
        passive = relation.get('passive')
        
        if active and name and passive:
            subj = resolve_uri(active)
            pred = resolve_uri(name)
            obj = resolve_uri(passive)
            g.add((subj, pred, obj))
            
    return g

if __name__ == "__main__":
    file_input = "dylanDog.xml" 
    
    # Avvio della trasformazione
    grafo_risultante = extract_rdf_from_tei(file_input)
    
    # Serializzazione in formato Turtle (ttl)
    turtle_data = grafo_risultante.serialize(format="turtle")
    
    # Salvataggio
    with open("rdf_dataset/dataset_dylandog.ttl", "w", encoding="utf-8") as f:
        f.write(turtle_data)