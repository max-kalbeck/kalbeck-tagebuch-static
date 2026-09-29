<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    <xsl:template name="blockquote">
        <xsl:param name="pageId" select="''"></xsl:param>
        <xsl:param name="currentTitle" select="false()"></xsl:param>
        <xsl:param name="customUrl" select="$base_url"></xsl:param>
        <xsl:variable name="fullUrl" select="concat($customUrl, $pageId)"/>
        <xsl:variable name="modalId" select="concat('citation-', generate-id())"/>
        <xsl:variable name="bibKey" select="replace($pageId, '\.html$', '')"/>
        <xsl:variable name="year" select="format-date(current-date(), '[Y0001]')"/>
        <xsl:variable name="monthNameDE" select="('Jänner', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember')[month-from-date(current-date())]"/>
        <xsl:variable name="accessDate" select="concat(day-from-date(current-date()), '. ', $monthNameDE, ' ', $year)"/>
        <xsl:variable name="entryAuthor" select="root(.)//tei:titleStmt/tei:author[1]"/>
        <xsl:variable name="isKalbeckAuthor" select="boolean($entryAuthor[normalize-space(.) = 'Kalbeck, Max' or @ref = '#pmb11857'])"/>

        <div>
            <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-toggle="modal" data-bs-target="#{$modalId}">
                Zitiervorschlag
            </button>

            <div class="modal fade" id="{$modalId}" data-bs-keyboard="true" tabindex="-1" aria-label="Zitiervorschlag" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h1 class="modal-title fs-5">Zitiervorschlag</h1>
                        </div>
                        <div class="modal-body">
                            <div class="meta-caption">Empfohlene Zitierweise</div>
                            <blockquote class="blockquote" style="text-align:left!important; padding-left:2em; text-indent:-2em;">
                                <xsl:choose>
                                    <xsl:when test="$currentTitle and $isKalbeckAuthor">
                                        <p>
                                            Kalbeck, Max: <xsl:value-of select="$currentTitle"/>, in: <xsl:value-of select="$project_title"/>, herausgegeben von Henrike Rost, Wien 2026 (<a href="{$fullUrl}"><xsl:value-of select="$fullUrl"/></a>)
                                        </p>
                                    </xsl:when>
                                    <xsl:when test="$currentTitle">
                                        <p>
                                            <xsl:value-of select="$currentTitle"/>, in: <xsl:value-of select="$project_title"/>, herausgegeben von Henrike Rost, Wien 2026 (<a href="{$fullUrl}"><xsl:value-of select="$fullUrl"/></a>)
                                        </p>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <p>
                                            <xsl:value-of select="$project_title"/>, herausgegeben von Henrike Rost, Wien 2026 (<a href="{$fullUrl}"><xsl:value-of select="$fullUrl"/></a>)
                                        </p>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </blockquote>
                            <div class="meta-caption">APA</div>
                            <blockquote class="blockquote" style="text-align:left!important; padding-left:2em; text-indent:-2em;">
                                <xsl:choose>
                                    <xsl:when test="$currentTitle and $isKalbeckAuthor">
                                        <p>
                                            Kalbeck, M. (<xsl:value-of select="$year"/>). <xsl:value-of select="$currentTitle"/>. In H. Rost (Hrsg.), <i><xsl:value-of select="$project_title"/></i>. Abgerufen am <xsl:value-of select="$accessDate"/>, von <a href="{$fullUrl}"><xsl:value-of select="$fullUrl"/></a>
                                        </p>
                                    </xsl:when>
                                    <xsl:when test="$currentTitle">
                                        <p>
                                            <xsl:value-of select="$currentTitle"/>. (<xsl:value-of select="$year"/>). In H. Rost (Hrsg.), <i><xsl:value-of select="$project_title"/></i>. Abgerufen am <xsl:value-of select="$accessDate"/>, von <a href="{$fullUrl}"><xsl:value-of select="$fullUrl"/></a>
                                        </p>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <p>
                                            Rost, H. (Hrsg.). (<xsl:value-of select="$year"/>). <i><xsl:value-of select="$project_title"/></i>. Abgerufen am <xsl:value-of select="$accessDate"/>, von <a href="{$fullUrl}"><xsl:value-of select="$fullUrl"/></a>
                                        </p>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </blockquote>
                            <div class="meta-caption">MLA</div>
                            <blockquote class="blockquote" style="text-align:left!important; padding-left:2em; text-indent:-2em;">
                                <xsl:choose>
                                    <xsl:when test="$currentTitle and $isKalbeckAuthor">
                                        <p>
                                            Kalbeck, Max. „<xsl:value-of select="$currentTitle"/>.“ <i><xsl:value-of select="$project_title"/></i>, herausgegeben von Henrike Rost, <xsl:value-of select="$year"/>, <a href="{$fullUrl}"><xsl:value-of select="$fullUrl"/></a>. Zugriff am <xsl:value-of select="$accessDate"/>.
                                        </p>
                                    </xsl:when>
                                    <xsl:when test="$currentTitle">
                                        <p>
                                            „<xsl:value-of select="$currentTitle"/>.“ <i><xsl:value-of select="$project_title"/></i>, herausgegeben von Henrike Rost, <xsl:value-of select="$year"/>, <a href="{$fullUrl}"><xsl:value-of select="$fullUrl"/></a>. Zugriff am <xsl:value-of select="$accessDate"/>.
                                        </p>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <p>
                                            <i><xsl:value-of select="$project_title"/></i>. Herausgegeben von Henrike Rost, <xsl:value-of select="$year"/>, <a href="{$fullUrl}"><xsl:value-of select="$fullUrl"/></a>. Zugriff am <xsl:value-of select="$accessDate"/>.
                                        </p>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </blockquote>
                             <div class="meta-caption">BibTeX</div>
                            <blockquote class="blockquote text-left">
                                <xsl:choose>
                                    <xsl:when test="$currentTitle and $isKalbeckAuthor">
                                        <pre  style="text-align:left!important;"><code>@incollection{<xsl:value-of select="$bibKey"/>,
	author      = {Kalbeck, Max},
	title       = {<xsl:value-of select="$currentTitle"/>},
	date        = {<xsl:value-of select="format-date(current-date(), '[Y0001]')"/>},
	address     = {Wien},
	editor      = {Rost, Henrike},
	booktitle   = {<xsl:value-of select="$project_title"/>},
	url         = {<xsl:value-of select="$fullUrl"/>}
}</code></pre>
                                    </xsl:when>
                                    <xsl:when test="$currentTitle">
                                        <pre  style="text-align:left!important;"><code>@incollection{<xsl:value-of select="$bibKey"/>,
	title       = {<xsl:value-of select="$currentTitle"/>},
	date        = {<xsl:value-of select="format-date(current-date(), '[Y0001]')"/>},
	address     = {Wien},
	editor      = {Rost, Henrike},
	booktitle   = {<xsl:value-of select="$project_title"/>},
	url         = {<xsl:value-of select="$fullUrl"/>}
}</code></pre>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <pre style="text-align:left!important;"><code>@collection{rost_2026,
	title       = {<xsl:value-of select="$project_title"/>},
	date        = {<xsl:value-of select="format-date(current-date(), '[Y0001]')"/>},
	url         = {<xsl:value-of select="$fullUrl"/>},
	editor      = {Rost, Henrike},
	langid      = {German},
	address     = {Wien}
}</code></pre>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </blockquote>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Schließen</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>
