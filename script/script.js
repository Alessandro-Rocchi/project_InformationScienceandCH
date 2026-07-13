
async function init() {
    transformXML()
}

document.querySelectorAll('pre code').forEach((blocco) => {
  // 1. Dividiamo il testo riga per riga (cattura sia i ritorni a capo Windows che Mac/Linux)
  let righe = blocco.textContent.split(/\r?\n/);
  
  // 2. Rimuoviamo la prima riga se contiene solo spazi vuoti (creata andando a capo dopo <code>)
  if (righe.length > 0 && righe[0].trim() === '') {
    righe.shift();
  }
  
  // 3. Rimuoviamo l'ultima riga se contiene solo spazi vuoti (creata prima del tag </code>)
  if (righe.length > 0 && righe[righe.length - 1].trim() === '') {
    righe.pop();
  }
  
  // 4. Calcoliamo qual è l'indentazione minima tra tutte le righe che contengono testo
  let minSpazi = Infinity;
  righe.forEach(riga => {
    // Ignoriamo le righe totalmente vuote
    if (riga.trim() !== '') {
      const spazi = riga.match(/^\s*/)[0].length;
      if (spazi < minSpazi) {
        minSpazi = spazi;
      }
    }
  });
  
  // 5. Tagliamo esattamente quel numero di spazi dall'inizio di OGNI riga
  if (minSpazi < Infinity) {
    righe = righe.map(riga => riga.substring(minSpazi));
  }
  
  // 6. Uniamo di nuovo le righe e aggiorniamo l'HTML
  blocco.textContent = righe.join('\n');
});

document.addEventListener('DOMContentLoaded', init);

function transformXML() {
      // Load the XML file
      const xmlFile = "./xml/dylanDog_TEI.xml";
      const xhr = new XMLHttpRequest();
      xhr.open("GET", xmlFile, true);
      xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
          const xml = xhr.responseXML;

          // Load the XSLT file
          const xslFile = "./xslt/dd_entities_XSLT.xslt";
          const xhrXSLT = new XMLHttpRequest();
          xhrXSLT.open("GET", xslFile, true);
          xhrXSLT.onreadystatechange = function () {
            if (xhrXSLT.readyState == 4 && xhrXSLT.status == 200) {
              const xsl = xhrXSLT.responseXML;

              // Perform the transformation
              if (typeof XSLTProcessor !== "undefined") {
                const processor = new XSLTProcessor();
                processor.importStylesheet(xsl);
                const result = processor.transformToDocument(xml);

                // Display the transformed HTML
                const outputDiv = document.getElementById("entities_table");
                outputDiv.innerHTML = new XMLSerializer().serializeToString(result);
              } else {
                alert("XSLTProcessor not supported by the browser.");
              }
            }
          };
          xhrXSLT.send(null);
        }
      };
      xhr.send(null);
    }

