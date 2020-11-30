<?xml version="1.0" encoding="UTF-8"?>
<!-- 
JHS Common Sheet Scripts [Full Screen (1280x720)]
Dynamic XLST component
Created by: JHSpyHard
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	xmlns:myjs="urn:custom-javascript" 
	exclude-result-prefixes="msxsl myjs">
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<msxsl:script implements-prefix="myjs" language="CSharp">
	
	<!-- Other Assembly Imports -->
	<msxsl:assembly name="System.Windows.Forms" />
	<msxsl:assembly name="mscorlib" /> 
	<msxsl:assembly name="System" /> 
	<msxsl:assembly href="..\scripts\dlls\HtmlAgilityPack.dll"/> 
	
	<![CDATA[
	
	// MEMBER VARIABLES
	
	// Initialized by initializeBlurayPage() and initializeIMDBPage() methods
	private HtmlAgilityPack.HtmlDocument blurayPage;
	private HtmlAgilityPack.HtmlDocument imdbPage;
	
	// Used so that the we don't have to keep parsing the IMDB page for every call of getAspectRatio()
	private string aspectRatio = "";
	
	// MEMBER METHODS
   /**
	* getFormattedChannels() returns the formatted version of the Channels parameter.  If no transformation exists, 
	* then it returns the original parameter with an "ch" appended after.
	* @param channels - The thumbgen value of the number of channels
	* @return Channels in the N.1 channel format.
	*/
	public string getFormattedChannels(string channels)
	{
		if(channels == "1")
			return "1.0 ch";
		else if(channels == "2")
			return "2.0 ch";
		else if(channels == "3")
			return "2.1 ch";
		else if(channels == "4")
			return "4.0 ch";
		else if(channels == "5")
			return "4.1 ch";
		else if(channels == "6")
			return "5.1 ch";
		else if(channels == "7")
			return "6.1 ch";
		else if(channels == "8")
			return "7.1 ch";
		else if(channels == "")
			return "";
		return channels +" ch";
	}
	
	/**
	 * Performs a transformation on aspect ratios to known Lowest Common Demoninator formats.
	 */
	public string getFormattedAspectRatio(string aspectRatio){
		if(aspectRatio == "16:9")
			return "1.78:1";
		else if (aspectRatio == "4:3")
			return "1.33:1";
		return aspectRatio;
	 }
	
	/**
	* renderBox() decides whether the box should be rendered based on if the value is valid.
	* @param boxPath - The folder in which the box image is located.
	* @param boxName - The name of the image as well as its file extension.
	* @param value - The value residing inside of the box.
	* @return The file path and file name (//<PATH>/../Common/<BOXNAME.EXT>) if the value is not empty or "VBR", otherwise
	* it returns an empty string.
	*/
	public string renderBox(string boxPath, string boxName, string value)
	{
		if(value != "" && value != "VBR")
			return boxPath + @"\..\Common\" + boxName;
		else
			return "";
	}
	
	/**
	* renderTextTag() is a method to allow a text tag to be rendered indirectly, by returning the text to displayed, or an empty string.
	* @param value - The value in which to be checked for being empty.
	* @param tagText - The text in which to return if the value parameter is not empty.
	* @return The tagText tag if the value is not empty. Otherwise, it returns an empty string.
	*/
	public string renderTextTag(string value, string tagText)
	{
		if (value == "")
			return value;
		else
			return tagText;
	}
	
   /**
	* CalculateRatingWidth() calculates the number of pixels required to crop an image given the audio/video rating ratio.
	* @param comments - The text contained in the %COMMENTS% field containing rating information and or comments. To specify the rating, 
	* for picture, use the following format: [p || picture] seperated by one or more spaces or colons (:), [rating]/[total]
	* @param totalWidth - Total number of pixels in width of the full star rating image.
	* @param audio - This flag is used to specify whether to return the audio or video rating. If 0, this function will return the appropriate 
	* rating width for picture.  If 1, this function will return the appropriate width for audio.
	* @return  The totalWidth divided by the audio/video rating ratio.
	*/
	public int CalculateRatingWidth(string comments, int totalWidth, bool audio)
	{
		string rating = "";
		if(audio == false)
			rating = getRating(comments, audio);
		else
			rating = getRating(comments, audio);
		
		string[] r = rating.Split('/');
		
		if (r.Length == 2)
		{
			double ratingValue = !string.IsNullOrEmpty(r[0]) ? Convert.ToDouble(r[0]) : 1;
			return (int)(totalWidth * ratingValue / Convert.ToDouble(r[1]));
		}
		return 1;
	}
	
	/**
	* @deprecated
	*
	* getRating() parses the %COMMENTS field returns a string "<RATING>/<TOTAL>" for either audio or picture quality if one exists.
	* @param comments - The contents of the TG %COMMENTS% field. In order for the function to pick up the data, it must be in the format of 
	* Audio rating/total; or Audio: rating/total; or A rating/total or A: rating/total. The same formatting will apply to picture.
	* @param audio - A boolean value that represents which rating value to return. False indicates that you want output returned for picture, 
	* True indicates you want output returned for audio.
	* @return <rating>/<total> string for the desired media, otherwise it returns an empty string.
	*/
	public string getRating(string comments, bool audio)
	{
		char[] linesDelimitors = new char[] {'\r','\n'};
		char[] lineDelimitors = new char[] {':',' '};
		
		string[] lines = comments.Split(linesDelimitors, StringSplitOptions.RemoveEmptyEntries);
		// Search by line
		for(int i = 0; i < lines.Length; ++i)
		{
			string[] lineTokens = lines[i].Split(lineDelimitors, StringSplitOptions.RemoveEmptyEntries);
			if(audio != true)
			{
				if(lineTokens[0].ToLower() == "p" || lineTokens[0].ToLower() == "picture")
				{
					if(lineTokens.Length > 1)
						return lineTokens[1];
					else 
						return "";
				}
			}
			else
			{
				if(lineTokens[0].ToLower() == "a" || lineTokens[0].ToLower() == "audio")
				{
					if(lineTokens.Length > 1)
						return lineTokens[1];
					else 
						return "";
				}
			}
		}
		return "";
	}
	
   /**
	* getStatBoxXCoord() is a helper function that gets the X coordinate for a statistic box. This function expects 6 total boxes.
	* @param total - An int representing the total number of statistics boxes in the set with a valid value.
	* @param totalIndex - An int representing the number of placed statistics boxes.
	* @return The X coordinate for the upper left corner of a the <totalIndex>'th statistic box of a set of statistic boxes of size <total>.
	*/
	private string getStatBoxXCoord(int total, int totalIndex)
	{
		int startPosition = 0;
		int offset = 0; // Default Offset value for 6, 5 boxes
		
		if((total % 2)  == 0) // 6, 4, 2 boxes
		{
			startPosition = 351;
			if (total == 4)
				offset = 1;
			else if(total == 2)
				offset = 2;
		}
		else if((total % 2)  == 1) // 5, 3, 1 boxes
		{
			startPosition = 397;
			if (total == 3)
				offset = 1;
			else if(total == 1)
				offset = 2;
		}
		return Convert.ToString(startPosition + (offset * 92)+(totalIndex * 92));
	}
	
   /**
	* getStatBoxPosition() is a high level function that gets the starting X coordinate for a statistics box.
	* @param boxNumber - This parameter represents the absolute number of the statistic box you want to get the box X position for.
	* VBR = 1, VFR = 2, VAR = 3, ABR = 4, ACH = 5, FSZ= 6
	* @param vbrVal - The value of Video Bit Rate
	* @param vfrVal - The value of Video Frame Rate
	* @param varVal - The value of Video Aspect Ratio
	* @param abrVal - The value of Audio Bit Rate
	* @param achVal - The value of Audio Channels
	* @param fszVal - The value of File Size
	* @return The integer (as a string) of the horizontal starting location for the statistics box, boxNumber.  If there is an issue with the function, it
	* will return "-1".
	*/
	public string getStatBoxPosition(string boxNumber, string vbrVal, string vfrVal, string varVal, string abrVal, string achVal, string fszVal)
	{
		if (Convert.ToInt32(boxNumber) < 1 || Convert.ToInt32(boxNumber) > 6)
			return "-1";
		string [] values = {vbrVal,vfrVal,varVal,abrVal,achVal, fszVal};
		int boxesWithValues = 0; 
		int index = 0;
		// Calculate Total Boxes to be displayed.
		for(int i = 0; i < 6; ++i)
		{
			if(values[i] != "" && values[i] != "VBR")
				++boxesWithValues;
		}
		
		// Now, calculate the index number of the current stat box in the valid set.
		for(int i = 0; i < Convert.ToInt32(boxNumber); ++i)
		{
			if(values[i] != "" && values[i] != "VBR")
				++index;
		}
		// index-1 is used as the parameter because we are switching between
		// index numbering (0-x), to absolute numbering (1-x) in the next function.
		return getStatBoxXCoord(boxesWithValues, index-1);
	}
	
   /**
	* getStatBoxValuePosition() returns the starting position for the text value of a statistics box, 
	* which is calculated to be 9 less than the starting position.
	* @param value - The X coordinate of the statistics box. 
	*/
	public string getStatBoxValuePosition(string value)
	{
		return Convert.ToString(Convert.ToInt32(value)-9);
	}
	
   /**
	* applyMovieTime() inspects the two parameters and returns a string in the format of "Runtime: <***> min."
	* where <***> equals the runtime value if duration is less than 60 seconds.  Otherwise, the duration value is
	* embedded and returned.
	*
	* @param runtime - The variable representing the length of the movie that comes from data collector.
	* @param duration - The variable representing the length of the movie based on the media file.
	* @return The string "Runtime: <***> min." where <***> is based on duration parameter if the duration value 
	* is GT 59. Otherwise, <***> is based on the runtime parameter.
	*/
	public string applyMovieTime(string runtime, string duration)
	{
		if(duration == "0" || duration == "")
			return "Runtime: " + runtime + " min.";
		else
			return "Runtime: " + duration + " min.";
	}
	
   /**
	* notString() verifies that the input value is NOT the same value of the notString.  If the two strings are the same,
	* it returns an empty string.  If they are not the same, value is returned.
	* @param value - A string to be compared to notString.
	* @param notString - Another string to be to value.
	* @return If value and notString are NOT the same, value is returned; otherwise an empty string is returned.
	*/
	public string notString(string value, string notString)
	{
		if(value == notString)
			return "";
		else 
			return value;
	}
	
   /**
	* parseComments() parses the first word or letter of a line in the comments and returns 
	* the text following first letter of the tag or the tag itself. For example
	* ("line1 \n line2 \n b 45 \n blah", "Bicycle") would return "45".
	* ("line1 \n line2 \n bicycle 45 62 \n blah", "Bicycle") would return "45 62".
	* ("line1 \n line2 \n bic 45 \n blah", "Bicycle") would return "".
	* @param comments - Comments String
	* @param tag - the string you are looking for
	* @return The text following the tag found in the comments section to the new line.  If the first 
	* letter of the tag or the tag itself isn't found int the comments, an empty string is returned.
	*/
	public string parseComments(string comments, string tag)
	{
		char[] lineDelimitors = new char[] {'\r','\n'};
		char[] tokenDelimitors = new char[] {':',' '};
		
		string[] lines = comments.Split(lineDelimitors, StringSplitOptions.RemoveEmptyEntries);
		
		// Search by line
		for(int i = 0; i < lines.Length; ++i)
		{
			char[] tagChars = tag.ToCharArray();
			string[] lineTokens = lines[i].Split(tokenDelimitors, StringSplitOptions.RemoveEmptyEntries);
			if(lineTokens[0].ToLower() == tagChars[0].ToString().ToLower() || lineTokens[0].ToLower() == tag.ToLower())
			{
				if(lineTokens.Length > 1)
					//return lineTokens[1];
					return lines[i].Substring(lineTokens[0].Length+1).Trim();
				else 
					return "";
			}
		}
		return "";
	}
	
	private string parseLineComments (string comments, string tag)
	{
		// TODO
		return "";
	}
	
   /**
	* getUserSeasonValue() parses through the comments string looking for a user's season value.  If one can not be found
	* the default %SEASON% field value is returned.
	* @param defaultValue - The value to be returned if no season code is present in comments.
	* @param comments - The block of string containing the season tag and value.
	* @return The season value from the comments if it exists, otherwise returns the defaultValue.
	*/
	public string getUserSeasonValue(string defaultValue, string comments)
	{
		string commentValue = parseComments(comments,"season");
		if(commentValue != "")
			return commentValue;
		else
			return defaultValue;
	}
	
   /**
	* getStudioImagePath() takes in a string of the associated studios. It parses through the string,
	* then checks, in the order in which the studios are presented in the string, then returns the 
	* first studio which has an associated graphic.
	*
	* NOTE: This method makes the ASSUMPTION that the graphics will be located in your \Thumbgen
	* Templates\Common\Studios folder.  If the graphics are not at this location, they will not work.
	*
	* @param studios - A string containing the individual studio names.
	* @return The path of the first existing studio graphic in the input string.
	*/
	public string getStudioImagePath(string studios)
	{
		
		// Parse studios string into tokens
		//debugOutput("--> " + @studios.Replace( @"&","?amp"));
		char[] tokenDelimitors = new char[] {'/',','};
		// TODO: When an ampersand character is in a string processed by Split, it returns 0 as the length.
		// Need to further research String.Split to find out why this is happening, and if it can be
		// prevented.  It seems to be coming IN as an empty string.  This would suggest an issue with XML.
		string[] studio = studios.Split(tokenDelimitors, StringSplitOptions.RemoveEmptyEntries);
		string filePath = "";			
		// Check the studio elements to see if the associated graphic exists in the file path
		for(int i = studio.Length - 1; i >= 0; --i)
		{
			filePath = AppDomain.CurrentDomain.BaseDirectory + @"Templates\Common\Studios\"+ studio[i] +".png";
			if (System.IO.File.Exists(filePath))
			{
				return filePath;
			}
		}
		return "";
	}
		
   /**
	* Gets the IMDB Page URL for the a movie with a specific IMDBID.
	* @param imdbid - The IMDB ID of the movie
	* @return The complete IMDB URL for the movie page.
	*/
	private string getIMDBURL(string imdbID)
	{
		return "http://www.imdb.com/title/tt"+imdbID+"/";
	}
	
	/**
	* initializeIMDBPage() initialized the blurayPage member variable by storing the 
	* page's HTML into that object.
	* @param imdbID - The IMDB ID for a specific movie.
	*/
	private void initializeIMDBPage(string imdbID)
	{
		try
		{
			HtmlAgilityPack.HtmlWeb htmlWeb = new HtmlAgilityPack.HtmlWeb();
			string movieURL = getIMDBURL(imdbID);
			// The Load method is very time expensive.
			imdbPage = htmlWeb.Load(movieURL);
		}
		catch (Exception e)
		{
			debugOutput("Connection Failure");
		}
	}
	
   /**
	* getIMDBAspectRatio() retreives the Aspect Ratio for a specific movie from IMDB.com
	* @param imdbID - The IMDB ID for a specific movie.
	*/
	public string getIMDBAspectRatio(string imdbID)
	{
		if(aspectRatio != "")
			return aspectRatio;
		if(imdbPage == null)
			initializeIMDBPage(imdbID);
		try
		{
			HtmlAgilityPack.HtmlNode node = imdbPage.DocumentNode.SelectSingleNode("//html/body/div[2]/div/div[3]/div/div[4]");
			string tableData = node.WriteContentTo();
			int start = tableData.IndexOf("Aspect Ratio:")+19;
			int stop = tableData.IndexOf("</div>\nSee")-1;
			aspectRatio = tableData.Substring(start,stop-start).Replace(" ",string.Empty);
			return aspectRatio;
		}
		catch(Exception e)
		{
			return "";
		}
	}
	
   /**
	* Gets the URL for the movie on Blu-ray.com 
	* TODO: Waiting for ThumbGen to create a token with this information.
	*/
	private string getBlurayURL()
	{
		//** TESTING GetBlurayQualityScores -- Hard coded for now, Going to need to find a way to build this URL **//
		// Hard coded for now
		return "http://www.blu-ray.com/movies/Batman-Begins-Blu-ray/5/";
	}
	
   /**
	* initializeBlurayPage() initialized the blurayPage member variable by storing the 
	* page's HTML into that object.
	*/
	private void initializeBlurayPage()
	{
		try
		{
			HtmlAgilityPack.HtmlWeb htmlWeb = new HtmlAgilityPack.HtmlWeb();
			string ReviewsURL = getBlurayURL()+ "#UserReviews";
			// This Load method is very time expensive.
			blurayPage = htmlWeb.Load(ReviewsURL);
		}
		catch (Exception e)
		{
			debugOutput("Connection Failure");
		}
	}
	
   /**
	* This method retrieves the Blu-ray.com user's average rating of the video for the 
	* movie. 
	* @param comments - The text contained in the %COMMENTS% field containing rating information and or comments.
	* @param format - The format of the movie file.
	* @return If the format of the movie file is "Blu-ray" or scores is set to off in the comments block, an empty
	* string is returned.  If a picture <value>/<total> comment already exists, it returns that.  Otherwise, a string 
	* containing the Blu-ray.com average user rating for the movie.
	*/
	public string getBlurayVideoScore(string comments, string format)
	{
		if(format != "Blu-ray")
			return "";
		
		if(parseComments(comments,"scores")== "off")
			return "";
			
		string pictureScore = parseComments(comments,"picture");
		if(pictureScore != "")
			return pictureScore;
			
		if(blurayPage == null)
			initializeBlurayPage();

		HtmlAgilityPack.HtmlNode node = blurayPage.DocumentNode.SelectSingleNode("//*[@id='user_rating']//table/tr[2]/td[3]");
		double video = Convert.ToDouble(node.WriteContentTo());
		return video.ToString() + "/5";
	}
	
   /**
	* This method retreives the Blu-ray.com user's average rating of the audio for the movie. 
	* @param comments - The text contained in the %COMMENTS% field containing rating information and or comments.
	* @param format - The format of the movie file.
	* @return If the format of the movie file is "Blu-ray" or scores is set to off in the comments block, an empty
	* string is returned.  If an audio <value>/<total> comment already exists, it returns that.  Otherwise, a string 
	* containing the Blu-ray.com average user rating for the movie.
	*/	
	public string getBlurayAudioScore(string comments, string format)
	{
		if(format != "Blu-ray")
			return "";
		
		if(parseComments(comments,"scores")== "off")
			return "";
		
		string audioScore = parseComments(comments,"audio");
		if(audioScore != "")
			return audioScore;
			
		if(blurayPage == null)
			initializeBlurayPage();
		
		HtmlAgilityPack.HtmlNode node = blurayPage.DocumentNode.SelectSingleNode("//*[@id='user_rating']//table/tr[3]/td[3]");
		double audio = Convert.ToDouble(node.WriteContentTo());
		return audio.ToString() + "/5";
	}
	
   /**
	* TODO: Finish this for 9.5
	* getBlurayAspectRatio() retrieves the Aspect Ratio for a specific movie from Blu-ray.com
	* @return
	*/
	public string getBlurayAspectRatio()
	{
		if(blurayPage == null)
			initializeBlurayPage();

		HtmlAgilityPack.HtmlNode node = blurayPage.DocumentNode.SelectSingleNode("//html/body/center[2]/table/tr[1]/td[4]/table[2]/tr/td[3]");
		string tableData = node.WriteContentTo();
		int start = tableData.IndexOf("Aspect ratio:") + 14;
		int stop = tableData.IndexOf("Original aspect") - 5;
		string aspectRatio = tableData.Substring(start,stop-start);
		return aspectRatio;
	}	
	
   /**
	* debugOutput() pops up a MessageBox during runtime/compilation time, displaying the string 
	* that is passed in as a parameter. The method name from which debugOuput() was called is
	* displayed as the title of the pop-up which is appended with the code line number from where debugOutput 
	* was called.
	* @param output - The string to be printed to the screen.
	*/
	public void debugOutput(string output)
	{
		// Get Diagnostic Objects
		System.Diagnostics.StackFrame stackFrame = new System.Diagnostics.StackFrame(1,true);
		// Get Calling Method Name
		string methodName = stackFrame.GetMethod().Name;
		// Get debugOutput's Calling Line Number.
		string lineNumber = stackFrame.GetFileLineNumber().ToString();
		// Attach Line numbers to the end of the method name and return the output.
		System.Windows.Forms.MessageBox.Show(output,methodName+"(): ln "+lineNumber);
	}
	
   /**
	* getDataValue() looks  to see if a parameter value is empty.  If so, it returns label + "n/a".
	* If it is not empty, it returns label + value.
	* @param label - The label for the field. If the last character isn't a space, one will be appended
	* to the returning result of the method.
	* @param value - The data value.
	* @return <label> + "n/a" if it is empty; otherwise returns <label> + <value>. For instance,
	* getDataValue("Director: ","Steven Speilburg") == "Director: Steven Speilburg"
	* getDataValue("Studio: ", "") == "Studio: n/a"
	* getDataValue("Cast:","Tom Cruise") == "Cast: Tom Cruise")
	*/
	public string getDataValue(string label, string value)
	{
		// Check to see if the last character of <label> is not a space.  If it isn't, add one.
		if(label[label.Length-1] != ' ')
			label = label + " ";
		// If the value is empty, return the label with "n/a" in place of the value.
		if (value == "")
			return label + "n/a";
		// Return the label and the value.
		return label + value;
	}
	
   /**
	* getSubtitlesValue() takes looks to see if a subtitle is to be forced, by looking for 
	* forcedSubtitles / 'f' in the %comments% followed by the country to set the subtitles to.
	* @param comments: The full set of comments from the Thumbgen token.
	* @param defaultValue: The default language that is picked up by thumbgen as the subtitle 
	* langauge.
	* @return The file path of an existing graphic for a subtitle.  If not forced value is given
	* in the %comments*, then the default language file path is returned. If a forced subtitle
	* language image file does not exist on the file system, then an empty string is returned.
	*/
	public string getSubtitlesValue(string comments,string defaultValue)
	{
		string forceValue = parseComments(comments, "forcesubtitles");
		string filePath = AppDomain.CurrentDomain.BaseDirectory + @"Templates\Common\countries\"+ defaultValue +".png";
		if(forceValue != "")
		{
			filePath = AppDomain.CurrentDomain.BaseDirectory + @"Templates\Common\countries\"+ forceValue +".png";
		}
		if (System.IO.File.Exists(filePath))
		{
			return filePath;
		}
		else 
			return "";
	}
	
   /**
	* getAspectRatio() attempts to go out and pull the aspect ratio for the particular format of media. Currently, 
	* the only available option is for the DVD format.  It uses IMDB as the source. TODO: Implement this for blu-rays
	* at blu-ray.com.
	* @param mediaFormat - The format of the media.
	* @param defaultValue - The default Aspect Ratio value
	* @param imdbID - The IMDB ID for the media.
	* @return 
	*/
	public string getAspectRatio(string mediaFormat, string defaultValue, string imdbID)
	{
		string aspectValue = "";
		if(mediaFormat == "DVD")
		{
			aspectValue = getIMDBAspectRatio(imdbID);
			if(aspectValue != "")
				return aspectValue;
		}
		else if(mediaFormat == "Blu-ray")
		{
			// getBlurayAspectRatio();
		}
		
		return getFormattedAspectRatio(defaultValue);
	}
	
   /**
    * getAlternateDataElement() allows you to create alternate attribute, based on whether the primary Data is not empty.
	* If primaryData is empty but seconardaryData is not, then the secondary attribute described by mode is returned.  Otherwise,
	* the primary attribute described by mode is returned.  If an empty string is returned as 
	* @param mode - Two return modes; Label (0) and Label and Data (1).
	* @param primaryLabel - The primary attribute's label 
	* @param primaryData - The primary attribute's data
	* @param secondaryLabel - The secondary attribute's label
	* @param secondaryData - The secondary attribute's data
	* @return See the following examples to get an idea of what the method returns with various inputs.
	*   Examples:
	*	(false, "Director:", "", "Writer:", "Jonesy Prince") -> "Writer:"
	* 	(false, "Director:", "Steven Speilberg", "Writer:", "Tom Cruise") -> "Director:"
	*	(false, "Director:", "", "Writer:", "") -> "Director:"
	*	(true, "Director:", "", "Writer:", "Jonesy Prince") -> "Writer: Jonesy Prince"
	* 	(true, "Director:", "Steven Speilberg", "Writer:", "Tom Cruise") -> "Director: Steven Speilberg"
	*	(false, "Director:", "", "Writer:", "") -> "Director: n/a"
	*/
	public string getAlternateDataElement(bool mode, string primaryLabel, string primaryData, string secondaryLabel, string secondaryData)
	{
		bool isPrimary = false;
		bool isSecondary = false;
		if(primaryData != "" && primaryData != "n/a")
			isPrimary = true;
		if(secondaryData != "" && secondaryData != "n/a")
			isSecondary = true;
			
		if(isPrimary || !isSecondary)
		{
			if(mode == false)
				return primaryLabel;
			if(mode == true)
				return getDataValue(primaryLabel,primaryData);
		}
		else if(isSecondary)
		{
			if(mode == false)
				return secondaryLabel;
			if(mode == true)
				return  getDataValue(secondaryLabel,secondaryData);
		}
		return "getAlernateDataElement() issue.";
	}
	
   /**
	* Retrieves both of the Rotten Tomato and Flixster values from the comments fields, including the separating space characters.
	* @param defaultValue - The value to be returned if no rotten tomato values are present in comments.
	* @param comments - The text contained in the %COMMENTS% field containing rating information and or comments.
	*/
	private string getRottenTomatoFlixsterScores(string defaultValue, string comments)
	{
		string commentValue = parseComments(comments,"rotten");
		if(commentValue != "")
			return commentValue;
		else
			return defaultValue;
	}
   
   /**
    * Parses the Rotten Tomato Score (Index 0) from the Rotten key, from the comments.
	* @param defaultValue - The value to be returned if no rotten tomato values are present in comments.
	* @param comments - The text contained in the %COMMENTS% field containing rating information and or comments.
	* returns A string representation of the Rotten Tomato score, or an empty string.
	*/
	public string getRottenTomatoScore(string defaultValue, string comments, bool season)
	{
		string scorePair = getRottenTomatoFlixsterScores(defaultValue, comments);
		if(scorePair=="")
			return defaultValue;
		// Parse First Score
		char[] scoreDelimitors = new char[] {' '};
		string[] scores = scorePair.Split(scoreDelimitors, StringSplitOptions.RemoveEmptyEntries);
		// If Season is set, and values are present
		if(season && scores.Length == 4 ){
			return scores[2];
		} 
		// If Season is set, but values are NOT present
		else if (season){
			return defaultValue;
		}
		// If Season is NOT set, return default values.
		return scores[0];
	}
	
   /**
	*
	*/
	public string getRottenTomatoIconPath(string basePath, string defaultValue, string comments, bool season)
	{
		string strScore=getRottenTomatoScore(defaultValue, comments, season);
		if(strScore=="")
			return defaultValue;
			
		int numericRtScore = Convert.ToInt32(strScore);
		if (numericRtScore < 0)
			return "";
		// Rotten - LTE 0-59%
		if(numericRtScore >= 0 && numericRtScore <= 59)
			return basePath+@"\..\Common\rotten_tomatoes\tomato-rotten.png";
		// FRESH - GTE 60% && LTE 74%
		if(numericRtScore >= 60 && numericRtScore <= 74)
			return basePath+@"\..\Common\rotten_tomatoes\tomato-fresh.png";
		// CERTIFIED FRESH - GTE 75%
		if(numericRtScore >= 75 && numericRtScore <= 100)
			return basePath+@"\..\Common\rotten_tomatoes\tomato-certifiedfresh.png";
		return "";
	}
	
   /**
	* Parses the Flixster Score (Index 1) from the Rotten key, from the comments.
	* @param defaultValue - The value to be returned if no Flixster values are present in comments.
	* @param comments - The text contained in the %COMMENTS% field containing rating information and or comments.
	* @returns A string representation of the Flixster score, or an empty string.
	*/
	public string getFlixsterScore(string defaultValue, string comments, bool season)
	{
		string scorePair = getRottenTomatoFlixsterScores(defaultValue, comments);
		if(scorePair=="")
			return defaultValue;
		// Parse Second Score
		char[] scoreDelimitors = new char[] {' '};
		string[] scores = scorePair.Split(scoreDelimitors, StringSplitOptions.RemoveEmptyEntries);
		// If Season is set, and values are present
		if(season && scores.Length == 4 ){
			return scores[3];
		} 
		// If Season is set, but values are NOT present
		else if (season){
			return defaultValue;
		}
		// If Season is NOT set, return default values.
		return scores[1];
	}
   /**
	* percentage gives a formatted string consisting of the input followed by a "%" character.
	* @param numericValue - A string representing a numerical number.
	* @returns An empty string if there is no value or the value is less than 0. Otherwise, the input is concatenated with a % character and returns.
	*/
	public string percentage(string numericValue)
	{
		if(numericValue=="" || Convert.ToInt32(numericValue) < 0)
			return "";
		string output=numericValue+"%";
		return output;
	}
	
   /**
	*
	*/
	public string getFlixsterIconPath(string basePath, string defaultValue, string comments, bool season)
	{
		string strScore=getFlixsterScore(defaultValue, comments, season);
		if(strScore=="")
			return defaultValue;
			
		int numericFxScore = Convert.ToInt32(strScore);
		// Parse Second Score
		if(numericFxScore < 0)
			return "";
		// DOWN - LTE 59%
		if(numericFxScore >=0 && numericFxScore <=59)
			return basePath+@"\..\Common\rotten_tomatoes\popcorn-down.png";
		// UP - GTE 60%
		if(numericFxScore >=60 && numericFxScore <=100)
			return basePath+@"\..\Common\rotten_tomatoes\popcorn-up.png";
		debugOutput("FXScore="+numericFxScore);
		return defaultValue;
	}
	
	public string useAltDelimitor(string baseToken, string altDelimitor)
	{
		char[] delimitors = new char[] {'/'};
		string[] tokens = baseToken.Split(delimitors, StringSplitOptions.RemoveEmptyEntries);
		string result = "";
		for(int i = 0; i < tokens.Length; ++i){
			result = result + tokens[i];
			if(i < (tokens.Length - 1)){
				result = result + altDelimitor+" ";
			}
		}
		return result;
	}
	
	public string getRTSeparatorImage(string basePath, string defaultValue, string comments, bool season){
		string rt = getRottenTomatoScore(defaultValue, comments, season);
		string fs = getFlixsterScore(defaultValue, comments, season);
		
		// If RT has a score and is GT than -1
		if(rt != "" ){
			if(Convert.ToInt32(rt) >= 0){
				return basePath+@"\..\Common\Separator.png";
			}
		} 
		// If FS has a score and is GT than -1
		if (fs != ""){
			if(Convert.ToInt32(fs) >= 0){
				return basePath+@"\..\Common\Separator.png";
			}
		}
		// No scores present; Don't return a valid path.
		return defaultValue;
	}
	
    ]]>
	</msxsl:script>
</xsl:stylesheet>