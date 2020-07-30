<?xml version="1.0" encoding="UTF-8" ?>
<!-- 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:doc="http://www.lyncode.com/xoai" 
    xmlns:logUtil="cz.cuni.mff.ufal.utils.XslLogUtil"
    xmlns:isocodes="cz.cuni.mff.ufal.IsoLangCodes"
    xmlns:langUtil="cz.cuni.mff.ufal.utils.LangUtil"
    xmlns:license="cz.cuni.mff.ufal.utils.LicenseUtil"
    xmlns:xalan="http://xml.apache.org/xslt"
    xmlns:str="http://exslt.org/strings"
    xmlns:ms="http://w3id.org/meta-share/meta-share/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="doc logUtil isocodes license xalan str langUtil confman"
    version="1.0">
    
    <xsl:output omit-xml-declaration="yes" method="xml" indent="yes" xalan:indent-amount="4"/>

    <!-- VARIABLES BEGIN -->
    <xsl:variable name="identifier_uri" select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']"/>
    
    <xsl:variable name="handle" select="/doc:metadata/doc:element[@name='others']/doc:field[@name='handle']/text()"/>

    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='resourceType']/doc:element/doc:field[@name='value']">
          <xsl:value-of select="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='resourceType']/doc:element/doc:field[@name='value']"/>
        </xsl:when>
        <xsl:when test="/doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
          <xsl:value-of select="/doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="logUtil:logMissing('type',$handle)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="upperType">
      <xsl:value-of select="translate(substring($type,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
      <xsl:value-of select="substring($type,2)"/>
    </xsl:variable>

    <xsl:variable name="mediaType">
      <!-- No media type for toolService -->
      <xsl:if test="not($type='toolService')">
        <xsl:choose>
          <xsl:when test="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='mediaType']/doc:element/doc:field[@name='value']">
            <xsl:value-of select="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='mediaType']/doc:element/doc:field[@name='value']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="logUtil:logMissing('mediaType',$handle)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="upperMediaType">
      <xsl:value-of select="translate(substring($mediaType,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
      <xsl:value-of select="substring($mediaType,2)"/>
    </xsl:variable>

    <xsl:variable name="detailedType">
      <!-- No detailed type for corpus -->
      <xsl:if test="not($type='corpus')">
        <xsl:choose>
          <xsl:when
                  test="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='detailedType']/doc:element/doc:field[@name='value'] = 'wordList' ">
            <xsl:value-of select="'wordlist'"/>
          </xsl:when>
          <xsl:when
                  test="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='detailedType']/doc:element/doc:field[@name='value'] ">
            <xsl:value-of select="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='detailedType']/doc:element/doc:field[@name='value']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="logUtil:logMissing('detailedType',$handle)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

  <xsl:variable name="files">
    <xsl:copy-of
            select="//doc:element[@name='bundle']/doc:field[@name='name'][text()='ORIGINAL']/..//doc:element[@name='bitstream']"/>
  </xsl:variable>

  <xsl:variable name="lr.download.all.limit.max.file.size" select="confman:getLongProperty('lr', 'lr.download.all.limit.max.file.size', 1073741824)"/>
  <!-- VARIABLES END -->

  <xsl:template match="/">
    <xsl:call-template name="MetadataRecord"/>
  </xsl:template>

  <xsl:template name="MetadataRecord">
    <ms:MetadataRecord xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://w3id.org/meta-share/meta-share/ ../Schema/ELG-SHARE.xsd">
      <ms:MetadataRecordIdentifier ms:MetadataRecordIdentifierScheme="http://w3id.org/meta-share/meta-share/elg">value automatically assigned - leave as is</ms:MetadataRecordIdentifier>
      <ms:metadataCreationDate>
        <xsl:call-template name="formatDate">
          <xsl:with-param name="date"
                          select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='available']/doc:element/doc:field[@name='value']"/>
        </xsl:call-template>
      </ms:metadataCreationDate>
      <ms:metadataLastDateUpdated>
        <xsl:call-template name="formatDate">
          <xsl:with-param name="date" select="doc:metadata/doc:element[@name='others']/doc:field[@name='lastModifyDate']"/>
        </xsl:call-template>
      </ms:metadataLastDateUpdated>
      <ms:compliesWith>http://w3id.org/meta-share/meta-share/ELG-SHARE</ms:compliesWith>
      <ms:sourceOfMetadataRecord>
        <ms:repositoryName xml:lang="en">LINDAT/CLARIAH-CZ</ms:repositoryName>
      </ms:sourceOfMetadataRecord>
      <ms:sourceMetadataRecord>
        <ms:MetadataRecordIdentifier>
          <xsl:attribute name="ms:MetadataRecordIdentifierScheme">http://purl.org/spar/datacite/handle</xsl:attribute>
          <xsl:value-of select="$identifier_uri"/>
        </ms:MetadataRecordIdentifier>
      </ms:sourceMetadataRecord>
      <ms:DescribedEntity>
        <xsl:call-template name="LanguageResource"/>
      </ms:DescribedEntity>
    </ms:MetadataRecord>
  </xsl:template>

  <xsl:template name="LanguageResource">
    <ms:LanguageResource>
      <ms:entityType>LanguageResource</ms:entityType>
      <xsl:call-template name="resourceName"/>
      <xsl:call-template name="description"/>
      <ms:version>undefined</ms:version>
      <ms:additionalInfo>
        <ms:landingPage><xsl:value-of select="$identifier_uri"/></ms:landingPage>
      </ms:additionalInfo>
      <xsl:call-template name="keyword"/>
      <xsl:call-template name="resourceProvider"/>
      <ms:publicationDate>
        <xsl:call-template name="formatDate">
          <xsl:with-param name="date" select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']"/>
        </xsl:call-template>
      </ms:publicationDate>
      <xsl:call-template name="resourceCreator"/>
      <xsl:call-template name="fundingProject"/>
        <!-- TODO replaces need a title; should add that to the xoai format -->
      <xsl:call-template name="LRSubclass"/>
    </ms:LanguageResource>
  </xsl:template>

  <xsl:template name="resourceName">
      <ms:resourceName xml:lang="en">
        <xsl:choose>
          <xsl:when test="doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#IdentificationInfo']/doc:element[@name='resourceName']/doc:element/doc:field[@name='value']">
            <xsl:value-of select="doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#IdentificationInfo']/doc:element[@name='resourceName']/doc:element/doc:field[@name='value']"/>
          </xsl:when>
          <xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="logUtil:logMissing('resourceName',$handle)"/>
          </xsl:otherwise>
        </xsl:choose>
      </ms:resourceName>
  </xsl:template>

  <xsl:template name="description">
      <ms:description xml:lang="en">
        <xsl:choose>
          <xsl:when test="doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='description']/doc:element/doc:field[@name='value']">
            <xsl:value-of select="doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='description']/doc:element/doc:field[@name='value']"/>
          </xsl:when>
          <xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element/doc:field[@name='value']">
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element/doc:field[@name='value']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="logUtil:logMissing('description',$handle)"/>
          </xsl:otherwise>
        </xsl:choose>
      </ms:description>
  </xsl:template>

  <xsl:template name="keyword">
      <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
        <ms:keyword xml:lang='en'><xsl:value-of select="."/></ms:keyword>
      </xsl:for-each>
  </xsl:template>

  <xsl:template name="resourceProvider">
      <ms:resourceProvider>
        <ms:Organization>
          <ms:actorType>Organization</ms:actorType>
          <ms:organizationName xml:lang="en"><xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']"/></ms:organizationName>
        </ms:Organization>
      </ms:resourceProvider>
  </xsl:template>

  <xsl:template name="resourceCreator">
      <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
          <xsl:if test="not(. = 'et al.')">
            <xsl:variable name="surname" select="str:split(., ', ')[1]"/>
            <xsl:variable name="given">
              <xsl:for-each select="str:split(., ', ')">
                <xsl:if test="position() &gt; 1">
                  <xsl:value-of select="."/>
                  <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                  </xsl:if>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <ms:resourceCreator>
              <ms:Person>
                <ms:actorType>Person</ms:actorType>
                <!--  xml:lang doesn't make much sense for surnames and givenName; it should be "script", en mandatory -->
                <ms:surname xml:lang="en"><xsl:value-of select="$surname"/></ms:surname>
                <ms:givenName xml:lang="en"><xsl:value-of select="$given"/></ms:givenName>
              </ms:Person>
            </ms:resourceCreator>
          </xsl:if>
      </xsl:for-each>
  </xsl:template>

  <xsl:template name="fundingProject">
    <xsl:for-each select="doc:metadata/doc:element[@name='local']/doc:element[@name='sponsor']/doc:element/doc:field[@name='value']">
      <xsl:variable name="proj_arr" select="str:split(., '@@')"/>
        <xsl:if
                test="count($proj_arr) &gt;= 4 and $proj_arr[1] != '' and $proj_arr[2] != '' and $proj_arr[3] != '' and $proj_arr[4] != ''">
          <ms:fundingProject>
            <ms:projectName xml:lang="en">
              <xsl:value-of select="$proj_arr[3]"/>
            </ms:projectName>
            <xsl:choose>
              <xsl:when test="starts-with($proj_arr[5], 'info:')">
                <ms:ProjectIdentifier>
                  <xsl:attribute name="ms:ProjectIdentifierScheme">http://w3id.org/meta-share/meta-share/OpenAIRE</xsl:attribute>
                  <xsl:value-of select="$proj_arr[5]"/>
                </ms:ProjectIdentifier>
              </xsl:when>
              <xsl:otherwise>
                  <ms:grantNumber>
                    <xsl:value-of select="$proj_arr[2]"/>
                  </ms:grantNumber>
              </xsl:otherwise>
            </xsl:choose>
            <ms:fundingType>
              <xsl:choose>
                <xsl:when test="$proj_arr[4] = 'Other'">http://w3id.org/meta-share/meta-share/other</xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat('http://w3id.org/meta-share/meta-share/', $proj_arr[4])"/>
                </xsl:otherwise>
              </xsl:choose>
            </ms:fundingType>
            <ms:funder>
              <ms:Organization>
                <ms:actorType>Organization</ms:actorType>
                <ms:organizationName xml:lang="en"><xsl:value-of select="$proj_arr[1]"/></ms:organizationName>
              </ms:Organization>
            </ms:funder>
          </ms:fundingProject>
        </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="LRSubclass">
    <ms:LRSubclass>
      <xsl:choose>
        <xsl:when test="$type = 'corpus'">
          <xsl:call-template name="corpus"/>
        </xsl:when>
        <xsl:when test="$type = 'toolService'">
          <xsl:call-template name="toolService"/>
        </xsl:when>
        <xsl:when test="$type = 'languageDescription'">
          <xsl:call-template name="languageDescription"/>
        </xsl:when>
        <xsl:when test="$type = 'lexicalConceptualResource'">
          <xsl:call-template name="lexicalConceptualResource"/>
        </xsl:when>
      </xsl:choose>
    </ms:LRSubclass>
  </xsl:template>

  <xsl:template name="corpus">
      <ms:Corpus>
        <ms:lrType>Corpus</ms:lrType>
        <ms:corpusSubclass>http://w3id.org/meta-share/meta-share/unspecified</ms:corpusSubclass>
        <xsl:call-template name="CommonMediaPart"/>
        <xsl:call-template name="Distribution"/>
        <xsl:call-template name="personalSensitiveAnon"/>
      </ms:Corpus>
  </xsl:template>

  <xsl:template name="personalSensitiveAnon">
    <ms:personalDataIncluded>false</ms:personalDataIncluded>
    <ms:sensitiveDataIncluded>false</ms:sensitiveDataIncluded>
  </xsl:template>

  <xsl:template name="CommonMediaPart">
    <xsl:variable name="name" select="concat($upperType, 'MediaPart')"/>
    <xsl:element name="ms:{$name}">
      <xsl:call-template name="commonMediaElements"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="commonMediaElements">
    <xsl:variable name="name" select="concat($upperType, $upperMediaType, 'Part')"/>
    <xsl:variable name="name2" >
      <xsl:choose>
        <xsl:when test="$type = 'lexicalConceptualResource'">lcrMediaType</xsl:when>
        <xsl:when test="$type = 'languageDescription'">ldMediaType</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($type, 'MediaType')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:element name="ms:{$name}">
      <xsl:element name="ms:{$name2}"><xsl:value-of select="$name"/></xsl:element>
      <ms:mediaType><xsl:value-of select="concat('http://w3id.org/meta-share/meta-share/', $mediaType)"/></ms:mediaType>
      <ms:lingualityType>
        <xsl:variable name="langCount" select="count(/doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value'])"/>
        <xsl:text>http://w3id.org/meta-share/meta-share/</xsl:text>
        <xsl:choose>
          <xsl:when test="$langCount=1">monolingual</xsl:when>
          <xsl:when test="$langCount=2">bilingual</xsl:when>
          <xsl:otherwise>multilingual</xsl:otherwise>
        </xsl:choose>
      </ms:lingualityType>
      <ms:multilingualityType>http://w3id.org/meta-share/meta-share/unspecified</ms:multilingualityType>
      <xsl:for-each
              select="/doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value']">
        <xsl:call-template name="Language">
          <xsl:with-param name="isoCode" select="langUtil:getShortestId(.)"/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:choose>
        <xsl:when test="$mediaType = 'audio'">
          <xsl:call-template name="audio"/>
        </xsl:when>
        <xsl:when test="$mediaType = 'video'">
          <xsl:call-template name="video"/>
        </xsl:when>
        <xsl:when test="$mediaType = 'text'">
          <xsl:call-template name="text"/>
        </xsl:when>
        <xsl:when test="$mediaType = 'image'">
          <xsl:call-template name="image"/>
        </xsl:when>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="commonCorpusMediaElements">
      <xsl:variable name="name" select="concat('Corpus', $upperMediaType, 'Part')"/>
      <xsl:element name="ms:{$name}">
        <ms:corpusMediaType><xsl:value-of select="$name"/></ms:corpusMediaType>
        <ms:mediaType><xsl:value-of select="concat('http://w3id.org/meta-share/meta-share/', $mediaType)"/></ms:mediaType>
        <ms:lingualityType>
          <xsl:variable name="langCount" select="count(/doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value'])"/>
          <xsl:text>http://w3id.org/meta-share/meta-share/</xsl:text>
          <xsl:choose>
            <xsl:when test="$langCount=1">monolingual</xsl:when>
            <xsl:when test="$langCount=2">bilingual</xsl:when>
            <xsl:otherwise>multilingual</xsl:otherwise>
          </xsl:choose>
        </ms:lingualityType>
        <xsl:for-each
                select="/doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value']">
          <xsl:call-template name="Language">
            <xsl:with-param name="isoCode" select="langUtil:getShortestId(.)"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:element>
  </xsl:template>

  <xsl:template name="text"></xsl:template>
  <xsl:template name="audio"></xsl:template>
    <!-- XXX
     elg.xml:53: element CorpusVideoPart: Schemas validity error : Element '{http://w3id.org/meta-share/meta-share/}CorpusVideoPart': Missing child element(s). Expected is one of ( {http://w3id.org/meta-share/meta-share/}language, {http://w3id.org/meta-share/meta-share/}languageVariety, {http://w3id.org/meta-share/meta-share/}modalityType, {http://w3id.org/meta-share/meta-share/}VideoGenre, {http://w3id.org/meta-share/meta-share/}typeOfVideoContent ).
elg.xml:62: element typeOfVideoContent: Schemas validity error : Element '{http://w3id.org/meta-share/meta-share/}typeOfVideoContent': This element is not expected.
     -->
  <xsl:template name="video">
    <ms:typeOfVideoContent xml:lang="en">unspecified</ms:typeOfVideoContent>
  </xsl:template>
  <xsl:template name="image">
    <ms:typeOfImageContent xml:lang="en">unspecified</ms:typeOfImageContent>
  </xsl:template>

  <xsl:template name="Language">
    <xsl:param name="isoCode"/>
    <ms:language>
        <xsl:call-template name="ms_language_inside">
          <xsl:with-param name="isoCode" select="$isoCode"/>
        </xsl:call-template>
    </ms:language>
  </xsl:template>

  <xsl:template name="ms_language_inside">
    <xsl:param name="isoCode"/>
    <ms:languageTag>
      <xsl:value-of select="$isoCode"/>
    </ms:languageTag>
    <ms:languageId>
      <xsl:value-of select="$isoCode"/>
    </ms:languageId>
  </xsl:template>

  <xsl:template name="Distribution">
    <xsl:param name="distributionType" select="'Dataset'"/>
    <xsl:variable name="form">
      <xsl:choose>
        <xsl:when test="$distributionType = 'Dataset'">downloadable</xsl:when>
        <xsl:otherwise>sourceCode</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="ms:{$distributionType}Distribution">
      <xsl:element name="ms:{$distributionType}DistributionForm">
        <xsl:value-of select="concat('http://w3id.org/meta-share/meta-share/', $form)"/>
      </xsl:element>

      <!-- downloadLocation if there are files -->
      <xsl:if test="xalan:nodeset($files)/doc:element[@name='bitstream']">
        <xsl:choose>
          <!-- one file -> direct link -->
          <xsl:when test="count(xalan:nodeset($files)/doc:element[@name='bitstream']) = 1">
            <ms:downloadLocation><xsl:value-of
                      select="xalan:nodeset($files)[1]/doc:element[@name='bitstream']/doc:field[@name='url']/text()" /></ms:downloadLocation>
          </xsl:when>
          <!-- multiple files within allzip limit -->
          <xsl:when
                  test="sum(xalan:nodeset($files)/doc:element[@name='bitstream']/doc:field[@name='size']/text()) &lt; $lr.download.all.limit.max.file.size ">
            <ms:downloadLocation><xsl:value-of
                    select="concat(str:split(xalan:nodeset($files)[1]/doc:element[@name='bitstream']/doc:field[@name='url']/text(), 'bitstream/')[1], $handle, '/allzip')" /></ms:downloadLocation>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      <ms:accessLocation><xsl:value-of select="$identifier_uri"/></ms:accessLocation>
      <xsl:if test="doc:metadata/doc:element[@name='local']/doc:element[@name='demo']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
        <xsl:variable name="locType">
          <xsl:choose>
            <xsl:when test="$type = 'toolService'">demo</xsl:when>
            <xsl:otherwise>samples</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:element name="ms:{$locType}Location">
          <xsl:value-of select="doc:metadata/doc:element[@name='local']/doc:element[@name='demo']/doc:element[@name='uri']/doc:element/doc:field[@name='value']"/>
        </xsl:element>
      </xsl:if>

      <!-- distributionXfeature -->
      <xsl:if test="$distributionType = 'Dataset'">
        <xsl:element name="ms:distribution{$upperMediaType}Feature">
          <xsl:call-template name="Sizes"/>
          <xsl:call-template name="dataFormat"/>
        </xsl:element>
      </xsl:if>


      <ms:licenceTerms>
        <ms:licenceTermsName xml:lang="en"><xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value']" /></ms:licenceTermsName>
        <ms:licenceTermsURL><xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='uri']/doc:element/doc:field[@name='value']" /></ms:licenceTermsURL>
      </ms:licenceTerms>
    </xsl:element>
  </xsl:template>

  <xsl:template name="toolService">
      <ms:ToolService>
        <ms:lrType>ToolService</ms:lrType>
        <ms:function>
          <ms:LTClassRecommended>undefined</ms:LTClassRecommended>
            <!-- XXX if undefined not working
          <ms:LTClassRecommended>http://w3id.org/meta-share/omtd-share/Tokenization</ms:LTClassRecommended>
            -->
        </ms:function>
        <xsl:call-template name="Distribution">
          <xsl:with-param name="distributionType" select="'Software'"/>
        </xsl:call-template>
        <ms:languageDependent>
          <xsl:value-of select="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ResourceComponentType#ToolServiceInfo']/doc:element[@name='languageDependent']/doc:element/doc:field[@name='value']"/>
        </ms:languageDependent>
        <ms:inputContentResource>
          <ms:processingResourceType>http://w3id.org/meta-share/meta-share/unspecified</ms:processingResourceType>
        </ms:inputContentResource>
        <!--
         The element can be used for adding evaluation/quality-related information,
         e.g. BLEU scores for machine translation tools,
         or links to evaluation reports if it has been formally evaluated by someone.
         -->
        <ms:evaluated>false</ms:evaluated>
      </ms:ToolService>
  </xsl:template>

  <xsl:template name="languageDescription">
    <ms:LanguageDescription>
      <ms:lrType>LanguageDescription</ms:lrType>
      <ms:LanguageDescriptionSubclass>
        <xsl:choose>
          <xsl:when test="$detailedType='grammar'">
            <ms:Grammar>
              <ms:ldSubclassType>Grammar</ms:ldSubclassType>
              <ms:encodingLevel>http://w3id.org/meta-share/meta-share/unspecified</ms:encodingLevel>
            </ms:Grammar>
          </xsl:when>
          <xsl:when test="$detailedType='mlmodel'">
            <ms:MLModel>
              <ms:ldSubclassType>MlModel</ms:ldSubclassType>
            </ms:MLModel>
          </xsl:when>
          <xsl:when test="$detailedType='ngrammodel'">
            <ms:NGramModel>
              <ms:ldSubclassType>NGramModel</ms:ldSubclassType>
              <ms:baseItem>http://w3id.org/meta-share/meta-share/unspecified</ms:baseItem>
              <!-- XXX this is supposed to mean unspecified -->
              <ms:order>-1</ms:order>
            </ms:NGramModel>
          </xsl:when>
        </xsl:choose>
      </ms:LanguageDescriptionSubclass>
      <xsl:call-template name="CommonMediaPart"/>
      <xsl:call-template name="Distribution"/>
      <xsl:call-template name="personalSensitiveAnon"/>
    </ms:LanguageDescription>
  </xsl:template>

  <xsl:template name="lexicalConceptualResource">
    <ms:LexicalConceptualResource>
      <ms:lrType>LexicalConceptualResource</ms:lrType>
      <ms:lcrSubclass>
        <xsl:choose>
          <xsl:when test="$detailedType = 'wordnet'">http://w3id.org/meta-share/meta-share/wordNet</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('http://w3id.org/meta-share/meta-share/', $detailedType)"/>
          </xsl:otherwise>
        </xsl:choose>
      </ms:lcrSubclass>
      <ms:encodingLevel>http://w3id.org/meta-share/meta-share/unspecified</ms:encodingLevel>
      <xsl:call-template name="CommonMediaPart"/>
      <xsl:call-template name="Distribution"/>
      <xsl:call-template name="personalSensitiveAnon"/>
    </ms:LexicalConceptualResource>
  </xsl:template>

  <xsl:template name="formatDate">
    <xsl:param name="date"/>
    <xsl:value-of select="str:split($date, 'T')[1]"/>
  </xsl:template>

  <xsl:template name="Sizes">
    <xsl:choose>
      <xsl:when
              test="doc:metadata/doc:element[@name='local']/doc:element[@name='size']/doc:element[@name='info']/doc:element/doc:field[@name='value']">
        <xsl:for-each
                select="doc:metadata/doc:element[@name='local']/doc:element[@name='size']/doc:element[@name='info']/doc:element/doc:field[@name='value']">
          <xsl:variable name="size_arr" select="str:split(., '@@')"/>
          <xsl:call-template name="size">
            <xsl:with-param name="amount" select="$size_arr[1]"/>
            <xsl:with-param name="unit" select="$size_arr[2]"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="size">
          <xsl:with-param name="amount" select="sum(xalan:nodeset($files)/doc:element[@name='bitstream']/doc:field[@name='size']/text())"/>
          <xsl:with-param name="unit" select="'byte'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="size">
    <xsl:param name="amount"/>
    <xsl:param name="unit"/>
    <ms:size>
      <ms:amount><xsl:value-of select="$amount"/></ms:amount>
      <!-- sizeUnit -->
      <!-- adapted from https://gitlab.com/european-language-grid/platform/ELG-SHARE-schema/-/blob/master/Support%20tools/META-SHARE_3.1_into_ELG/elg-conversion-tools-master/rules/elra-to-elg-body.xsl -->
      <!-- DO NOT CHANGER ORDER DECLARATION -->
      <xsl:choose>
        <xsl:when test="$unit = '4-grams'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/four-gram</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = '5-grams'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/five-gram</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'articles'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/article</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'bigrams'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/bigram</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'bytes'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/byte</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'classes'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/class</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'entries'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/entry</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'expressions'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/expression</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'files'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/file</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'frames'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/frame1</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'hours'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/hour1</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'hpairs'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/T-HPair</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'images'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/image2</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'items'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/item</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'keywords'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/keyword1</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'lexicalTypes'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/lexicalType</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'minutes'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/minute</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'multiWordUnits'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/multiWordUnit</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'pages'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/other</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'segments'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/entry</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'sentences'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/sentence1</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'semanticUnits'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/semanticUnit1</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'terms'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/term</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'texts'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/text1</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'tokens'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/token</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'trigrams'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/trigram</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'turns'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/turn</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'units'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/unit</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'unigrams'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/unigram</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'utterances'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/utterance1</ms:sizeUnit>
        </xsl:when>
        <xsl:when test="$unit = 'words'">
          <ms:sizeUnit>http://w3id.org/meta-share/meta-share/word3</ms:sizeUnit>
        </xsl:when>
        <xsl:otherwise>
          <ms:sizeUnit><xsl:value-of select="concat('http://w3id.org/meta-share/meta-share/', $unit)"/></ms:sizeUnit>
        </xsl:otherwise>
      </xsl:choose>
    </ms:size>
  </xsl:template>

  <xsl:template name="dataFormat">
    <ms:dataFormat>
      <xsl:choose>
        <xsl:when test="false()"></xsl:when>
        <xsl:otherwise><xsl:value-of select="'http://w3id.org/meta-share/omtd-share/BinaryFormat'"/></xsl:otherwise>
      </xsl:choose>
    </ms:dataFormat>
  </xsl:template>


</xsl:stylesheet>
