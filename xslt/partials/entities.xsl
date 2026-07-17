<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="3.0" exclude-result-prefixes="xsl tei xs">

    <xsl:template match="tei:bibl" name="bibl_detail">
        <dl>
            <xsl:if test="./tei:author">
                <dt>Autor*innen</dt>
                <xsl:for-each select="./tei:author">
                    <dd>
                        <xsl:choose>
                            <xsl:when test="@key">
                                <a href="{@key}.html">
                                    <xsl:value-of select="string-join(.//text())"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="string-join(.//text())"/>
                            </xsl:otherwise>
                        </xsl:choose>

                    </dd>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="./tei:date">
                <dt>Datum</dt>
                <dd>
                    <xsl:value-of select="./tei:date"/>
                </dd>
            </xsl:if>
            <xsl:if test="./tei:idno">
                <dt>Identifiers</dt>
                <xsl:for-each select="./tei:idno">
                    <dd>
                        <xsl:choose>
                            <xsl:when test="starts-with(./text(), 'http')">
                                <a href="{./text()}">
                                    <xsl:value-of select="."/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="./tei:noteGrp/tei:note[@type = 'mentions']">
                <dt>Erwähnt in</dt>
                <xsl:for-each select="./tei:noteGrp/tei:note[@type = 'mentions']">
                    <dd>
                        <a href="{replace(@target, '.xml', '.html')}">
                            <xsl:value-of select="./text()"/>
                        </a>
                    </dd>
                </xsl:for-each>
            </xsl:if>
        </dl>
    </xsl:template>

    <xsl:template match="tei:org" name="org_detail">
        <dl>
            <xsl:if test="./tei:orgName">
                <dt>Name</dt>
                <xsl:for-each select="./tei:orgName">
                    <dd>
                        <xsl:value-of select="."/>
                    </dd>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="./tei:desc">
                <dt>Beschreibung</dt>
                <dd>
                    <xsl:value-of select="./tei:desc"/>
                </dd>
            </xsl:if>
            <xsl:if test="./tei:idno">
                <dt>Identifiers</dt>
                <xsl:for-each select="./tei:idno">
                    <dd>
                        <xsl:choose>
                            <xsl:when test="starts-with(./text(), 'http')">
                                <a href="{./text()}">
                                    <xsl:value-of select="."/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="./tei:note">
                <dt>Notiz</dt>
                <dd>
                    <xsl:value-of select="./tei:note"/>
                </dd>
            </xsl:if>
            <xsl:if test="./tei:noteGrp/tei:note[@type = 'mentions']">
                <dt>Erwähnt in</dt>
                <xsl:for-each select="./tei:noteGrp/tei:note[@type = 'mentions']">
                    <dd>
                        <a href="{replace(@target, '.xml', '.html')}">
                            <xsl:value-of select="./text()"/>
                        </a>
                    </dd>
                </xsl:for-each>
            </xsl:if>
        </dl>
    </xsl:template>

    <xsl:template match="tei:person" name="person_detail">
        <xsl:variable name="person-xml-id" select="string(@xml:id)"/>
        <xsl:variable name="person-index" select="doc(resolve-uri(concat('../../data/indices/list', local-name(), '.xml'), static-base-uri()))"/>
        <xsl:variable name="person-image" select="string((
            ./tei:figure/tei:graphic/@url,
            root(.)//tei:person[@xml:id = $person-xml-id]/tei:figure/tei:graphic/@url,
            $person-index//tei:person[@xml:id = $person-xml-id]/tei:figure/tei:graphic/@url
        )[1])"/>

        <dl>
            <xsl:if test="$person-image != ''">
                <dd>
                    <img src="{$person-image}" alt="{normalize-space(string-join(./tei:persName[1]//text()))}" class="img-fluid"/>
                </dd>
            </xsl:if>
             <xsl:if test="./tei:birth/tei:date">
                 <dd>
                    <xsl:value-of select="./tei:birth/tei:date"/>
                </dd>
             </xsl:if>

            <xsl:if test="./tei:birth/tei:date">
                <dt>Geburtsdatum</dt>
                <dd>
                    <xsl:value-of select="./tei:birth/tei:date"/>
                </dd>
            </xsl:if>
            <xsl:if test="./tei:death/tei:date">
                <dt>Sterbedatum</dt>
                <dd>
                    <xsl:value-of select="./tei:death/tei:date"/>
                </dd>
            </xsl:if>
            <xsl:if test="./tei:idno">
                <dt>Identifiers</dt>
                <xsl:for-each select="./tei:idno">
                    <dd>
                        <xsl:choose>
                            <xsl:when test="starts-with(./text(), 'http')">
                                <a href="{./text()}">
                                    <xsl:value-of select="."/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="./tei:noteGrp/tei:note[@type = 'mentions']">
                <dt>Erwähnt in</dt>
                <dd>
                    <xsl:for-each select="./tei:noteGrp/tei:note[@type = 'mentions']">
                        <a href="{replace(@target, '.xml', '.html')}">
                            <xsl:value-of select="./text()"/>
                        </a>
                    </xsl:for-each>
                </dd>
            </xsl:if>
        </dl>
    </xsl:template>

    <xsl:template match="tei:event" name="event_detail">
        <dl>
            <xsl:if test="./@when-iso">
                <dt>Datum</dt>
                <dd>
                    <xsl:value-of select="./@when-iso"/>
                </dd>
            </xsl:if>
            <xsl:if test="./tei:eventName">
                <dt>Bezeichnung</dt>
                <xsl:for-each select="./tei:eventName">
                    <dd>
                        <xsl:value-of select="normalize-space(string-join(.//text()))"/>
                    </dd>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="./tei:note[@type = 'listorg']/tei:listOrg/tei:org">
                <dt>Veranstaltet von</dt>
                <xsl:for-each select="./tei:note[@type = 'listorg']/tei:listOrg/tei:org">
                    <dd>
                        <xsl:choose>
                            <xsl:when test="./tei:orgName/@key">
                                <a href="{./tei:orgName/@key}.html">
                                    <xsl:value-of select="normalize-space(string-join(./tei:orgName//text()))"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(string-join(./tei:orgName//text()))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="@role">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="@role"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </dd>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="./tei:listPlace/tei:place">
                <dt>Ort</dt>
                <xsl:for-each select="./tei:listPlace/tei:place">
                    <dd>
                        <xsl:choose>
                            <xsl:when test="./tei:placeName/@key">
                                <a href="{./tei:placeName/@key}.html">
                                    <xsl:value-of select="normalize-space(string-join(./tei:placeName//text()))"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(string-join(./tei:placeName//text()))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="./tei:placeName/@role">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="./tei:placeName/@role"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </dd>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="./tei:listPerson/tei:person">
                <dt>Beteiligte</dt>
                <xsl:for-each select="./tei:listPerson/tei:person">
                    <dd>
                        <xsl:choose>
                            <xsl:when test="./tei:persName/@key">
                                <a href="{./tei:persName/@key}.html">
                                    <xsl:value-of select="normalize-space(string-join(./tei:persName//text()))"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(string-join(./tei:persName//text()))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="@role">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="@role"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </dd>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="./tei:listBibl/tei:bibl[not(@type = 'collections')]">
                <dt>Werke</dt>
                <xsl:for-each select="./tei:listBibl/tei:bibl[not(@type = 'collections')]">
                    <dd>
                        <xsl:choose>
                            <xsl:when test="./tei:title/@key">
                                <a href="{./tei:title/@key}.html">
                                    <xsl:value-of select="normalize-space(string-join(./tei:title//text()))"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(string-join(./tei:title//text()))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="./tei:note[@type = 'relation-type']">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="./tei:note[@type = 'relation-type'][1]"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </dd>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="./tei:idno">
                <dt>Identifiers</dt>
                <xsl:for-each select="./tei:idno">
                    <dd>
                        <xsl:choose>
                            <xsl:when test="starts-with(./text(), 'http')">
                                <a href="{./text()}">
                                    <xsl:value-of select="."/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="./tei:noteGrp/tei:note[@type = 'mentions']">
                <dt>Erwähnt in</dt>
                <xsl:for-each select="./tei:noteGrp/tei:note[@type = 'mentions']">
                    <dd>
                        <a href="{replace(@target, '.xml', '.html')}">
                            <xsl:value-of select="./text()"/>
                        </a>
                    </dd>
                </xsl:for-each>
            </xsl:if>
        </dl>
    </xsl:template>
    
    <xsl:template match="tei:place" name="place_detail">
        <dl>
            <dt>Ortsname</dt>
            <dd>
                <xsl:choose>
                    <xsl:when test="./tei:settlement/tei:placeName">
                        <xsl:value-of select="./tei:settlement/tei:placeName"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="./tei:placeName"/>
                    </xsl:otherwise>
                </xsl:choose>
            </dd>
            <xsl:if test="./tei:location[@type = 'located_in_place']">
                <dt>Teil von</dt>
                <xsl:for-each select="./tei:location[@type = 'located_in_place']">
                    <dd>
                        <a href="{./tei:placeName/@key}.html">
                            <xsl:value-of select="./tei:placeName"/>
                        </a>
                    </dd>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="./tei:country">
                <dt>Land</dt>
                <dd>
                    <xsl:value-of select="./tei:country"/>
                </dd>
            </xsl:if>
            <xsl:if test="./tei:settlement">
                <dt>Ortstyp</dt>
                <dd>
                    <xsl:value-of select="./tei:settlement/@type"/>, <xsl:value-of
                        select="./tei:desc[@type = 'entity_type']"/>
                </dd>
            </xsl:if>
            <xsl:if test="./tei:idno">
                <dt>Identifiers</dt>
                <xsl:for-each select="./tei:idno">
                    <dd>
                        <xsl:choose>
                            <xsl:when test="starts-with(./text(), 'http')">
                                <a href="{./text()}">
                                    <xsl:value-of select="."/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test=".//tei:location">
                <dt>Breitengrad</dt>
                <dd>
                    <xsl:value-of select="tokenize(./tei:location[1]/tei:geo[1], '\s')[1]"/>
                </dd>
            </xsl:if>
            <xsl:if test=".//tei:location">
                
                <dt>Längengrad</dt>
                <dd>
                    <xsl:value-of select="tokenize(./tei:location[1]/tei:geo[1], '\s')[2]"/>
                </dd>
            </xsl:if>
            <xsl:if test="./tei:noteGrp/tei:note[@type = 'mentions']">
                <dt>Erwähnt in</dt>
                <xsl:for-each select="./tei:noteGrp/tei:note[@type = 'mentions']">
                    <dd>
                        <a href="{replace(@target, '.xml', '.html')}">
                            <xsl:value-of select="./text()"/>
                        </a>
                    </dd>
                </xsl:for-each>
            </xsl:if>
        </dl>
    </xsl:template>
</xsl:stylesheet>
