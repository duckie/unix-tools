<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output omit-xml-declaration="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:template match="@*|node()" name="identity">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="comment()"/>
  <xsl:template match="@choice">
    <xsl:value-of select="concat(.,'&#9;')"/>
  </xsl:template>
  <xsl:template match="question|answer">
    <xsl:call-template name="identity"/>
    <xsl:text>
</xsl:text>
  </xsl:template>
</xsl:stylesheet>
