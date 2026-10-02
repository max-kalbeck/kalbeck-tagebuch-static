<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="urn:entities"
    version="3.0" exclude-result-prefixes="xsl tei xs local">

    <!-- computes the 'authority:ID' display label for an idno; @subtype names the source register
         so mirrored pmb links from different sister projects aren't all shown under the same 'pmb:' label -->
    <xsl:function name="local:idno-label" as="xs:string">
        <xsl:param name="idno" as="element(tei:idno)"/>
        <xsl:variable name="value" select="string($idno)"/>
        <xsl:variable name="subtype" select="string($idno/@subtype)"/>
        <xsl:choose>
            <xsl:when test="not(starts-with($value, 'http'))">
                <xsl:sequence select="$value"/>
            </xsl:when>
            <xsl:when test="matches($value, 'gnd/[0-9Xx-]+')">
                <xsl:sequence select="concat('gnd:', replace($value, '^.*gnd/([^/]+)$', '$1'))"/>
            </xsl:when>
            <xsl:when test="matches($value, '10\.\d{4,9}/')">
                <xsl:sequence select="concat('doi:', replace($value, '^.*?(10\.\d{4,9}/.*)$', '$1'))"/>
            </xsl:when>
            <xsl:when test="matches($value, 'wikidata\.org/(entity|wiki)/Q\d+')">
                <xsl:sequence select="concat('wikidata:', replace($value, '^.*/(Q\d+).*$', '$1'))"/>
            </xsl:when>
            <xsl:when test="matches($value, 'geonames\.org/\d+')">
                <xsl:sequence select="concat('geonames:', replace($value, '^.*geonames\.org/(\d+).*$', '$1'))"/>
            </xsl:when>
            <xsl:when test="$subtype = 'pmb' and matches($value, 'pmb\D*?(\d+)(\.html)?/?$')">
                <xsl:sequence select="concat('pmb:', replace($value, '^.*pmb\D*?(\d+)(\.html)?/?$', '$1'))"/>
            </xsl:when>
            <xsl:when test="$subtype != '' and matches($value, 'pmb\d+')">
                <xsl:sequence select="concat($subtype, ':', replace($value, '^.*?pmb(\d+).*$', '$1'))"/>
            </xsl:when>
            <xsl:when test="$subtype != ''">
                <xsl:sequence select="$subtype"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:variable name="month-names" as="map(xs:string, xs:string)">
        <xsl:map>
            <xsl:map-entry key="'01'" select="'Jänner'"/>
            <xsl:map-entry key="'02'" select="'Februar'"/>
            <xsl:map-entry key="'03'" select="'März'"/>
            <xsl:map-entry key="'04'" select="'April'"/>
            <xsl:map-entry key="'05'" select="'Mai'"/>
            <xsl:map-entry key="'06'" select="'Juni'"/>
            <xsl:map-entry key="'07'" select="'Juli'"/>
            <xsl:map-entry key="'08'" select="'August'"/>
            <xsl:map-entry key="'09'" select="'September'"/>
            <xsl:map-entry key="'10'" select="'Oktober'"/>
            <xsl:map-entry key="'11'" select="'November'"/>
            <xsl:map-entry key="'12'" select="'Dezember'"/>
        </xsl:map>
    </xsl:variable>

    <!-- turns an ISO "yyyy-mm-dd" date into "d. Monatsname yyyy"; anything else (years only,
         "vor 1935", "Juni 1942", etc.) is passed through unchanged -->
    <xsl:function name="local:format-date" as="xs:string">
        <xsl:param name="date" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="matches($date, '^\d{4}-\d{2}-\d{2}$')">
                <xsl:variable name="year" select="substring($date, 1, 4)"/>
                <xsl:variable name="month" select="substring($date, 6, 2)"/>
                <xsl:variable name="day" select="substring($date, 9, 2)"/>
                <xsl:sequence select="concat(xs:integer($day), '. ', $month-names($month), ' ', $year)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$date"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template name="render-idno-list">
        <xsl:if test="./tei:idno">
            <dt>Identifiers</dt>
            <xsl:for-each select="./tei:idno">
                <xsl:sort select="local:idno-label(.)"/>
                <xsl:variable name="label" select="local:idno-label(.)"/>
                <dd>
                    <xsl:choose>
                        <xsl:when test="starts-with(./text(), 'http')">
                            <a href="{./text()}">
                                <xsl:value-of select="$label"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$label"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </dd>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

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
            <xsl:call-template name="render-idno-list"/>
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
            <xsl:if test="./tei:note">
                <dt>Notiz</dt>
                <dd>
                    <xsl:value-of select="./tei:note"/>
                </dd>
            </xsl:if>
            <xsl:call-template name="render-idno-list"/>
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
                      <img src="{$person-image}" alt="{normalize-space(string-join(./tei:persName[1]//text(), ' '))}" class="img-fluid"/>
                </dd>
            </xsl:if>

            <xsl:variable name="birth-date" select="local:format-date(string(./tei:birth/tei:date))"/>
            <xsl:variable name="birth-place" select="string(./tei:birth/tei:place)"/>
            <xsl:variable name="death-date" select="local:format-date(string(./tei:death/tei:date))"/>
            <xsl:variable name="death-place" select="string(./tei:death/tei:place)"/>

            <xsl:variable name="birth">
                <xsl:choose>
                    <xsl:when test="$birth-date != '' and $birth-place != ''">
                        <xsl:value-of select="concat($birth-date, ', ', $birth-place)"/>
                    </xsl:when>
                    <xsl:when test="$birth-date != ''">
                        <xsl:value-of select="$birth-date"/>
                    </xsl:when>
                    <xsl:when test="$birth-place != ''">
                        <xsl:value-of select="$birth-place"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="death">
                <xsl:choose>
                    <xsl:when test="$death-date != '' and $death-place != ''">
                        <xsl:value-of select="concat($death-date, ', ', $death-place)"/>
                    </xsl:when>
                    <xsl:when test="$death-date != ''">
                        <xsl:value-of select="$death-date"/>
                    </xsl:when>
                    <xsl:when test="$death-place != ''">
                        <xsl:value-of select="$death-place"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>

            <xsl:if test="$birth != ''">
                <dt>Geboren</dt>
                <dd>
                    <xsl:value-of select="$birth"/>
                </dd>
            </xsl:if>
            <xsl:if test="$death != ''">
                <dt>Gestorben</dt>
                <dd>
                    <xsl:value-of select="$death"/>
                </dd>
            </xsl:if>
            <xsl:call-template name="render-idno-list"/>
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
            <xsl:call-template name="render-idno-list"/>
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
            <xsl:call-template name="render-idno-list"/>
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
