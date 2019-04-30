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

  <xsl:variable name="wikidata" select="document('wikidata.xml')"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
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

  <!-- add wikidata ID for play -->
  <xsl:template match="tei:publicationStmt">
    <xsl:variable name="idno" select="tei:idno[1]/text()"/>
    <publicationStmt>
      <xsl:apply-templates/>
      <idno type="wikidata" xml:base="https://www.wikidata.org/wiki/">
        <xsl:value-of select="$wikidata//play[@id = $idno]/@play"/>
      </idno>
    </publicationStmt>
  </xsl:template>

  <!-- add wikidata ID for author -->
  <xsl:template match="tei:titleStmt/tei:author">
    <xsl:variable
      name="idno" select="//tei:publicationStmt/tei:idno[1]/text()"/>
    <author key="Wikidata:{$wikidata//play[@id = $idno]/@author}">
      <xsl:apply-templates/>
    </author>
  </xsl:template>

  <!-- create particDesc -->
  <xsl:template match="tei:profileDesc">
    <xsl:variable name="castList" select="/tei:TEI//tei:castList"/>
    <profileDesc>
      <xsl:apply-templates/>
      <particDesc>
        <listPerson>
        <xsl:for-each select="/tei:TEI//tei:sp[@who]">
          <xsl:variable name="sp" select="."/>
          <xsl:variable
            name="whos" select="tokenize(normalize-space(@who), '\s+')"/>
          <xsl:for-each select="$whos">
            <xsl:variable name="who" select="substring(., 2)"/>
            <xsl:variable
              name="name" select="$castList//tei:role[@xml:id = $who]"/>
            <xsl:if test="not(
              $sp/preceding::tei:sp[tokenize(@who) = concat('#', $who)]
            )">
            <person>
              <xsl:attribute name="xml:id">
                <xsl:value-of select="$who"/>
              </xsl:attribute>
              <persName>
                <xsl:if test="$name"><xsl:value-of select="$name"/></xsl:if>
                <xsl:if test="not($name)"><xsl:value-of select="$who"/></xsl:if>
              </persName>
            </person>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
        </listPerson>
      </particDesc>
    </profileDesc>
  </xsl:template>

</xsl:stylesheet>