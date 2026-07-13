<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
        <html>
            <body>
                <div class="container-fluid bg-white mt-4 p-4 rounded shadow">
                    <h1 class="text-center mb-5">Dylan Dog Database</h1>

                    <xsl:apply-templates select="//tei:particDesc/tei:listPerson" />

                    <hr class="my-5" />

                    <xsl:apply-templates select="//tei:settingDesc/tei:listPlace" />

                    <hr class="my-5" />
 
                    <xsl:apply-templates select="//tei:particDesc/tei:listOrg" />

                    <hr class="my-5" />

                    <xsl:apply-templates select="//tei:sourceDesc/tei:listBibl" />
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:listPerson">
        <h3 class="mt-4">
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
                                <a href="{@sameAs}" target="_blank" class="btn btn-dark rounded-0 fw-bold">
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
    <h3 class="mt-5">Bibliographic Entities</h3>
    
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
                                    <span class="badge ms-2 rounded-pill text-white" style="font-size: 0.6em; text-transform: uppercase;">
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
                                <a href="{@sameAs}" target="_blank" class="btn btn-dark rounded-0 fw-bold">
                                    View Record (Authority File)
                                </a>
                            </xsl:if>
                            
                            <xsl:if test="tei:idno">
                                <span class="badge text-bg-light border border-secondary rounded-pill small">
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
        <h3 class="mt-4">
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
                                <a href="{@sameAs}" target="_blank" class="btn btn-dark rounded-0 fw-bold">
                                    View Record (Authority File)
                                </a>
                            </xsl:if>
                        </div>
                    </div>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template match="tei:listPlace">
        <h3 class="mt-4">
            Place List
        </h3>
        
        <div class="row">
            <xsl:for-each select="tei:place">
                <div class="col-md-4 mb-3">
                    <div class="card shadow-sm h-100" id="{@xml:id}">
                        <div class="card-body">
                            <h5 class="card-title">
                                <xsl:value-of select="tei:placeName" />
                            </h5>
                            
                            <xsl:if test="@sameAs">
                                <a href="{@sameAs}" target="_blank" class="btn btn-dark rounded-0 fw-bold">
                                    View Record (Authority File)
                                </a>
                            </xsl:if>
                        </div>
                    </div>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>
</xsl:stylesheet>