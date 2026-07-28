<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:import href="entities.xsl"/>

    <xsl:template match="tei:div">
        <div><xsl:apply-templates/></div>
    </xsl:template>
    <xsl:template match="tei:pb">
        <span class="anchor-pb"></span>
        <span class="pb" source="{@facs}"><xsl:value-of select="./@n"/></span>
    </xsl:template>
    <xsl:template match="tei:unclear">
        <abbr title="unclear"><xsl:apply-templates/></abbr>
    </xsl:template>
    <xsl:template match="tei:del">
        <del><xsl:apply-templates/></del>
    </xsl:template>
    <xsl:template match="tei:cit">
        <cite><xsl:apply-templates/></cite>
    </xsl:template>
    <xsl:template match="tei:quote">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:date">
        <span class="date"><xsl:apply-templates/></span>
    </xsl:template>
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>

    <xsl:template match="tei:note">
        <xsl:element name="a">
            <xsl:attribute name="name">
                <xsl:text>fna_</xsl:text>
                <xsl:number level="any" format="1" count="tei:note"/>
            </xsl:attribute>
            <xsl:attribute name="href">
                <xsl:text>#fn</xsl:text>
                <xsl:number level="any" format="1" count="tei:note"/>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:attribute>
            <sup>
                <xsl:number level="any" format="1" count="tei:note"/>
            </sup>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:list[@type='unordered']">
        <xsl:choose>
            <xsl:when test="ancestor::tei:body">
                <ul class="yes-index">
                    <xsl:apply-templates/>
                </ul>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:item">
        <xsl:choose>
            <xsl:when test="parent::tei:list[@type='unordered']|ancestor::tei:body">
                <li><xsl:apply-templates/></li>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:hi">
        <span>
            <xsl:choose>
                <xsl:when test="@rendition = '#em'">
                    <xsl:attribute name="class">
                        <xsl:text>italic</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@rendition = '#italic'">
                    <xsl:attribute name="class">
                        <xsl:text>italic</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@rendition = '#smallcaps'">
                    <xsl:attribute name="class">
                        <xsl:text>smallcaps</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@rendition = '#bold'">
                    <xsl:attribute name="class">
                        <xsl:text>bold</xsl:text>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:ref">
        <a class="ref {@type}" href="{@target}"><xsl:apply-templates/></a>
    </xsl:template>
    <xsl:template match="tei:lg">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    <xsl:template match="tei:l">
        <xsl:apply-templates/><br/>
    </xsl:template>
    <xsl:template match="tei:p">
       <p><xsl:apply-templates/></p>
    </xsl:template>
    
    <xsl:template match="tei:table">
        <xsl:element name="table">
            <xsl:attribute name="class">
                <xsl:text>table table-bordered table-striped table-condensed table-hover</xsl:text>
            </xsl:attribute>
            <xsl:element name="tbody">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:row">
        <xsl:element name="tr">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:cell">
        <xsl:element name="td">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:rs">
        <xsl:variable name="entity-class">
            <xsl:choose>
                <xsl:when test="@type = 'person'">persons</xsl:when>
                <xsl:when test="@type = 'place'">places</xsl:when>
                <xsl:when test="@type = ('work', 'bibl')">works</xsl:when>
                <xsl:when test="@type = ('org', 'institution')">orgs</xsl:when>
                <xsl:when test="@type = 'event'">events</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="entity-refs" select="tokenize(normalize-space(@ref), '\s+')"/>
        <xsl:variable name="multi-ref-id" select="concat('multi-', generate-id())"/>

        <xsl:choose>
            <xsl:when test="$entity-class != '' and count($entity-refs) > 1">
                <span class="{$entity-class} entity" data-bs-toggle="modal" data-bs-target="#{$multi-ref-id}">
                    <xsl:if test="$entity-class = 'orgs' and @xml:id">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@xml:id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="$entity-class != ''">
                <span class="{$entity-class} entity" data-bs-toggle="modal" data-bs-target="{$entity-refs[1]}">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:rs[@type = ('person', 'place', 'work', 'bibl', 'org', 'institution', 'event')][count(tokenize(normalize-space(@ref), '\s+')) > 1]" mode="multi-ref-modal">
        <xsl:variable name="context-rs" select="."/>
        <xsl:variable name="entity-refs" select="tokenize(normalize-space(@ref), '\s+')"/>
        <xsl:variable name="multi-ref-id" select="concat('multi-', generate-id())"/>
        <xsl:variable name="label" select="normalize-space(string-join(.//text()))"/>

        <div class="modal fade" id="{$multi-ref-id}" data-bs-keyboard="true" tabindex="-1" aria-label="{$label}" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h1 class="modal-title fs-5"><xsl:value-of select="$label"/></h1>
                    </div>
                    <div class="modal-body">
                        <xsl:for-each select="$entity-refs">
                            <xsl:variable name="entity-ref" select="."/>
                            <xsl:variable name="entity-node" select="root($context-rs)//tei:*[@xml:id = substring-after($entity-ref, '#')][1]"/>
                            <xsl:if test="$entity-node">
                                <xsl:for-each select="$entity-node">
                                    <xsl:call-template name="render-entity-section"/>
                                </xsl:for-each>
                            </xsl:if>
                            <xsl:if test="$entity-node and position() != last()">
                                <hr/>
                            </xsl:if>
                        </xsl:for-each>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Schließen</button>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="render-entity-title">
        <xsl:choose>
            <xsl:when test="self::tei:person">
                <xsl:value-of select="normalize-space(string-join(./tei:persName[1]//text()))"/>
            </xsl:when>
            <xsl:when test="self::tei:place">
                <xsl:value-of select="normalize-space(string-join(./tei:placeName[1]//text()))"/>
            </xsl:when>
            <xsl:when test="self::tei:org">
                <xsl:value-of select="normalize-space(string-join(./tei:orgName[1]//text()))"/>
            </xsl:when>
            <xsl:when test="self::tei:bibl">
                <xsl:value-of select="normalize-space(string-join(./tei:title[1]//text()))"/>
            </xsl:when>
            <xsl:when test="self::tei:event">
                <xsl:value-of select="normalize-space(string((./tei:eventName[1], @n, @xml:id)[1]))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="string(@xml:id)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="render-entity-detail">
        <xsl:choose>
            <xsl:when test="self::tei:person">
                <xsl:call-template name="person_detail"/>
            </xsl:when>
            <xsl:when test="self::tei:place">
                <xsl:call-template name="place_detail"/>
            </xsl:when>
            <xsl:when test="self::tei:org">
                <xsl:call-template name="org_detail"/>
            </xsl:when>
            <xsl:when test="self::tei:bibl">
                <xsl:call-template name="bibl_detail"/>
            </xsl:when>
            <xsl:when test="self::tei:event">
                <xsl:call-template name="event_detail"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="render-entity-section">
        <div class="mb-4">
            <h2 class="fs-6"><a href="{@xml:id}.html"><xsl:call-template name="render-entity-title"/></a></h2>
            <xsl:call-template name="render-entity-detail"/>
        </div>
    </xsl:template>

    <xsl:template name="render-entity-modal">
        <xsl:variable name="selfLink">
            <xsl:value-of select="concat(data(@xml:id), '.html')"/>
        </xsl:variable>
        <xsl:variable name="name">
            <xsl:call-template name="render-entity-title"/>
        </xsl:variable>

        <div class="modal fade" id="{@xml:id}" data-bs-keyboard="true" tabindex="-1" aria-label="{normalize-space($name)}" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h1 class="modal-title fs-5"><a href="{$selfLink}"><xsl:value-of select="normalize-space($name)"/></a></h1>
                    </div>
                    <div class="modal-body">
                        <xsl:call-template name="render-entity-detail"/>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Schließen</button>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="tei:listPerson">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:person | tei:place | tei:org | tei:bibl | tei:event[@xml:id]">
        <xsl:call-template name="render-entity-modal"/>
    </xsl:template>

    <xsl:template match="tei:listPlace">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:listOrg">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:listBibl">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:listEvent">
        <xsl:apply-templates select="tei:event[@xml:id]"/>
    </xsl:template>
</xsl:stylesheet>
