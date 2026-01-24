<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">

  <!-- We use indent=no to prevent Saxon to add unnecessary newlines. -->
  <xsl:output
    method="xml"
    encoding="UTF-8"
    omit-xml-declaration="no"
    indent="no"
  />

  <xsl:variable
    name="dracor-id"
    select="
      concat(
        'span000',
        //tei:publicationStmt/tei:idno[1]/tei:idno[@type='number']/text())"
  />

  <xsl:template match="/">
    <TEI type="dracor" xml:id="{$dracor-id}" xml:lang="es">
      <xsl:apply-templates select="/tei:TEI/*"/>
    </TEI>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- remove schema -->
  <xsl:template match="//processing-instruction('xml-model')" />

  <!-- adjust stylesheet path -->
  <xsl:template match="//processing-instruction('xml-stylesheet')">
    <xsl:processing-instruction name="xml-stylesheet">type="text/css" href="css/tei.css"</xsl:processing-instruction>
  </xsl:template>

  <xsl:template match="tei:teiHeader">
    <xsl:variable name="wd-id"
      select="/tei:TEI//tei:titleStmt/tei:title[@type='idno']/tei:idno[@type='wikidata']"/>
    <xsl:variable name="premiere"
      select=".//tei:sourceDesc/tei:bibl[@type='first-performance']/tei:date/@when/string()"/>
    <xsl:variable name="print"
      select=".//tei:sourceDesc/tei:bibl[@type='first-published']/tei:date/text()"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
    <standOff>
      <xsl:if test="$premiere or $print">
        <listEvent>
          <xsl:if test="$print">
            <event type="print" when="{$print}"><desc/></event>
          </xsl:if>
          <xsl:if test="$premiere">
            <event type="premiere" when="{$premiere}"><desc/></event>
          </xsl:if>
        </listEvent>
      </xsl:if>
      <listRelation>
        <relation
          name="wikidata"
          active="https://dracor.org/entity/{$dracor-id}"
          passive="http://www.wikidata.org/entity/{$wd-id}"/>
      </listRelation>

    </standOff>
  </xsl:template>

  <!-- remove type="main" from title -->
  <xsl:template match="tei:titleStmt/tei:title[@type='main']/@type"></xsl:template>

  <!-- remove xml:id from castList roles -->
  <xsl:template match="tei:role/@xml:id"></xsl:template>

  <!-- remove empty elements -->
  <xsl:template match="(tei:div|tei:roleDesc|tei:actor)[normalize-space() = '']"></xsl:template>

  <!-- transform tei:name and make sure wikidata idno comes first -->
  <xsl:template match="tei:titleStmt/tei:author">
    <author>
      <xsl:apply-templates select="tei:name[@type='full']|tei:persName"/>
      <xsl:apply-templates select="tei:idno[@type='wikidata']"/>
      <xsl:apply-templates select="tei:idno[@type!='wikidata']"/>
    </author>
  </xsl:template>

  <xsl:template match="tei:titleStmt/tei:author/tei:name[@type='full']">
    <xsl:variable name="full" select="normalize-space()"/>
    <xsl:variable name="parts" select="tokenize($full, ' ')"/>
    <xsl:variable
      name="persName"
      select="document('')//tei:author[@key = $full]/tei:persName"/>

    <xsl:choose>
      <xsl:when test="not($persName) and count($parts) = 2">
        <persName>
          <forename><xsl:value-of select="$parts[1]"/></forename>
          <xsl:text> </xsl:text>
          <surname><xsl:value-of select="$parts[2]"/></surname>
        </persName>
      </xsl:when>
      <xsl:when test="not($persName)">
        <persName><xsl:value-of select="$full"/></persName>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$persName"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- remove original wikidata idnos -->
  <xsl:template match="tei:titleStmt/tei:title/tei:idno[@type='wikidata']">
  </xsl:template>

  <!-- transform particDesc -->
  <xsl:template match="tei:particDesc/tei:listPerson/tei:person">
    <person>
      <xsl:apply-templates select="@xml:id"/>
      <xsl:apply-templates select="@sex"/>
      <persName>
        <xsl:value-of select="tei:persName"/>
      </persName>
    </person>
  </xsl:template>

  <xsl:template match="tei:particDesc/tei:listPerson/tei:personGrp">
    <personGrp>
      <xsl:apply-templates select="@xml:id"/>
      <xsl:apply-templates select="@sex"/>
      <name>
        <xsl:value-of select="tei:persName"/>
      </name>
    </personGrp>
  </xsl:template>

  <xsl:template match="@sex">
    <xsl:attribute name="sex">
      <xsl:choose>
        <xsl:when test=". = 'M'"><xsl:text>MALE</xsl:text></xsl:when>
        <xsl:when test=". = 'F'"><xsl:text>FEMALE</xsl:text></xsl:when>
        <xsl:otherwise><xsl:text>UNKNOWN</xsl:text></xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <!-- insert textClass derived from textDesc -->
  <xsl:template match="tei:particDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
    <xsl:variable name="purpose" select="//tei:textDesc/tei:purpose[@type]"/>
    <xsl:if test="$purpose">
      <textClass> <xsl:comment><xsl:value-of select="$purpose/@type"/></xsl:comment>
        <xsl:if test="$purpose/@type = ('tragedia', 'tragicomedia', 'comedia', 'comedia-bárbara', 'juguete-comico')">
          <classCode scheme="http://www.wikidata.org/entity/">
            <xsl:choose>
              <xsl:when test="$purpose/@type = 'tragedia'">
                <xsl:text>Q80930</xsl:text>
              </xsl:when>
              <xsl:when test="$purpose/@type = 'tragicomedia'">
                <xsl:text>Q192881</xsl:text>
              </xsl:when>
              <xsl:when test="$purpose/@type = ('comedia', 'comedia-bárbara', 'juguete-comico')">
                <xsl:text>Q40831</xsl:text>
              </xsl:when>
            </xsl:choose>
          </classCode>
        </xsl:if>
      </textClass>
    </xsl:if>
  </xsl:template>

  <!-- delete invalid since incomplete textDesc elements -->
  <xsl:template match="tei:textDesc">
  </xsl:template>

  <!--
  These elements define the persName overrides to replace the
  tei:name[@type=full] elements for cases that cannot be handled
  programmatically (i.e. authors with more than one forename or surname or
  other name components).
  -->
  <author key="Ramón María del Valle Inclán">
    <persName>
      <forename>Ramón</forename>
      <forename>María</forename>
      <nameLink>del</nameLink>
      <surname>Valle</surname>
      <surname>Inclán</surname>
    </persName>
  </author>

  <author key="Leopoldo Alas">
    <persName type="pen">Clarín</persName>
    <persName>
      <forename>Leopoldo</forename>
      <surname>Alas</surname>
    </persName>
  </author>

  <author key="Benito Pérez Galdós">
    <persName>
      <forename>Benito</forename>
      <surname>Pérez</surname>
      <surname sort="1">Galdós</surname>
    </persName>
  </author>

  <author key="Federico García Lorca">
    <persName>
      <forename>Federico</forename>
      <surname>García</surname>
      <surname sort="1">Lorca</surname>
    </persName>
  </author>

  <author key="Miguel de Unamuno">
    <persName>
      <forename>Miguel</forename>
      <nameLink>de</nameLink>
      <surname>Unamuno</surname>
    </persName>
  </author>

  <author key="Pedro Muñoz Seca">
    <persName>
      <forename>Pedro</forename>
      <surname>Muñoz</surname>
      <surname>Seca</surname>
    </persName>
  </author>
</xsl:stylesheet>
