<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="urn:graphics"
    version="2.0"
    exclude-result-prefixes="tei xsl xs local">

    <xsl:variable name="hanslick-id" as="xs:string" select="'hsl_person_id_1'"/>
    <xsl:variable name="net-person-index" as="document-node()" select="doc(resolve-uri('../../data/indices/listperson.xml', static-base-uri()))"/>
    <xsl:variable name="net-doc-targets" as="xs:string*" select="distinct-values($net-person-index//tei:listPerson/tei:person/tei:noteGrp/tei:note[starts-with(string(@target), 'd__')]/string(@target))"/>
    <xsl:variable name="net-doc-editions" as="document-node()*">
        <xsl:for-each select="$net-doc-targets">
            <xsl:variable name="doc-uri" as="xs:anyURI" select="resolve-uri(concat('../../data/doc/editions/', .), static-base-uri())"/>
            <xsl:if test="doc-available($doc-uri)">
                <xsl:sequence select="doc($doc-uri)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>

    <xsl:function name="local:normalize-target" as="xs:string">
        <xsl:param name="target" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="starts-with($target, 't__')">t__VMS_TREATISE</xsl:when>
            <xsl:otherwise><xsl:sequence select="$target"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="local:pub-targets" as="xs:string*">
        <xsl:param name="person" as="element(tei:person)"/>
        <xsl:sequence select="distinct-values(for $target in $person/tei:noteGrp/tei:note[@type='mentions'][starts-with(string(@target), 't__') or starts-with(string(@target), 'w__') or starts-with(string(@target), 'v__')]/string(@target) return local:normalize-target($target))"/>
    </xsl:function>

    <xsl:function name="local:doc-mention-targets" as="xs:string*">
        <xsl:param name="person" as="element(tei:person)"/>
        <xsl:sequence select="distinct-values($person/tei:noteGrp/tei:note[@type='mentions'][starts-with(string(@target), 'd__')]/string(@target))"/>
    </xsl:function>

    <xsl:function name="local:doc-authored-targets" as="xs:string*">
        <xsl:param name="person" as="element(tei:person)"/>
        <xsl:variable name="person-ref" as="xs:string" select="concat('#', string($person/@xml:id))"/>
        <xsl:sequence select="distinct-values(for $doc in $net-doc-editions[.//tei:teiHeader//tei:author[@ref = $person-ref]] return string((($doc/tei:TEI/@xml:id)[1], tokenize(base-uri($doc), '/')[last()])[1]))"/>
    </xsl:function>

    <xsl:function name="local:node-group" as="xs:string">
        <xsl:param name="person" as="element(tei:person)"/>
        <xsl:param name="pub-count" as="xs:integer"/>
        <xsl:param name="doc-mention-count" as="xs:integer"/>
        <xsl:param name="doc-authored-count" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="string($person/@xml:id) = $hanslick-id">hanslick</xsl:when>
            <xsl:when test="$doc-authored-count gt 0">doc-author</xsl:when>
            <xsl:when test="$doc-mention-count gt 0 and $person/@role = 'fictional'">doc-character</xsl:when>
            <xsl:when test="$doc-mention-count gt 0">doc-person</xsl:when>
            <xsl:when test="$pub-count gt 0 and $person/@role = 'fictional'">pub-character</xsl:when>
            <xsl:otherwise>pub-person</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template name="net_container">
        <script src="vendor/graphology/graphology.umd.min.js" />
        <script src="vendor/sigma/sigma.min.js" />
        <script src="js/person-network.js" />
        <div id="graphic-container" class="graphic-container-padded">
            <xsl:variable name="graph-persons" as="element(tei:person)*" select="$net-person-index//tei:listPerson/tei:person"/>
            <xsl:variable name="graph-max-rel" as="xs:integer" select="max((1, for $person in $graph-persons return count(distinct-values((local:pub-targets($person), local:doc-mention-targets($person), local:doc-authored-targets($person))))))"/>

            <div class="person-network-panel">
                <div class="person-network-controls">
                    <div class="person-network-category-toggles">
                        <label>
                            <input type="checkbox" class="person-network-category-toggle" data-group="pub-person" checked="checked"/>Personen</label>
                        <label>
                            <input type="checkbox" class="person-network-category-toggle" data-group="pub-place" checked="checked"/>Orte</label>
                        <label>
                            <input type="checkbox" class="person-network-category-toggle" data-group="pub-work" checked="checked"/>Werke</label>
                    </div>
                    <div class="person-network-search-row">
                        <label for="person-network-node-search">Knoten suchen:</label>
                        <input id="person-network-node-search" class="person-network-search-input" type="text" list="person-network-node-options" placeholder="Name eingeben"/>
                        <button id="person-network-node-search-button" class="person-network-search-button" type="button">Zentrieren</button>
                        <datalist id="person-network-node-options"/>
                    </div>
                </div>
                <div id="person-network"></div>
                <div class="person-network-hint">Klicken oder tippen Sie auf einen Knoten, um Details und den Link zur Personenseite anzuzeigen. Zoomen mit Mausrad oder Touch-Geste.</div>
                <div class="person-network-legend">
                    <span>
                        <i class="person-network-swatch-person"></i>Personen</span>
                    <span>
                        <i class="person-network-swatch-place"></i>Orte</span>
                    <span>
                        <i class="person-network-swatch-work"></i>Werke</span>
                </div>

                <div id="person-network-data" class="d-none" data-hanslick-id="{$hanslick-id}" data-max-rel="{$graph-max-rel}" data-source="data/person-network-data.json"/>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>
