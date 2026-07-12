import lxml.etree as ET

# Read the content of a XML file
dom = ET.parse('./xml/dylanDog_TEI.xml')

# Read the XSL file
xslt = ET.parse('./xslt/dd_XSLT.xslt')

# Build a XSL transformer
# create an instance of the class XSLT
transform = ET.XSLT(xslt)

# Perform the transformation
# the result is an instance of the class ElementTree
newdom = transform(dom)

# write the string in a html document
with open("./html/dylanDog_py.html", "wb") as f:
 f.write(ET.tostring(newdom, pretty_print=True))
