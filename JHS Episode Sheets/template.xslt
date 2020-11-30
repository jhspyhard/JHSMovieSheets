<?xml version="1.0" encoding="UTF-8"?>
<!-- 
JHS Episode Sheets [Full Screen (1280x720)]
Dynamic XLST component
Created by: JHSpyHard
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:myjs="urn:custom-javascript" exclude-result-prefixes="msxsl myjs">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<!-- Include Scripts Commonly Used Between The Sheets *snicker* -->
	<xsl:include href="..\Common\Scripts\CommonScripts.xslt"/>
	<!-- Include The List of Tokens Used By JHSMovieSheets -->
	<xsl:include href="..\Common\Scripts\ThumbGenTokens.xslt"/>
	
	<!-- The following code makes up the dynamic portions of the template  -->
	<msxsl:script implements-prefix="myjs" language="CSharp">
    <![CDATA[
   /**
	* notApplicable() takes in a string value and looks to see if the string is empty and then returns "n/a"
	* @param value - A string to be checked for being empty
	* @return If value is empty, the string "n/a" is returned.  Otherwise, value is returned.
	*/
	private string notApplicable(string value)
	{
		if(value == "")
			return "n/a";
		else
			return value;
	}
	
   /**
	* getGuestCast() takes a string containing the guest cast and then check it to see if it is empty.
	* If so, it returns "Guest Cast: " and "n/a" if empty, otherwise the guestCast string is appended and returned
	* @param guestCast - The value of the guestCast
	* @return - if guestCast is empty, "Guest Cast: n/a" is returned.  Otherwise, "Guest Cast: <value>" is returned.
	*/
	public string getGuestCast(string guestCast)
	{
		return "Guest Cast: "+ notApplicable(guestCast);
	}
	
    ]]>
	</msxsl:script>
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
   
	<!-- Rendering Picture Quality Rating -->
	<xsl:template match="//Elements/ImageElement[@Name='PQRatingStars']/Actions/Crop/@Width">
			<xsl:attribute name="Width"><xsl:value-of select="myjs:CalculateRatingWidth(string($comments), 135,0)"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='PQRating']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getRating(string($comments),0)"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='PQRatingText']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:renderTextTag(myjs:getRating(string($comments),0),'Picture Quality:')"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='PQRatingTextBold']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:renderTextTag(myjs:getRating(string($comments),0),'Picture Quality:')"/></xsl:attribute>
	</xsl:template>
	
	<!-- Rendering Audio Quality Rating -->
	<xsl:template match="//Elements/ImageElement[@Name='AQRatingStars']/Actions/Crop/@Width">
			<xsl:attribute name="Width"><xsl:value-of select="myjs:CalculateRatingWidth(string($comments), 135,1)"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='AQRating']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getRating(string($comments),1)"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='AQRatingText']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:renderTextTag(myjs:getRating(string($comments),1),'Audio Quality:')"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='AQRatingTextBold']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:renderTextTag(myjs:getRating(string($comments),1),'Audio Quality:')"/></xsl:attribute>
	</xsl:template>
	
	<!-- Rendering the Subtitles -->
	<!-- Label -->
	<xsl:template match="//Elements/TextElement[@Name='SubtitleTEXT']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:renderTextTag(myjs:getSubtitlesValue(string($comments),string($subtitle)), 'Subtitles:')"/></xsl:attribute>
	</xsl:template>
	<!-- Image -->
	<xsl:template match="//Elements/ImageElement[@Name='SubtitleImage']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:getSubtitlesValue(string($comments),string($subtitle))"/></xsl:attribute>
	</xsl:template>
	
	<!-- Rendering of the Tag-line -->
	<!--<xsl:template match="//Elements/TextElement[@Name='Tagline']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:renderTextTag(string($tagline), concat('&quot;',string($tagline),'&quot;'))"/></xsl:attribute>
	</xsl:template>-->
	
	<!-- Rendering the Studio Logo -->
	<xsl:template match="//Elements/ImageElement[@Name='CompanyLogo']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:getStudioImagePath(string($studios))"/></xsl:attribute>
	</xsl:template>
	
	<!-- Verify Data Field Values --> 
	<!-- Episode Title --> 
	<xsl:template match="//Elements/TextElement[@Name='EpisodeTitle']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getDataValue('Episode Title:',string($episodeTitle))"/></xsl:attribute>
	</xsl:template>
	<!-- Aired -->
	<xsl:template match="//Elements/TextElement[@Name='Aired']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getDataValue('Aired:',string($episodeReleaseDate))"/></xsl:attribute>
	</xsl:template>
	<!-- Cast / Director-->
	<xsl:template match="//Elements/TextElement[@Name='Cast']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getAlternateDataElement(1,'Cast:',string($cast),'Director:',string($directors))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='CastBoldText']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getAlternateDataElement(0,'Cast:',string($cast),'Director:',string($directors))"/></xsl:attribute>
	</xsl:template>
	<!-- Guest Cast / Writers -->
	<xsl:template match="//Elements/TextElement[@Name='GuestCast']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getAlternateDataElement(1,'Guest Cast:',string($guestCast),'Writers:',myjs:useAltDelimitor(string($episodeWriters),','))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='GuestCastBoldText']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getAlternateDataElement(0,'Guest Cast:',string($guestCast),'Writers:',myjs:useAltDelimitor(string($episodeWriters),','))"/></xsl:attribute>
	</xsl:template>
	
	<!-- Plot -->
	<xsl:template match="//Elements/TextElement[@Name='Plot']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getDataValue('Plot:',string($episodePlot))"/></xsl:attribute>
	</xsl:template>
	<!-- Runtime -->
	<xsl:template match="//Elements/TextElement[@Name='Runtime']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:applyMovieTime(string($runtime),string($duration))"/></xsl:attribute>
	</xsl:template>
	
	<!-- Rendering; Dynamic Movement of Statistic Boxes and Values -->
	<!-- Video Bitrate -->
	<xsl:template match="//Elements/ImageElement[@Name='vidBRbox']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:renderBox(string($path),'videobitrate.png',string($videoBR))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='vidBRbox']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxPosition('1', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), string($fileSZ))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='VidBRTEXT']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxValuePosition(myjs:getStatBoxPosition('1', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), string($fileSZ)))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='VidBRTEXT']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:notString(string($videoBR), 'VBR')"/></xsl:attribute>
	</xsl:template>
	<!-- Video Framerate -->
	<xsl:template match="//Elements/ImageElement[@Name='vidFRbox']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:renderBox(string($path),'videoframerate.png',string($videoFR))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='vidFRbox']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxPosition('2', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), string($fileSZ))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='fpsTEXT']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxValuePosition(myjs:getStatBoxPosition('2', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), string($fileSZ)))"/></xsl:attribute>
	</xsl:template>
	<!-- Video Aspect Ratio -->
	<xsl:template match="//Elements/ImageElement[@Name='vidARbox']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:renderBox(string($path),'aspectratio.png',myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='vidARbox']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxPosition('3', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), string($fileSZ))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='AspectRatioTEXT']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxValuePosition(myjs:getStatBoxPosition('3', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), string($fileSZ)))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='AspectRatioTEXT']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID))"/></xsl:attribute>
	</xsl:template>
	<!-- Audio Bitrate -->
	<xsl:template match="//Elements/ImageElement[@Name='AudBRbox']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:renderBox(string($path),'audiobitrate.png',string($audioBR))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='AudBRbox']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxPosition('4', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), string($fileSZ))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='AudBRTEXT']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxValuePosition(myjs:getStatBoxPosition('4', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), string($fileSZ)))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='AudBRTEXT']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:notString(string($audioBR), 'VBR')"/></xsl:attribute>
	</xsl:template>
	<!-- Audio Channels -->
	<xsl:template match="//Elements/ImageElement[@Name='AudChanBox']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:renderBox(string($path),'channels.png',string($audioCH))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='AudChanBox']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxPosition('5', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), string($fileSZ))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='AudChanTEXT']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getFormattedChannels(string($audioCH))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='AudChanTEXT']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxValuePosition(myjs:getStatBoxPosition('5', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), string($fileSZ)))"/></xsl:attribute>
	</xsl:template>	
	<!-- File Size -->
	<xsl:template match="//Elements/ImageElement[@Name='filesizebox']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:renderBox(string($path),'filesizebox.png',string($fileSZ))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='filesizebox']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxPosition('6', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), string($fileSZ))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='filesizeTEXT']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxValuePosition(myjs:getStatBoxPosition('6', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), string($fileSZ)))"/></xsl:attribute>
	</xsl:template>
	<!-- Season Box -->
	<xsl:template match="//Elements/ImageElement[@Name='Seasonbox']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:renderBox(string($path),'SeasonNumber.png',myjs:getUserSeasonValue(string($season), string($comments)))"/> </xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='Seasonbox']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxPosition('1', myjs:getUserSeasonValue($season, $comments), string($episode), '', '', '', '')"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='SeasonTEXT']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getUserSeasonValue($season, $comments)"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='SeasonTEXT']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxValuePosition(myjs:getStatBoxPosition('1', myjs:getUserSeasonValue($season, $comments), string($episode), '', '', '', ''))"/></xsl:attribute>
	</xsl:template>	
	<!-- Episode Box -->
	<xsl:template match="//Elements/ImageElement[@Name='Episodebox']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:renderBox(string($path),'EpisodeNumber.png',string($episode))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='Episodebox']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxPosition('2', myjs:getUserSeasonValue($season, $comments),string($episode), '', '', '', '')"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='EpisodeTEXT']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="string($episode)"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='EpisodeTEXT']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxValuePosition(myjs:getStatBoxPosition('2', myjs:getUserSeasonValue($season, $comments), string($episode), '', '', '', ''))"/></xsl:attribute>
	</xsl:template>	
	
	<!-- Rotten Tomatoes / Flixster Scores -->
	<xsl:template match="//Elements/ImageElement[@Name='RTTomatometer']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:getRottenTomatoIconPath(string($path),'',string($comments),0)"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='RTTomatometerText']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:percentage(myjs:getRottenTomatoScore('',string($comments),0))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='FlixterRating']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:getFlixsterIconPath(string($path),'',string($comments),0)"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='FlixterRatingText']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:percentage(myjs:getFlixsterScore('',string($comments),0))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='RTSeparator']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:getRTSeparatorImage(string($path),'',string($comments),0)"/></xsl:attribute>
	</xsl:template>
</xsl:stylesheet>
