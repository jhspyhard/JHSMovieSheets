<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:myjs="urn:custom-javascript" exclude-result-prefixes="msxsl myjs">
	
	<xsl:variable name="comments" select="//tokens/token[@name='%COMMENTS%']"/>
	<xsl:variable name="subtitle" select="//tokens/token[@name='%SUBTITLES1%']"/>
	<xsl:variable name="path" select="//tokens/token[@name='%PATH%']"/>
	<xsl:variable name="tagline" select="//tokens/token[@name='%TAGLINE%']"/>
	<xsl:variable name="videoBR" select="//tokens/token[@name='%VIDEOBITRATETEXT%']"/>
	<xsl:variable name="videoFR" select="//tokens/token[@name='%FRAMERATETEXT%']"/>
	<xsl:variable name="videoAR" select="//tokens/token[@name='%ASPECTRATIOTEXT%']"/>
	<xsl:variable name="audioBR" select="//tokens/token[@name='%AUDIOBITRATETEXT%']"/>
	<xsl:variable name="audioCH" select="//tokens/token[@name='%AUDIOCHANNELSTEXT%']"/>
	<xsl:variable name="fileSZ" select="//tokens/token[@name='%FILESIZETEXT%']"/>
	<xsl:variable name="episode" select="//tokens/token[@name='%EPISODE%']"/>
	<xsl:variable name="episodeNumbers" select="//tokens/token[@name='%EPISODELIST%']"/>
	<xsl:variable name="episodeNames" select="//tokens/token[@name='%EPISODENAMESLIST%']"/>
	<xsl:variable name="season" select="//tokens/token[@name='%SEASON%']"/>	
	<xsl:variable name="mediaFormat" select="//tokens/token[@name='%MEDIAFORMATTEXT%']"/>
	<xsl:variable name="imdbID" select="//tokens/token[@name='%IMDBID%']"/>
	
	<xsl:variable name="genres" select="//tokens/token[@name='%GENRES%']"/>
	<xsl:variable name="directors" select="//tokens/token[@name='%DIRECTORS%']"/>
	<xsl:variable name="studios" select="//tokens/token[@name='%STUDIOS%']"/>
	<xsl:variable name="plot" select="//tokens/token[@name='%PLOT%']"/>
	<xsl:variable name="year" select="//tokens/token[@name='%YEAR%']"/>
	
	<xsl:variable name="episodeTitle" select="//tokens/token[@name='%EPISODETITLE%']"/>
	<xsl:variable name="episodeReleaseDate" select="//tokens/token[@name='%EPISODERELEASEDATE%']"/>
	<xsl:variable name="cast" select="//tokens/token[@name='%ACTORS%']"/>
	<xsl:variable name="guestCast" select="//tokens/token[@name='%EPISODEGUESTSTARS%']"/>
	<xsl:variable name="episodeWriters" select="//tokens/token[@name='%EPISODEWRITERS%']"/>
	<xsl:variable name="episodePlot" select="//tokens/token[@name='%EPISODEPLOT%']"/>
	<xsl:variable name="duration" select="//tokens/token[@name='%DURATION%']"/>
	<xsl:variable name="runtime" select="//tokens/token[@name='%RUNTIME%']"/>
	
	<!-- Unused Tokens  -->
	<xsl:variable name="background" select="//tokens/token[@name='%BACKGROUND%']"/>
	<xsl:variable name="fanArt1" select="//tokens/token[@name='%FANART1%']"/>
	<xsl:variable name="fanArt2" select="//tokens/token[@name='%FANART2%']"/>
	<xsl:variable name="fanArt3" select="//tokens/token[@name='%FANART3%']"/>
	<xsl:variable name="titlePath" select="//tokens/token[@name='%TITLEPATH%']"/>
	<xsl:variable name="movieFileName" select="//tokens/token[@name='%MOVIEFILENAME%']"/>
	<xsl:variable name="movieFileNameWOExt" select="//tokens/token[@name='%MOVIEFILENAMEWITHOUTEXT%']"/>
	<xsl:variable name="movieFolder" select="//tokens/token[@name='%MOVIEFOLDER%']"/>
	<xsl:variable name="movieParentFolder" select="//tokens/token[@name='%MOVIEPARENTFOLDER%']"/>
	<xsl:variable name="cover" select="//tokens/token[@name='%COVER%']"/>
	
	<xsl:variable name="title" select="//tokens/token[@name='%TITLE%']"/>
	<xsl:variable name="originalTitle" select="//tokens/token[@name='%ORIGINALTITLE%']"/>
	<xsl:variable name="certification" select="//tokens/token[@name='%CERTIFICATION%']"/>
	<xsl:variable name="releaseDate" select="//tokens/token[@name='%RELEASEDATE%']"/>
	<xsl:variable name="mpaa" select="//tokens/token[@name='%MPAA%']"/>
	<xsl:variable name="certificationText" select="//tokens/token[@name='%CERTIFICATIONTEXT%']"/>
	<xsl:variable name="countries" select="//tokens/token[@name='%COUNTRIES%']"/>
	
	<xsl:variable name="allSubtitles" select="//tokens/token[@name='%ALLSUBTITLES%']"/>
	<xsl:variable name="subtitles" select="//tokens/token[@name='%SUBTITLES%']"/>
	<xsl:variable name="subtitle2" select="//tokens/token[@name='%SUBTITLES2%']"/>
	<xsl:variable name="subtitle3" select="//tokens/token[@name='%SUBTITLES3%']"/>
	<xsl:variable name="subtitle4" select="//tokens/token[@name='%SUBTITLES4%']"/>
	<xsl:variable name="subtitle5" select="//tokens/token[@name='%SUBTITLES5%']"/>
	<xsl:variable name="subtitlesText" select="//tokens/token[@name='%SUBTITLESTEXT%']"/>
	<xsl:variable name="externalSubtitlesText" select="//tokens/token[@name='%EXTERNALSUBTITLESTEXT%']"/>
	<xsl:variable name="externalSubtitle1" select="//tokens/token[@name='%EXTERNALSUBTITLES1%']"/>
	<xsl:variable name="externalSubtitle2" select="//tokens/token[@name='%EXTERNALSUBTITLES2%']"/>
	<xsl:variable name="externalSubtitle3" select="//tokens/token[@name='%EXTERNALSUBTITLES3%']"/>
	<xsl:variable name="externalSubtitle4" select="//tokens/token[@name='%EXTERNALSUBTITLES4%']"/>
	<xsl:variable name="externalSubtitle5" select="//tokens/token[@name='%EXTERNALSUBTITLES5%']"/>
	
	<xsl:variable name="rating" select="//tokens/token[@name='%RATING%']"/>
	<xsl:variable name="ratingPercent" select="//tokens/token[@name='%RATINGPERCENT%']"/>
	<xsl:variable name="ratingStars" select="//tokens/token[@name='%RATINGSTARS%']"/>
	<xsl:variable name="soundFormatText" select="//tokens/token[@name='%SOUNDFORMATTEXT%']"/>
	<xsl:variable name="resolutionText" select="//tokens/token[@name='%RESOLUTIONTEXT%']"/>
	<xsl:variable name="videoFormatText" select="//tokens/token[@name='%VIDEOFORMATTEXT%']"/>
	<xsl:variable name="frameRate" select="//tokens/token[@name='%FRAMERATE%']"/>
	<xsl:variable name="aspectRation" select="//tokens/token[@name='%ASPECTRATIO%']"/>
	<xsl:variable name="videoResolution" select="//tokens/token[@name='%VIDEORESOLUTION%']"/>
	<xsl:variable name="videoResolutionText" select="//tokens/token[@name='%VIDEORESOLUTIONTEXT%']"/>
	<xsl:variable name="videoCodecText" select="//tokens/token[@name='%VIDEOCODECTEXT%']"/>
	<xsl:variable name="audioCodecText" select="//tokens/token[@name='%AUDIOCODECTEXT%']"/>
	<xsl:variable name="durationFormatted" select="//tokens/token[@name='%DURATIONTEXT%']"/>
	<xsl:variable name="durationSec" select="//tokens/token[@name='%DURATIONSEC%']"/>
	<xsl:variable name="containerText" select="//tokens/token[@name='%CONTAINERTEXT%']"/>
	
	<xsl:variable name="languageCode" select="//tokens/token[@name='%LANGUAGECODE%']"/>
	<xsl:variable name="language" select="//tokens/token[@name='%LANGUAGE%']"/>
	<xsl:variable name="languages" select="//tokens/token[@name='%LANGUAGES%']"/>
	<xsl:variable name="languageCodes" select="//tokens/token[@name='%LANGUAGECODES%']"/>
	<xsl:variable name="certificationCountryCode" select="//tokens/token[@name='%CERTIFICATIONCOUNTRYCODE%']"/>
	
</xsl:stylesheet>