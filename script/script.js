
async function init() {
    transformXML()
}

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

