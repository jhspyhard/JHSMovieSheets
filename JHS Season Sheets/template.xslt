<?xml version="1.0" encoding="UTF-8"?>
<!-- 
JHS Season Sheets [Full Screen (1280x720)]
Dynamic XLST component
Created by: JHSpyHard
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	xmlns:myjs="urn:custom-javascript"
	exclude-result-prefixes="msxsl myjs">	
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<!-- Include Scripts Commonly Used Between The Sheets *snicker* -->
	<xsl:include href="..\Common\Scripts\CommonScripts.xslt"/>
	<!-- Include The List of Tokens Used By JHSMovieSheets -->
	<xsl:include href="..\Common\Scripts\ThumbGenTokens.xslt"/>
		
	<!-- The following code makes up the dynamic portions of the template  -->
	<msxsl:script implements-prefix="myjs" language="CSharp">
	
	<!-- Other Assembly Imports -->
	<msxsl:assembly name="System.Drawing" />
	
    <![CDATA[
	
   /**
	* getFormattedEpisodeNumbers() formats the episodeNumbers string. It looks to see if the episode names  
	* appear on more than one line.  If so, the function inserts a newline into the appropriate place.
	* It also right justifies the episodeNumbers string so that the output's 1's digit is 
	* in numbers less than 10 are lined up with the 1's digit in numbers greater
	* than 10. For example:
	*  9
	* 10
	* 11
	* It is worth noting that the episode numbers will NOT display correctly using current settings if the
	* episodeNumbers values are >= 100. 
	* @param episodeNumbers: A string of int eqivalent characters, with \n and \r seperating the values.
	* @param episodeNames: A string containing the episode names, with the individual values seperated by \n \r.
	* @returns A string of numbers containg appropriate spacing for when an episodeNames value takes up more 
	* than a single line and right justified numbers.
	*/
	public string getFormattedEpisodeNumbers(string episodeNumbers, string episodeNames)
	{
		char[] lineDelimitors = new char[] {'\n','\r'};
		string[] numbers = episodeNumbers.Split(lineDelimitors, StringSplitOptions.RemoveEmptyEntries);
		string[] names = episodeNames.Split(lineDelimitors, StringSplitOptions.RemoveEmptyEntries);
		
		int [] multilineNames = new int[names.Length];
		int mNIndex = 0;
		// Build the multilineNames Array - Need to find a better way to do this.
		for(int i = 0; i < names.Length; ++i)
		{
			if(getNameWidth(names[i]) > 254)
			{
				multilineNames[mNIndex] = i;
				++mNIndex;
			}
		}
		
		int mNSize = mNIndex; // Keep track of the total number of items in multilineNames[]
		
		// Result Set - Size = number of episodes + the number of multiline episode names
		string [] newNumbers = new string[numbers.Length + mNSize]; 

		// Keep track of index into the multilineNames []
		mNIndex = 0; 
		// Keep track of index into the numbers[]
		int numIndex = 0; 
		// Keep track of the number of extra newlines that are put in newNumbers[]
		// FROM multilineNames[]
		int offset = 0; 
		
		//Build the newNumbers array.
		for(int NNindex = 0; NNindex < newNumbers.Length; ++NNindex)
		{
			if(newNumbers[NNindex]=="nl")
			{
				continue;
			}
			else if(numbers[numIndex]=="nl")
			{
				newNumbers[NNindex] = "nl";
			}
			else if(multilineNames.Length != 0 && NNindex == multilineNames[mNIndex]+offset && mNSize > 0)
			{
				newNumbers[NNindex] = numbers[numIndex];
				++offset;
				
				newNumbers[NNindex+1] = "nl";
				++mNIndex;
			}
			else
			{
				newNumbers[NNindex] = numbers[numIndex];
			}
			
			++numIndex;

			// This only works up to episode # 99.
			if(newNumbers[NNindex] != "nl" && Convert.ToInt32(newNumbers[NNindex]) < 10)
			{
				newNumbers[NNindex] = "  " + newNumbers[NNindex];
			}
			
		}
		return convertStringArrayToString(newNumbers);
	}
	
   /**
	* Converts a string array to a string. ie ["a", "b", "nl", "123"] to "a\nb\n\n123".  
	* If a member of the array is "nl", that value is replaced with a new line character in the 
	* returned string.
	*/
	private string convertStringArrayToString(string [] array)
	{
		StringBuilder builder = new StringBuilder();
		foreach(string value in array)
		{
			if(value != "nl")
			{
				builder.Append(value);
			}
			builder.Append("\n");
		}
		return builder.ToString();
	}
	
   /**
	* getNameWidth() takes in a name string and returns the width.
	* @param epiName - A string representing the name of the episode
	* @return The width, in pixels of epiName.
	*/
	private float getNameWidth(string epiName)
	{
		System.Drawing.Graphics graphics = System.Drawing.Graphics.FromImage(new System.Drawing.Bitmap(1, 1));
		System.Drawing.Font fontArial = new System.Drawing.Font("Arial",12);
		float width = graphics.MeasureString(epiName,fontArial).Width;
		return width;
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
	
	<!-- Verify Data Field Values --> 
	<!-- Genre --> 
	<xsl:template match="//Elements/TextElement[@Name='Genre']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getDataValue('Genre:',string($genres))"/></xsl:attribute>
	</xsl:template>
	<!-- Director / Cast-->
	<xsl:template match="//Elements/TextElement[@Name='Director']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getAlternateDataElement(1,'Director:',string($directors),'Cast:',string($cast))"/></xsl:attribute>
	</xsl:template>
		<xsl:template match="//Elements/TextElement[@Name='DirectorBoldText']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getAlternateDataElement(0,'Director:',string($directors),'Cast:',string($cast))"/></xsl:attribute>
	</xsl:template>
	<!-- Studios -->
	<xsl:template match="//Elements/TextElement[@Name='Studios']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getDataValue('Studios:',string($studios))"/></xsl:attribute>
	</xsl:template>
	<!-- Plot -->
	<xsl:template match="//Elements/TextElement[@Name='Plot']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getDataValue('Plot:',string($plot))"/></xsl:attribute>
	</xsl:template>
	<!-- Release Year -->
	<xsl:template match="//Elements/TextElement[@Name='Year']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getDataValue('Released:',string($year))"/></xsl:attribute>
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
	<xsl:template match="//Elements/TextElement[@Name='Tagline']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:renderTextTag(string($tagline), concat('&quot;',string($tagline),'&quot;'))"/></xsl:attribute>
	</xsl:template>
	
	<!-- Rendering; Dynamic Movement of Statistic Boxes and Values -->
	<!-- Video Bitrate -->
	<xsl:template match="//Elements/ImageElement[@Name='vidBRbox']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:renderBox(string($path),'videobitrate.png',string($videoBR))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='vidBRbox']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxPosition('1', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), '')"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='VidBRTEXT']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxValuePosition(myjs:getStatBoxPosition('1', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), ''))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='VidBRTEXT']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:notString(string($videoBR), 'VBR')"/></xsl:attribute>
	</xsl:template>
	<!-- Video Framerate -->
	<xsl:template match="//Elements/ImageElement[@Name='vidFRbox']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:renderBox(string($path),'videoframerate.png',string($videoFR))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='vidFRbox']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxPosition('2', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), '')"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='fpsTEXT']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxValuePosition(myjs:getStatBoxPosition('2', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), ''))"/></xsl:attribute>
	</xsl:template>
	<!-- Video Aspect Ratio -->
	<xsl:template match="//Elements/ImageElement[@Name='vidARbox']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:renderBox(string($path),'aspectratio.png',myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='vidARbox']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxPosition('3', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), '')"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='AspectRatioTEXT']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxValuePosition(myjs:getStatBoxPosition('3', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), ''))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='AspectRatioTEXT']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID))"/></xsl:attribute>
	</xsl:template>
	<!-- Audio Bitrate -->
	<xsl:template match="//Elements/ImageElement[@Name='AudBRbox']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:renderBox(string($path),'audiobitrate.png',string($audioBR))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='AudBRbox']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxPosition('4', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), '')"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='AudBRTEXT']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxValuePosition(myjs:getStatBoxPosition('4', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), ''))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='AudBRTEXT']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:notString(string($audioBR), 'VBR')"/></xsl:attribute>
	</xsl:template>
	<!-- Audio Channels -->
	<xsl:template match="//Elements/ImageElement[@Name='AudChanBox']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:renderBox(string($path),'channels.png',string($audioCH))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='AudChanBox']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxPosition('5', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), '')"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='AudChanTEXT']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getFormattedChannels(string($audioCH))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='AudChanTEXT']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxValuePosition(myjs:getStatBoxPosition('5', string($videoBR), string($videoFR), myjs:getAspectRatio(string($mediaFormat), string($videoAR), string($imdbID)), string($audioBR), string($audioCH), ''))"/></xsl:attribute>
	</xsl:template>
	<!-- Season Box -->
	<xsl:template match="//Elements/ImageElement[@Name='Seasonbox']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:renderBox(string($path),'SeasonNumber.png',string($season))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='Seasonbox']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxPosition('1', myjs:getUserSeasonValue($season, $comments), myjs:parseComments($comments,'disc'), '', '', '', '')"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='SeasonTEXT']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getUserSeasonValue($season, $comments)"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='SeasonTEXT']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxValuePosition(myjs:getStatBoxPosition('1', myjs:getUserSeasonValue($season, $comments), myjs:parseComments($comments,'disc'), '', '', '', ''))"/></xsl:attribute>
	</xsl:template>	
	<!-- Disc Box -->
	<xsl:template match="//Elements/ImageElement[@Name='Discbox']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:renderBox(string($path),'DiscNumber.png',myjs:parseComments($comments,'disc'))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='Discbox']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxPosition('2', myjs:getUserSeasonValue($season, $comments), myjs:parseComments($comments,'disc'), '', '', '', '')"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='DiscTEXT']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:parseComments($comments,'disc')"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='DiscTEXT']/@X">
			<xsl:attribute name="X"><xsl:value-of select="myjs:getStatBoxValuePosition(myjs:getStatBoxPosition('2', myjs:getUserSeasonValue($season, $comments), myjs:parseComments($comments,'disc'), '', '', '', ''))"/></xsl:attribute>
	</xsl:template>	
	
	<!-- Formatted Episode List's-->
	<xsl:template match="//Elements/TextElement[@Name='EpisodeNumbers']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getFormattedEpisodeNumbers(string($episodeNumbers), string($episodeNames))"/></xsl:attribute>
	</xsl:template>
	
	<!-- Get the DISC value from Comments -->
	<xsl:template match="//Elements/TextElement[@Name='DiscTEXT']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:parseComments($comments,'disc')"/></xsl:attribute>
	</xsl:template>
	
	<!-- If a Season code exists in the comments section use that, otherwise, use %SEASON%.-->
	<xsl:template match="//Elements/TextElement[@Name='SeasonTEXT']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:getUserSeasonValue($season, $comments)"/></xsl:attribute>
	</xsl:template>
	
	<!-- Rotten Tomatoes / Flixster Scores -->
	<xsl:template match="//Elements/ImageElement[@Name='RTTomatometer']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:getRottenTomatoIconPath(string($path),'',string($comments),1)"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='RTTomatometerText']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:percentage(myjs:getRottenTomatoScore('',string($comments),1))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='FlixterRating']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:getFlixsterIconPath(string($path),'',string($comments),1)"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/TextElement[@Name='FlixterRatingText']/@Text">
			<xsl:attribute name="Text"><xsl:value-of select="myjs:percentage(myjs:getFlixsterScore('',string($comments),1))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="//Elements/ImageElement[@Name='RTSeparator']/@SourceData">
			<xsl:attribute name="SourceData"><xsl:value-of select="myjs:getRTSeparatorImage(string($path),'',string($comments),1)"/></xsl:attribute>
	</xsl:template>
	
	
</xsl:stylesheet>
