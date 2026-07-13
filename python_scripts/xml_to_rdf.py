from lxml import etree as ET
from rdflib import Graph, Namespace, URIRef, RDF, OWL, Literal
from rdflib.namespace import XSD

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
    
    # Namespace per gli identificatori locali (es. #d_dog, #t_sclavi)
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
    
    for prefix, uri in namespaces_dict.items():
        g.bind(prefix, uri, override=True)
    g.bind("dd_data", LOCAL, override=True)
    
    # 3. Parsing del file XML con lxml
    tree = ET.parse(xml_file_path)
    root = tree.getroot()
    
    # Dizionario dei Namespace XML per le query XPath in lxml
    nsmap = {
        'tei': 'http://www.tei-c.org/ns/1.0',
        'xml': 'http://www.w3.org/XML/1998/namespace'
    }
    
    # 4. Estrazione automatica dei sameAs (Generazione di triple owl:sameAs)
    elements_with_sameas = root.xpath('//*[@xml:id and @sameAs]', namespaces=nsmap)
    
    for el in elements_with_sameas:
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
        
    # 5. Iterazione sulle <relation> per la generazione delle Triple principali (Object Properties)
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

    # 6. Estrazione dei Datatype (Data Properties)
    
    # A. Estrazione Nomi Persone (xsd:string)
    for person in root.xpath('.//tei:person[@xml:id]', namespaces=nsmap):
        p_id = person.get("{http://www.w3.org/XML/1998/namespace}id")
        subject_uri = LOCAL[p_id]
        
        name_tag = person.find('./tei:persName', namespaces=nsmap)
        if name_tag is not None:
            # Estrae tutto il testo dal tag e dai suoi figli (forename, surname, ecc.)
            raw_text = "".join(name_tag.itertext())
            
            # Pulisce gli spazi, i tab e gli "a capo" creati dall'XML
            full_name = " ".join(raw_text.split())
            
            # Se dopo la pulizia c'è effettivamente un nome, aggiunge la tripla
            if full_name:
                g.add((subject_uri, FOAF.name, Literal(full_name, datatype=XSD.string)))

    # B. Estrazione Titoli, Date e Numeri degli Albi 
    for bibl in root.xpath('.//tei:bibl[@xml:id]', namespaces=nsmap):
        b_id = bibl.get("{http://www.w3.org/XML/1998/namespace}id")
        subject_uri = LOCAL[b_id]
        
        # Titolo (xsd:string)
        title_tag = bibl.find('./tei:title', namespaces=nsmap)
        if title_tag is not None and title_tag.text:
            g.add((subject_uri, DCTERMS.title, Literal(title_tag.text.strip(), datatype=XSD.string)))
            
        # Data di pubblicazione (xsd:gYear)
        date_tag = bibl.find('./tei:date', namespaces=nsmap)
        if date_tag is not None:
            year_val = date_tag.get("when")
            if year_val:
                year_val = year_val.strip()
                if len(year_val) == 4:
                    date_value = Literal(year_val, datatype=XSD.gYear)
                else:
                    date_value = Literal(year_val, datatype=XSD.date)
                g.add((subject_uri, DCTERMS.date, date_value))

        # Numero dell'albo (xsd:integer)
        issue_tag = bibl.find('./tei:biblScope[@unit="albo"]', namespaces=nsmap)
        if issue_tag is not None and issue_tag.text:
            g.add((subject_uri, CBO.issueNumber, Literal(issue_tag.text.strip(), datatype=XSD.integer)))
            
    return g

if __name__ == "__main__":
    file_input = "./xml/dylanDog_TEI.xml" 
    
    # Avvio della trasformazione
    grafo_risultante = extract_rdf_from_tei(file_input)
    
    # Serializzazione in formato Turtle (ttl)
    turtle_data = grafo_risultante.serialize(format="turtle")
    
    # Salvataggio
    with open("rdf_dataset/dataset_dylandog.ttl", "w", encoding="utf-8") as f:
        f.write(turtle_data)