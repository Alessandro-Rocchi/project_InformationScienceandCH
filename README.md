# Dylan Dog Citation LODLAM Project

This repository contains a Knowledge Organization / Cultural Heritage project that models **Dylan Dog citations and inspirations** as Linked Open Data.

The project includes:
- a public website (`index.html`) describing the domain analysis and modeling process;
- a TEI-XML source dataset (`xml/dylanDog_TEI.xml`);
- XSLT transformations to HTML (`xslt/`);
- Python scripts to generate HTML and RDF outputs (`python_scripts/`);
- a custom ontology (`ontology/DDOntology.ttl`);
- the generated RDF dataset in Turtle (`rdf_dataset/dataset_dylandog.ttl`).

## Repository structure

- `index.html` — main project page
- `script/` — JavaScript logic (including dynamic XSLT entity-table rendering)
- `style/` — CSS theme
- `xml/` — TEI source file
- `xslt/` — XSLT stylesheets
- `python_scripts/` — transformation scripts
- `html/` — generated HTML artifacts and auxiliary pages
- `ontology/` — custom ontology files
- `rdf_dataset/` — generated RDF/Turtle dataset
- `images/`, `data/`, `yED_files/` — project assets and modeling resources

## Requirements

- Python `>=3.14` (as declared in `pyproject.toml`)
- Python packages listed in `pyproject.toml` (`lxml`, `rdflib`, etc.)

## Setup

From the project root:

```bash
pip install -r <(python - <<'PY'
import tomllib
with open("pyproject.toml","rb") as f:
    deps = tomllib.load(f)["project"]["dependencies"]
print("\n".join(deps))
PY
)
```

Or install dependencies with your preferred tool using `pyproject.toml`.

## Run the website locally

Because the project loads XML/XSLT assets via browser requests, run a local web server from the repository root:

```bash
python -m http.server 8000
```

Then open:

`http://localhost:8000/index.html`

## Generate HTML from XML/TEI (Python + XSLT)

```bash
python python_scripts/xml_to_html_python.py
```

Output file:
- `html/dylanDog_py.html`

## Generate RDF dataset (Turtle)

```bash
python python_scripts/xml_to_rdf.py
```

Output file:
- `rdf_dataset/dataset_dylandog.ttl`

## Notes

- The webpage also generates an entities table dynamically in the browser using `script/script.js` and `xslt/dd_entities_XSLT.xslt`.
- Ontology documentation is available in `html/Dylan Dog Ontology.html`.