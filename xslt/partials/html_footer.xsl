<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:template name="html_footer">
        <footer class="py-3">
        <div class="container text-center">
            <div class="d-flex align-items-center gap-2 border-bottom pb-3 mb-4" style="color: #444;"><i class="bi bi-chat"
                    style="font-size: 1.125rem;"></i><span class="fw-medium" style="font-size: 0.875rem;">Kontakt</span></div>
            <div class="row justify-content-md-center">
                <div class="col col-lg-4">
                    <div><a href="https://www.oeaw.ac.at/acdh/acdh-home">
                            <img class="footerlogo" src="images/logo.png" alt="ACDH logo"/></a></div>
                    <div class="text-center p-4">
                        ACDH Austrian Centre for Digital Humanities Österreichische
                        Akademie der Wissenschaften
                        <br/><a href="mailto:acdh-helpdesk@oeaw.ac.at">acdh-helpdesk@oeaw.ac.at</a>
                    </div>
                </div>
                <div class="col col-lg-4"></div>
                <div class="col col-lg-4">
                    <div>
                        <a href="https://www.mdw.ac.at/imi/"><img
                                class="footerlogo" src="images/mdwLogoohne.svg"
                                alt="Universität für Musik und Darstellende Kunst Wien logo"/></a>
                    </div>
                    <div class="text-center p-4">
                        Institut für Musikwissenschaft und Interpretationsforschung (IMI); Universität für Musik und Darstellende Kunst Wien
                        <br/><a href="mailto:rost@mdw.ac.at">rost@mdw.ac.at</a>
                    </div>
                </div>
            </div>
        </div>
        <div class="text-center">
            <a href="https://github.com/acdh-oeaw/eurotort">
                <i aria-hidden="true" class="bi bi-github fs-2"></i>
                <span class="visually-hidden">GitHub repo</span>
            </a>
        </div>
        
        </footer>
        <script src="vendor/jquery/jquery-3.7.1.min.js"></script>
        <script src="vendor/bootstrap-5.3.5-dist/js/bootstrap.bundle.min.js"></script>
        
    </xsl:template>
</xsl:stylesheet>