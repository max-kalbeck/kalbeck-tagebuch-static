<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:template name="blockquote">
        <xsl:param name="pageId" select="''"></xsl:param>
        <xsl:param name="currentTitle" select="false()"></xsl:param>
        <xsl:param name="customUrl" select="$base_url"></xsl:param>
        <xsl:variable name="fullUrl" select="concat($customUrl, $pageId)"/>
        
        <div>
            <h2 class="fs-4">Zitiervorschlag</h2>
            <blockquote class="blockquote">
                <xsl:choose>
                    <xsl:when test="$currentTitle">
                        <p>
                            <xsl:value-of select="$currentTitle"/>, in: <xsl:value-of select="$project_title"/>, herausgegeben von Henrike Rost, Wien 2025 (<a href="{$fullUrl}"><xsl:value-of select="$fullUrl"/></a>)
                        </p>
                    </xsl:when>
                    <xsl:otherwise>
                        <p>
                            <xsl:value-of select="$project_title"/>, herausgegeben von Henrike Rost, Wien 2025 (<a href="{$fullUrl}"><xsl:value-of select="$fullUrl"/></a>)
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
                
            </blockquote>
        </div>
    </xsl:template>
</xsl:stylesheet>