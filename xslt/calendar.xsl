<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes" omit-xml-declaration="yes"/>

    <xsl:import href="./partials/html_navbar.xsl" />
    <xsl:import href="./partials/html_head.xsl" />
    <xsl:import href="./partials/html_footer.xsl" />
    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select="'Kalender'" />
        </xsl:variable>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html xmlns="http://www.w3.org/1999/xhtml" lang="de">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title" />
                </xsl:call-template>
            </head>
            <body class="d-flex flex-column h-100">
                <script src="https://unpkg.com/js-year-calendar@latest/dist/js-year-calendar.min.js" />
                <script src="https://unpkg.com/js-year-calendar@latest/locales/js-year-calendar.de.js" />
                <link rel="stylesheet" type="text/css" href="https://unpkg.com/js-year-calendar@latest/dist/js-year-calendar.min.css" />
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>

                    <main class="flex-shrink-0 flex-grow-1">
                        <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb" class="ps-5 p-3">
                            <ol class="breadcrumb">
                                <li class="breadcrumb-item">
                                    <a href="index.html">
                                        <xsl:value-of select="$project_short_title"/>
                                    </a>
                                </li>
                                <li class="breadcrumb-item active" aria-current="page">
                                    <xsl:value-of select="$doc_title"/>
                                </li>
                            </ol>
                        </nav>
                        <div class="container">
                            <h1><xsl:value-of select="$doc_title"/></h1>
                            <div class="card-body containingloader">
                                <div class="row">
                                    <div class="col-sm-2 yearscol">
                                        <div class="row">
                                            <div class="col-sm-12">
                                                <p style="text-align:center;font-weight:bold;margin-bottom:0;">
                                                    Jahr
                                                </p>
                                            </div>
                                        </div>
                                        <div class="row justify-content-md-center" id="years-table" />
                                    </div>
                                    <div class="col-sm-10">
                                        <div id="calendar"/>
                                    </div>
                                </div>
                            </div>
                            <div class="dlinks">
                                  <a style="padding-left:5px;" target="_blank" href="calendarData.json" download="Kalbeck-Kalenderdaten.json">
                                    <i class="bi bi-box-arrow-down" title="Kalenderdaten herunterladen" />
                                </a>
                            </div>
                        </div>
                    </main>

                    <div class="modal" tabindex="-1" role="dialog" id="exampleModal">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">Das Tagebuch in Kalenderansicht</h5>
                                </div>
                                <div class="modal-body">
                                    <p>
                                        Über den Kalender können bestimmte Tage direkt aufgefunden werden.
                                    </p>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <script type="text/javascript" src="js/calendar.js" charset="UTF-8" />
                    <div id="loadModal" />

                    <xsl:call-template name="html_footer" />
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>