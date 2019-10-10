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

  <xsl:template match="/">
    <TEI xml:lang="es">
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

  <!-- remove xml:id from castList roles -->
  <xsl:template match="tei:role/@xml:id"></xsl:template>

  <!-- add DraCor and Wikidata IDs for play -->
  <xsl:template match="tei:publicationStmt">
    <xsl:variable name="idno" select="tei:idno[1]/tei:idno[@type='number']/text()"/>
    <publicationStmt>
      <xsl:apply-templates/>
      <idno type="dracor" xml:base="https://dracor.org/id/">
        <xsl:value-of select="concat('span000', $idno)"/>
      </idno>
      <idno type="wikidata" xml:base="https://www.wikidata.org/entity/">
        <xsl:value-of select="/tei:TEI//tei:titleStmt/tei:title[@type='idno']/tei:idno[@type='wikidata']"/>
      </idno>
    </publicationStmt>
  </xsl:template>

  <!-- add wikidata ID for author -->
  <xsl:template match="tei:titleStmt/tei:author">
    <xsl:variable
      name="id" select="./tei:idno[@type='wikidata']/text()"/>
    <author key="wikidata:{$id}">
      <xsl:apply-templates/>
    </author>
  </xsl:template>

  <!-- remove original wikidata idnos -->
  <xsl:template match="tei:titleStmt/tei:*/tei:idno[@type='wikidata']">
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

  <!-- add 'originalSource' dates -->
  <xsl:template match="tei:sourceDesc">
    <xsl:variable name="premiere" select="tei:bibl[@type='first-performance']/tei:date/@when/string()"/>
    <xsl:variable name="print" select="tei:bibl[@type='first-published']/tei:date/text()"/>
    <sourceDesc>
      <xsl:apply-templates/>
      <bibl type="originalSource">
        <xsl:if test="$print">
          <date type="print" when="{$print}"/>
        </xsl:if>
        <xsl:if test="$premiere">
          <date type="premiere" when="{$premiere}"/>
        </xsl:if>
      </bibl>
    </sourceDesc>
  </xsl:template>

</xsl:stylesheet>
