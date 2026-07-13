from lxml import etree as ET
from rdflib import Graph, Namespace, URIRef, RDF, OWL, Literal
from rdflib.namespace import XSD

def resolve_uri(value, LOCAL, namespaces_dict):
    if value.startswith('#'):
        return LOCAL[value[1:]] 
    elif ':' in value and not value.startswith('http'):
        prefix, local_name = value.split(':', 1)
        if prefix in namespaces_dict:
            return namespaces_dict[prefix][local_name]
    return URIRef(value)

def extract_rdf_from_tei(xml_file_path):

    g = Graph() #graph creation
    
    # Used namespace definitions
    DCTERMS = Namespace("http://purl.org/dc/terms/")
    CBO = Namespace("http://comicmeta.org/cbo/")
    FRBROO = Namespace("http://iflastandards.info/ns/fr/frbr/frbroo/")
    SCHEMA = Namespace("http://schema.org/")
    DBO = Namespace("http://dbpedia.org/ontology/")
    DD = Namespace("https://alessandro-rocchi.github.io/project_InformationScienceandCH/ontology/DDOntology#")
    CRM = Namespace("http://www.cidoc-crm.org/cidoc-crm/")
    SKOS = Namespace("http://www.w3.org/2004/02/skos/core#")
    FOAF = Namespace("http://xmlns.com/foaf/0.1/")
    
    # Local namespace for the RDF dataset generated from the TEI XML
    LOCAL = Namespace("https://alessandro-rocchi.github.io/project_InformationScienceandCH/rdf_dataset/")    
    
    # Namespace dictionary for binding prefixes to URIs in the RDF graph
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
    
    for prefix, uri in namespaces_dict.items(): # in this for i bind every prefix to the corresponding URI in the RDF graph
        g.bind(prefix, uri, override=True)
    g.bind("dd_data", LOCAL, override=True)
    
    tree = ET.parse(xml_file_path) #parsing using lxml and Etree to create an ElementTree object from the XML file
    root = tree.getroot()
    
    #Dictionary for the namespaces used in the TEI XML document useful for XPath queries
    nsmap = {
        'tei': 'http://www.tei-c.org/ns/1.0',
        'xml': 'http://www.w3.org/XML/1998/namespace'
    }
    
    #Automatic extraction of <relation> elements with @sameAs attributes to generate owl:sameAs triples using XPath queries
    elements_with_sameas = root.xpath('//*[@xml:id and @sameAs]', namespaces=nsmap)
    
    for el in elements_with_sameas: #for every element with @sameAs attribute I extract the xml:id and the sameAs value to create a triple in the RDF graph
        xml_id = el.get('{http://www.w3.org/XML/1998/namespace}id')
        same_as = el.get('sameAs')
        
        subj = LOCAL[xml_id]
        obj = URIRef(same_as)
        g.add((subj, OWL.sameAs, obj)) #i add the triple to the RDF graph using the add() method of the Graph class
        
    #extraction of <relation> elements with @active, @name, and @passive attributes to generate RDF triples using XPath queries
    relations = root.xpath('.//tei:listRelation/tei:relation', namespaces=nsmap)
    
    for relation in relations: #every <relation> element is processed to extract the @active, @name, and @passive attributes to create a triple in the RDF graph
        active = relation.get('active')
        name = relation.get('name')
        passive = relation.get('passive')
        
        if active and name and passive: #if all three attributes are present, the URIs are resolved and a triple is added to the RDF graph
            subj = resolve_uri(active, LOCAL, namespaces_dict)
            pred = resolve_uri(name, LOCAL, namespaces_dict)
            obj = resolve_uri(passive, LOCAL, namespaces_dict)
            g.add((subj, pred, obj))
    
    for person in root.xpath('.//tei:person[@xml:id]', namespaces=nsmap): #extraction of <person> elements with @xml:id attributes to generate RDF triples using XPath queries. This is mandatory to extract the names of the persons in the database and to create the corresponding triples in the RDF graph
        p_id = person.get("{http://www.w3.org/XML/1998/namespace}id")
        subject_uri = LOCAL[p_id] #I create a URI for the subject using the LOCAL namespace and the xml:id of the <person> element
        
        name_tag = person.find('./tei:persName', namespaces=nsmap) #do a find() to get the <persName> child element
        if name_tag is not None:

            raw_text = "".join(name_tag.itertext()) #I use itertext() to get all the text content of the <persName> element, including any nested elements, and join them into a single string
            

            full_name = " ".join(raw_text.split())#clean the text by removing leading/trailing whitespace and replacing multiple spaces with a single space
            
            if full_name:
                g.add((subject_uri, FOAF.name, Literal(full_name, datatype=XSD.string))) #I add a triple to the RDF graph with the subject URI, the FOAF.name predicate, and the full name as a literal with xsd:string datatype

    
    for bibl in root.xpath('.//tei:bibl[@xml:id]', namespaces=nsmap):#extraction of <bibl> elements with @xml:id attributes to generate RDF triples using XPath queries. This is mandatory to extract the bibliographic information of the comics in the database and to create the corresponding triples in the RDF graph
        b_id = bibl.get("{http://www.w3.org/XML/1998/namespace}id")
        subject_uri = LOCAL[b_id]
        
        title_tag = bibl.find('./tei:title[@level="m"]', namespaces=nsmap) #I find the <title> child element of the <bibl> element with the level attribute equal to "m" using the find() method and the appropriate XPath query
    
        if title_tag is None: #if the <title> element with level="m" is not found, I look for a <title> element with level="s" using the find() method and the appropriate XPath query
            title_tag = bibl.find('./tei:title[@level="s"]', namespaces=nsmap)
            
        if title_tag is None: #if the <title> element with level="s" is not found, I look for a <title> element without any level attribute using the find() method and the appropriate XPath query
            title_tag = bibl.find('./tei:title', namespaces=nsmap)

        if title_tag is not None and title_tag.text: #if a <title> element is found and it has text content, I add a triple to the RDF graph with the subject URI, the DCTERMS.title predicate, and the title as a literal with xsd:string datatype
            g.add((subject_uri, DCTERMS.title, Literal(title_tag.text.strip(), datatype=XSD.string))) #I add a triple to the RDF graph with the subject URI, the DCTERMS.title predicate, and the title as a literal with xsd:string datatype
            
        date_tag = bibl.find('./tei:date', namespaces=nsmap) #I find the <date> child element of the <bibl> element using the find() method and the appropriate XPath query
        if date_tag is not None:
            year_val = date_tag.get("when") #I extract the value of the "when" attribute from the <date> element using the get() method
            if year_val:
                year_val = year_val.strip()
                if len(year_val) == 4: #if the length of the year value is 4 I know that the value is only a year, so I use the xsd:gYear datatype
                    date_value = Literal(year_val, datatype=XSD.gYear)
                else: #if the length of the year value is not 4 I assume that the value is a full date, so I use the xsd:date datatype
                    date_value = Literal(year_val, datatype=XSD.date)
                g.add((subject_uri, DCTERMS.date, date_value))#I add a triple to the RDF graph with the subject URI, the DCTERMS.date predicate, and the date value as a literal with the appropriate datatype (xsd:gYear or xsd:date)

        # Numero dell'albo (xsd:integer)
        issue_tag = bibl.find('./tei:biblScope[@unit="albo"]', namespaces=nsmap)#I find the <biblScope> child element of the <bibl> element with the unit attribute equal to "albo" using the find() method and the appropriate XPath query
        if issue_tag is not None and issue_tag.text:
            g.add((subject_uri, CBO.issueNumber, Literal(issue_tag.text.strip(), datatype=XSD.integer)))
            
    return g

if __name__ == "__main__":
    file_input = "./xml/dylanDog_TEI.xml" 
    
    result_graph = extract_rdf_from_tei(file_input)
    
    # Serializzazione in formato Turtle (ttl)
    turtle_data = result_graph.serialize(format="turtle")
    
    # Salvataggio
    with open("rdf_dataset/dataset_dylandog.ttl", "w", encoding="utf-8") as f:
        f.write(turtle_data)