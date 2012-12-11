<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="xlink"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:xlink="http://www.w3.org/1999/xlink">

  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes" standalone="yes" indent="yes"/>

  <!-- body of the article -->
  <xsl:template match="/pmc-articleset">
    <article>
      <xsl:apply-templates select="article/front"/>
      <xsl:apply-templates select="article/body"/>
      <xsl:apply-templates select="article/back"/>
    </article>
  </xsl:template>

  <xsl:template match="front">
    <header class="{local-name()}">
      <xsl:apply-templates select="article-meta/title-group/article-title"/>

      <div class="context authors" data-ignore-class="">
        <xsl:apply-templates select="article-meta/contrib-group/contrib[@contrib-type='author']/name"/>
      </div>

      <div class="context" data-ignore-class="">
        <xsl:text>Published in </xsl:text>

        <a>
          <xsl:attribute name="href">
            <xsl:text>http://dx.doi.org/</xsl:text>
            <xsl:value-of select="article-meta/article-id[@pub-id-type='doi']"/>
          </xsl:attribute>

          <xsl:choose>
            <xsl:when test="journal-meta/journal-title-group">
              <xsl:value-of select="journal-meta/journal-title-group/journal-title"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="journal-meta/journal-title"/>
            </xsl:otherwise>
          </xsl:choose>
        </a>

        <xsl:text> on </xsl:text>

        <xsl:variable name="date" select="article-meta/pub-date[@pub-type='epub']"/>

        <xsl:variable name="mo">
            <xsl:value-of select="$date/month"/>
          </xsl:variable>

        <xsl:variable name="month">
            <xsl:choose>
              <xsl:when test="$mo = 1">January</xsl:when>
              <xsl:when test="$mo = 2">February</xsl:when>
              <xsl:when test="$mo = 3">March</xsl:when>
              <xsl:when test="$mo = 4">April</xsl:when>
              <xsl:when test="$mo = 5">May</xsl:when>
              <xsl:when test="$mo = 6">June</xsl:when>
              <xsl:when test="$mo = 7">July</xsl:when>
              <xsl:when test="$mo = 8">August</xsl:when>
              <xsl:when test="$mo = 9">September</xsl:when>
              <xsl:when test="$mo = 10">October</xsl:when>
              <xsl:when test="$mo = 11">November</xsl:when>
              <xsl:when test="$mo = 12">December</xsl:when>
            </xsl:choose>
          </xsl:variable>

          <time datetime="{$date/year}-{format-number($date/month, '00')}-{format-number($date/day, '00')}">
            <xsl:value-of select="$month"/><xsl:text> </xsl:text>
            <xsl:value-of select="$date/day"/><xsl:text>, </xsl:text>
            <xsl:value-of select="$date/year"/>
          </time>
      </div>
    </header>
  </xsl:template>

  <xsl:template match="back">
    <footer class="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </footer>
  </xsl:template>

  <!-- year for article context -->
  <xsl:template match="year" mode="context">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates select="node()|@*"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- paragraph -->
  <xsl:template match="p">
    <p class="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </p>
  </xsl:template>

  <!-- the article title -->
  <xsl:template match="article-title">
    <h1 class="{local-name()}"><xsl:apply-templates select="node()|@*"/></h1>
  </xsl:template>

  <!-- people -->
  <xsl:template match="person-group">
    <ol class="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </ol>
  </xsl:template>

  <!-- person in a list -->
  <xsl:template match="person-group/name">
    <li class="{local-name()}">
      <xsl:call-template name="name"/>
    </li>
  </xsl:template>

  <!-- name -->
  <xsl:template name="name">
    <xsl:apply-templates select="given-names"/>
    <xsl:if test="surname">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="surname"/>
    </xsl:if>
  </xsl:template>

  <!-- name -->
  <xsl:template match="name">
    <span class="{local-name()}">
      <xsl:call-template name="name"/>
    </span>
  </xsl:template>

  <!-- style elements -->
  <xsl:template match="italic | bold | sc | strike | sub | sup | underline | inline-formula">
    <span class="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </span>
  </xsl:template>

  <!-- inline elements -->
  <xsl:template match="abbrev | surname | given-names | email | label | year | month | day | xref | contrib | source | volume | fpage | lpage | etal | pub-id | x">
    <span class="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </span>
  </xsl:template>

  <!-- table elements -->
  <xsl:template match="table | tbody | thead | tfoot | column | tr | th | td | colgroup | col">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>

  <!-- sections -->
  <xsl:template match="sec">
    <section class="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </section>
  </xsl:template>

  <!-- section headings -->
  <xsl:template match="title | fig/label">
    <xsl:variable name="hierarchy" select="count(ancestor::sec | ancestor::back | ancestor::fig)"/>

    <xsl:if test="$hierarchy > 4">
      <xsl:variable name="hierarchy">6</xsl:variable>
    </xsl:if>

    <xsl:variable name="heading">h<xsl:value-of select="$hierarchy + 1"/></xsl:variable>

    <xsl:element name="{$heading}">
      <xsl:attribute name="class">heading</xsl:attribute>
      <xsl:attribute name="data-ignore-class"></xsl:attribute>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="supplementary-material/caption/title">
    <section class="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </section>
  </xsl:template>

  <!-- pass-through -->
  <!--
  <xsl:template match="p">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  -->

  <!-- links -->
  <xsl:template match="ext-link">
    <a class="{local-name()}" href="{@xlink:href}">
      <xsl:apply-templates select="node()|@*"/>
    </a>
  </xsl:template>

  <xsl:template match="ext-link[@ext-link-type='doi']">
    <a class="{local-name()}" href="http://dx.doi.org/{@xlink:href}">
      <xsl:apply-templates select="node()|@*"/>
    </a>
  </xsl:template>

  <!-- bibliography reference -->
  <xsl:template match="xref[@ref-type='bibr']">
    <xsl:variable name="rid" select="@rid"/>
    <xsl:variable name="citation" select="/article/back/ref-list/ref[@id=$rid]/citation"/>
    <a class="{local-name()}" href="#{$rid}" title="{$citation/article-title}"><xsl:apply-templates select="node()|@*"/></a>
  </xsl:template>

  <!-- figure reference -->
  <xsl:template match="xref">
    <a class="{local-name()}" href="#{@rid}"><xsl:apply-templates select="node()|@*"/></a>
  </xsl:template>

  <!-- figure -->
  <xsl:template match="fig">
    <figure class="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="graphic" mode="fig"/>
      <figcaption>
        <xsl:apply-templates select="label"/>
        <xsl:apply-templates select="caption"/>
      </figcaption>
      <xsl:apply-templates select="p"/>
    </figure>
  </xsl:template>

  <!-- figure title -->
  <xsl:template match="title" mode="fig">
    <div class="{local-name()}"><xsl:apply-templates select="node()|@*"/></div>
  </xsl:template>

  <!-- graphic -->
  <xsl:template match="graphic | inline-graphic">
    <xsl:variable name="href" select="@xlink:href"/>
    <img class="{local-name()}" src="{$href}"><xsl:apply-templates select="@*"/></img>
  </xsl:template>

  <!-- figure graphic -->
  <xsl:template match="graphic" mode="fig">
    <xsl:variable name="href" select="@xlink:href"/>
    <img class="{local-name()}" src="{$href}"><xsl:apply-templates select="@*"/></img>
  </xsl:template>

  <!-- supplementary material -->
  <xsl:template match="supplementary-material">
    <div class="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
      <a href="{@xlink:href}" download="" class="btn">Download</a>
    </div>
  </xsl:template>

  <!-- acknowledgments -->
  <xsl:template match="ack">
    <div class="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </div>
  </xsl:template>

  <!-- reference list -->
  <xsl:template match="ref-list">
    <xsl:apply-templates select="title|@*"/>
    <div class="ref-list-container" data-ignore-class="">
      <ol class="{local-name()}">
        <xsl:apply-templates select="ref|@*"/>
      </ol>
    </div>
  </xsl:template>

  <!-- reference list item -->
  <xsl:template match="ref-list/ref">
    <li class="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </li>
  </xsl:template>

  <!-- mixed citation -->
  <xsl:template match="mixed-citation">
    <div class="{local-name()}">
      <xsl:apply-templates select="article-title"/>

      <div>
        <xsl:choose>
          <xsl:when test="person-group">
            <xsl:apply-templates select="person-group"/>
          </xsl:when>
          <xsl:otherwise>
            <div class="person-group" data-ignore-class="">
              <xsl:apply-templates select="name"/>
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <div>
        <xsl:apply-templates select="year"/>
        <xsl:apply-templates select="source"/>
        <xsl:apply-templates select="volume"/><xsl:if test="fpage">:</xsl:if><xsl:apply-templates select="fpage"/>
      </div>
    </div>
  </xsl:template>

  <!-- mixed citation -->
  <xsl:template match="citation">
    <div class="{local-name()}">
      <xsl:apply-templates select="article-title"/>

      <div>
        <xsl:choose>
          <xsl:when test="person-group">
            <xsl:apply-templates select="person-group"/>
          </xsl:when>
          <xsl:otherwise>
            <div class="person-group" data-ignore-class="">
              <xsl:apply-templates select="name"/>
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <div>
        <xsl:apply-templates select="year"/>
        <xsl:apply-templates select="source"/>
        <xsl:apply-templates select="volume"/><xsl:if test="fpage">:</xsl:if><xsl:apply-templates select="fpage"/>
      </div>
    </div>
  </xsl:template>

  <!-- article title in references -->
  <xsl:template match="mixed-citation/article-title|citation/article-title">
    <a class="{local-name()}" target="_blank" href="http://scholar.google.com/scholar?q=intitle:&quot;{.}&quot;"><xsl:apply-templates select="node()|@*"/></a>
  </xsl:template>

  <!-- "et al" -->
  <xsl:template match="mixed-citation/person-group/etal">
    <li class="{local-name()}">et al.</li>
  </xsl:template>

  <!-- block elements -->
  <xsl:template match="*">
    <div class="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </div>
  </xsl:template>

  <!-- attributes (direct copy) -->
  <xsl:template match="@*">
    <xsl:copy-of select="."/>
  </xsl:template>

  <!-- mathml (direct copy) -->
  <xsl:template match="mml:math">
    <xsl:copy-of select="."/>
  </xsl:template>
</xsl:stylesheet>
