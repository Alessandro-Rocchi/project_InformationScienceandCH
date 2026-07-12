<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
        <html>
            <head>
                <link rel="schema.DC" href="http://purl.org/dc/elements/1.1/"/>
                <META name="DC.Title" content="{//tei:titleStmt/tei:title}"/>
                <META name="DC.Creator" content="Alessandro Rocchi"/>
                <META name="DC.Subject" content="Dylan Dog, Fumetti"/>
                <META name="DC.Description" content="Un catalogo contenente i primi 150 numeri del fumetto italiano Dylan Dog"/>
                <META name="DC.Publisher" content="Github Pages"/>
                <META name="DC.Date" content="2024/01/01"/>
                <META name="DC.Type" content="Catalogo web"/>
                <META name="DC.Format" content="Sito web"/>
                <META name="DC.Source" content="Collana di fumetti Dylan Dog"/>
                <META name="DC.Language" content="It"/>

                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous"></link>
                <link rel="stylesheet" href="style/style.css"/>

                <link rel="apple-touch-icon" sizes="180x180" href="favicon/apple-touch-icon.png"/>
                <link rel="icon" type="image/png" sizes="32x32" href="favicon/favicon-32x32.png"/>
                <link rel="icon" type="image/png" sizes="16x16" href="favicon/favicon-16x16.png"/>
                <link rel="manifest" href="favicon/site.webmanifest"/>

                <title><xsl:value-of select="//tei:titleStmt/tei:title"/></title>
            </head>
            <body>
                <header class="container-fluid">
                    <h1><xsl:value-of select="//tei:titleStmt/tei:title"/></h1>
                        <div class="meta">
                            <h2>Metadata</h2>

                            Author: <xsl:value-of select="//tei:titleStmt/tei:author"/><br/>
                            Annotated by: <xsl:value-of select="//tei:respStmt/tei:persName"/><br/>
                            Publisher: <xsl:value-of select="//tei:publicationStmt/tei:publisher"/><br/>
                            Place: <xsl:value-of select="//tei:publicationStmt/tei:pubPlace"/><br/>
                            Year: <xsl:value-of select="//tei:publicationStmt/tei:date"/>

                        </div>
                </header>

                <hr class="my-5" />
                
                <xsl:apply-templates select="//tei:text"/>

                <hr class="my-5" />

                <div class="container bg-white mt-4 p-4 rounded shadow">
                    <h1 class="text-center mb-5">Dylan Dog Database</h1>

                    <xsl:apply-templates select="//tei:particDesc/tei:listPerson" />

                    <hr class="my-5" />

                    <xsl:apply-templates select="//tei:particDesc/tei:listOrg" />

                    <hr class="my-5" />

                    <xsl:apply-templates select="//tei:sourceDesc/tei:listBibl" />

                    <hr class="my-5" />

                    <xsl:apply-templates select="//tei:sourceDesc/tei:listRelation" />
                </div>
                <footer class="container-fluid mt-5 p-3 bg-light text-center">
                    <p class="small">Dylan Dog Database 2026</p>
                </footer>
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="tei:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:label">
        <strong>
            <xsl:apply-templates/>
        </strong>
    </xsl:template>
    <xsl:template match="tei:list[@type='unordered']">
        <ul class="ps-4 mb-4">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    <xsl:template match="tei:item">
        <li class="mb-2">
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="tei:div[@type='section']">
        <section class="container-fluid">
            <xsl:apply-templates/>
        </section>
    </xsl:template>
    <xsl:template match="tei:div[@type='section']/tei:head">
        <h2>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>
     <xsl:template match="tei:div[@type='subsection']/tei:head">
        <h3>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>
    <xsl:template match="tei:persName | tei:orgName | tei:title">
        <a href="{@ref}" class="text-primary text-decoration-none fw-semibold">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <xsl:template match="tei:figure">
        <figure class="figure text-center my-4 p-3 border rounded bg-light" id="{@xml:id}">
            <xsl:apply-templates/>
        </figure>
    </xsl:template>
    <xsl:template match="tei:graphic">
        <img src="{@url}" class="figure-img img-fluid rounded shadow-sm" alt="Immagine di Rupert Everett" />
    </xsl:template>
    <xsl:template match="tei:figure/tei:head">
        <figcaption class="figure-caption fw-bold text-dark fs-5 mt-3">
            <xsl:apply-templates/>
        </figcaption>
    </xsl:template>
    <xsl:template match="tei:figDesc">
        <p class="text-muted small mt-2 mb-0 px-4">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="tei:listPerson">
        <h3 class="mt-4 text-primary">
            Person List (Type: <xsl:value-of select="@type"/>)
        </h3>
        
        <div class="row">
            <xsl:for-each select="tei:person">
                <div class="col-md-4 mb-3">
                    <div class="card shadow-sm h-100" id="{@xml:id}">
                        <div class="card-body">
                            <h5 class="card-title">
                                <xsl:value-of select="tei:persName/tei:forename[@type='first']" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="tei:persName/tei:forename[@type='middle']" />
                                <xsl:text> </xsl:text> 
                                <xsl:value-of select="tei:persName/tei:surname" />
                            </h5>
                            
                            <p class="card-text text-muted mb-1">
                                <strong>Role: </strong> <xsl:value-of select="@role" />
                            </p>
                            
                            <xsl:if test="@sameAs">
                                <a href="{@sameAs}" target="_blank" class="btn btn-sm btn-outline-info mt-2">
                                    View Record (Authority File)
                                </a>
                            </xsl:if>
                        </div>
                    </div>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template match="tei:listBibl">
    <h3 class="mt-5 text-primary">Bibliographic Entities</h3>
    
    <div class="row mt-3">
            <xsl:for-each select="tei:bibl">
                <div class="col-md-6 mb-4">
                    <div class="card shadow-sm h-100" id="{@xml:id}">
                        
                        <div class="card-body">
                            <h5 class="card-title mb-3">
                                <xsl:if test="tei:title[1]/@level = 's'">
                                    <xsl:value-of select="tei:title[1]"/>
                                    <xsl:value-of select="tei:title[2]"/>
                                </xsl:if>
                                <xsl:if test="tei:title[1]/@level != 's'">
                                    <xsl:value-of select="tei:title[1]"/>
                                </xsl:if>
                                    <span class="badge ms-2 rounded-pill text-primary" style="font-size: 0.6em; text-transform: uppercase;">
                                        <xsl:value-of select="@type" />
                                    </span>
                            </h5>

                            <xsl:if test="count(tei:title) > 1">
                                <p class="text-muted small mb-3">
                                    <xsl:choose>
                                        <xsl:when test="tei:title[1]/@level = 's' and count(tei:title) > 2">
                                            <p class="text-muted small mb-3">
                                                <em>Other titles: </em>
                                                <xsl:for-each select="tei:title[position() >= 3]">
                                                    <xsl:value-of select="."/>
                                                    <xsl:if test="@xml:lang"> (<xsl:value-of select="@xml:lang"/>)</xsl:if>
                                                    <xsl:if test="position() != last()">, </xsl:if>
                                                </xsl:for-each>
                                            </p>
                                        </xsl:when>
                                        <xsl:when test="tei:title[1]/@level != 's' and count(tei:title) > 1">
                                            <p class="text-muted small mb-3">
                                                <em>Other titles: </em>
                                                <xsl:for-each select="tei:title[position() >= 2]">
                                                    <xsl:value-of select="."/>
                                                    <xsl:if test="@xml:lang"> (<xsl:value-of select="@xml:lang"/>)</xsl:if>
                                                    <xsl:if test="position() != last()">, </xsl:if>
                                                </xsl:for-each>
                                            </p>
                                        </xsl:when>

                                    </xsl:choose>
                                </p>
                            </xsl:if>

                            <xsl:if test="tei:author">
                                <p class="mb-2"><strong>Author: </strong>
                                    <xsl:for-each select="tei:author">
                                        <code><xsl:value-of select="substring-after(@ref, '#')"/></code>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </p>
                            </xsl:if>

                            <xsl:if test="tei:biblScope">
                                <p class="mb-1"><strong>Albo nr.: </strong> <xsl:value-of select="tei:biblScope"/></p>
                            </xsl:if>

                            <xsl:if test="tei:respStmt">
                                <p class="mb-1"><strong>Credits: </strong></p>
                                <ul class="list-unstyled mb-2 ms-3 border-start ps-2 border-secondary">
                                    <xsl:for-each select="tei:respStmt">
                                        <li>
                                            <small class="text-muted text-capitalize"><xsl:value-of select="tei:resp"/>:</small>
                                            <code class="ms-1"><xsl:value-of select="substring-after(tei:persName/@ref, '#')"/></code>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </xsl:if>

                            <xsl:if test="tei:date">
                                <p class="mb-1"><strong>Release Date: </strong> <xsl:value-of select="tei:date"/></p>
                            </xsl:if>
                        </div>

                        <div class="card-footer bg-transparent d-flex justify-content-between align-items-center">
                            <xsl:if test="@sameAs">
                                <a href="{@sameAs}" target="_blank" class="btn btn-sm btn-outline-info">
                                    View Record (Authority File)
                                </a>
                            </xsl:if>
                            
                            <xsl:if test="tei:idno">
                                <span class="badge text-bg-light border text-muted">
                                    SBN: <xsl:value-of select="tei:idno[1]"/>
                                </span>
                            </xsl:if>
                        </div>

                    </div>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template match="tei:listOrg">
        <h3 class="mt-4 text-primary">
            Organization List
        </h3>
        
        <div class="row">
            <xsl:for-each select="tei:org">
                <div class="col-md-4 mb-3">
                    <div class="card shadow-sm h-100" id="{@xml:id}">
                        <div class="card-body">
                            <h5 class="card-title">
                                <xsl:value-of select="tei:orgName" />
                            </h5>
                            
                            <p class="card-text text-muted mb-1">
                                <strong>Type: </strong> <xsl:value-of select="@type" />
                            </p>
                            
                            <xsl:if test="@sameAs">
                                <a href="{@sameAs}" target="_blank" class="btn btn-sm btn-outline-info mt-2">
                                    View Record (Authority File)
                                </a>
                            </xsl:if>
                        </div>
                    </div>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template match="tei:listRelation">
        <h3 class="mt-5 text-danger">Relation Graph (Triple)</h3>
        
        <table class="table table-striped table-hover table-bordered mt-3 shadow-sm">
            <thead class="table-dark">
                <tr>
                    <th>Subject (Active)</th>
                    <th>Property (Name)</th>
                    <th>Object (Passive)</th>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="tei:relation">
                    <tr>
                        <td><span class="badge bg-secondary"><xsl:value-of select="@active"/></span></td>
                        <td><code class="text-primary"><xsl:value-of select="@name"/></code></td>
                        <td><span class="badge bg-secondary"><xsl:value-of select="@passive"/></span></td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>
</xsl:stylesheet>