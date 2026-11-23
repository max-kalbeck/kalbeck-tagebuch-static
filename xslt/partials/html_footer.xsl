<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <xsl:template name="html_footer">
        <footer class="py-3">
            <div class="container">
                <div class="row mobile-hide">
                    <div class="col col-lg-10 d-flex align-items-center gap-2 border-bottom pb-3 mb-2" style="color: var(--kb-color);">
                        <i class="bi bi-chat" style="font-size: 1.125rem;"></i>
                        <span class="fw-medium" style="font-size: 0.875rem;">Kontakt</span>
                    </div>
                    <div class="col col-lg-2 d-flex align-items-center gap-2 border-bottom pb-3 mb-2" style="color: var(--kb-color);">
                        <i class="bi bi-chat" style="font-size: 1.125rem;"></i>
                        <span class="fw-medium" style="font-size: 0.875rem;">Förderung</span>
                    </div>
                </div>
                <div class="row text-left">
                    <div class="col-6 col-lg-3">
                        <div>
                            <a href="https://www.oeaw.ac.at">
                                <img class="footerlogo" src="images/logo_oeaw_bw.svg" alt="ÖAW logo"/>
                            </a>
                        </div>
                    </div>
                    <div class="col-6 col-lg-3">
                        <div>
                            <a href="https://www.oeaw.ac.at/acdh/acdh-home">
                                <img class="footerlogo" src="images/logo_acdh.svg" alt="ACDH logo"/>
                            </a>
                        </div>
                        <div class="align-left mobile-hide">
                            Bäckerstraße 13<br />
                            1010 Wien<br/>
                            <a href="mailto:acdh-helpdesk@oeaw.ac.at">acdh-helpdesk@oeaw.ac.at</a>
                        </div>
                    </div>
                    <div class="col-6 col-lg-3">
                        <div class="justify-content-md-center text-center">
                            <a href="https://www.mdw.ac.at/imi/">
                                <img class="footerlogo" src="images/mdwLogoohne.png" alt="Universität für Musik und Darstellende Kunst Wien logo"/>
                            </a>
                        </div>
                        <div class="text-center mobile-hide">
                            <div class="bold">
                                Institut für Musikwissenschaft<br/>
                                und Interpretationsforschung (IMI)<br/>
                            </div>
                            <div>Universität für Musik<br/>
                                und Darstellende Kunst Wien</div>
                            <div><a href="mailto:rost@mdw.ac.at">rost@mdw.ac.at</a></div>
                        </div>
                    </div>
                    <div class="col-0 col-lg-1 mobile-hide" />
                    <div class="col-6 col-lg-2">
                        <div>
                            <a href="https://www.fwf.ac.at/forschungsradar/10.55776/PAT1123425">
                               <img class="footerlogo" src="images/fwf-logo.svg" alt="Österreichische Wissenschaftsfonds"/>
                            </a>
                        </div>
                        <div class="mobile-hide">
                            Gefördert aus Mitteln Wissenschaftsfonds FWF<br/>
                            <a href="https://doi.org/10.55776/PAT1123425">doi:10.55776/PAT1123425</a>
                        </div>
                    </div>
                </div>
            </div> <!-- conmtainer -->
            <div class="text-center">
                © 2026 ÖAW | <a href="imprint.html">Impressum</a> |    <a href="{$github_url}">
                <i aria-hidden="true" class="bi bi-github fs-6"></i>
                <span class="visually-hidden">GitHub repo</span>
                </a>
            </div>
        </footer>
<script src="vendor/jquery/jquery-3.7.1.min.js"></script>
<script src="vendor/bootstrap-5.3.5-dist/js/bootstrap.bundle.min.js"></script>

</xsl:template>
</xsl:stylesheet>
