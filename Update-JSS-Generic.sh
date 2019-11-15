#!/bin/bash

#####################################################################################
#																					#
#	CUSTOMIZE THE LOOK FOR YOUR SPECIFIC JSS										#
#																					#
#	Be sure to always use hex code for colors.										#
#	These variables will be inserted into hmtl code, so plan accordingling.			#
#																					#
#	If there are any elements you do not wish to include,							#
#	leave the message field blank and it will get skipped.							#
#																					#
#	Be sure to use single quotes '' for these variables.							#
#																	        		#
#####################################################################################

#####################################################################################
#									TOP BANNER										#
#####################################################################################



#	What  the classification banner at the top will say. 
#	Make sure this is only 1 line of text or the rest may not appear.
HEADER_MESSAGE='UNCLASSIFIED // FOUO'

#	What color is the banner at the top? 
HEADER_COLOR='#008000'

#	What color is the font in the banner? 
HEADER_FONT_COLOR='#fff'

#	How big should the banner font be? Do not include the "px", that is added in the next line automatically later.
HEADER_FONT_SIZE=20

#	Calculates how much buffer space to give the header based on the font size.
HEADER_SIZE=$(($HEADER_FONT_SIZE+10))
HEADER_FONT_SIZE+='px'


#####################################################################################
#									EULA											#
#   Define how you want your EULA to appear. You can leave either section blank		#
#   if you choose not to use it.													#
#   Leave both blank if you don't want any EULA at all								#
#####################################################################################

#	EULA Header -> Appears at the top of the popup, above a separating line
EULA_HEADER='NOTICE OF CONDITIONS AND RESTRICTIONS ON SYSTEM'

#	EULA Message -> If you care where the breaks in text appear, be sure to include <br> at each break.
EULA_MESSAGE='You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only.
		<br>
		By using this IS (which includes any device attached to this IS), you consent to the following conditions:
		<br><br>
		The USG routinely intercepts and monitors communications on this IS for purposes  including, but not limited to, penetration testing. COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations.
		<br><br>
		At any time, the USG may inspect and seize data stored on this IS.
		<br><br>
		Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG-authorized purpose.
		<br><br>
		This IS includes security measures (e.g., authentication and access controls) to protect USG interests—not for your personal benefit or privacy.
		<br><br>
		Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants.  Such communications and work product are private and confidential. See User Agreement for details.
'

#####################################################################################
#																					#
#	SPECIFY THE JSS OPERATING SYSTEM												#
#																					#
#	Depending on what OS hosts the JSS, file paths will be different.				#
#	Below the location fo the JSS files are stored in variables.					#
#																					#
#####################################################################################

#	All logs will be written here.
TIMELOG="$(date "+%a %h %d %H:%M:%S"):"

#	If you store your JSS in a custom location, rather than the default for the OS, enter it 
#	in single quotes '' below. Include the trailing / or \. If not, leave this empty.
CUSTOM_JSS=''

# 	Path to JSS Root folder
case $OSTYPE in
	"linux-gnu")
		LOG_LOCATION='/var/log/JSS_Classification_Update.log'
		echo $TIMELOG"OS-DETECT-- Linux OS detected. Script not yet compatible. Exiting" >> "$LOG_LOCATION"
		MAIN_JSS='/usr/local/jss/tomcat/webapps/ROOT/ui/'
		PATH_SEPERATOR='/'
		SED_COM='sed -i'
		;;
	"msys")
		LOG_LOCATION='/var/log/JSS_Classification_Update.log'
		echo $TIMELOG"OS-DETECT-- Windows OS detected. Script not yet compatible. Exiting" >> "$LOG_LOCATION"
		MAIN_JSS='C:\Program Files\JSS\Tomcat\webapps\ROOT\ui\'
		PATH_SEPERATOR='\'
		exit
		;;
	"darwin"*)
		LOG_LOCATION='/var/log/JSS_Classification_Update.log'
		echo $TIMELOG"OS-DETECT-- Mac OS detected" >> "$LOG_LOCATION"
		MAIN_JSS='/Library/JSS/Tomcat/webapps/ROOT/ui/'
		PATH_SEPERATOR='/'
		SED_COM='sed -i ""'
		;;
	*)
		echo $TIMELOG"OS-DETECT-- Unknown OS. Exiting" >> "$LOG_LOCATION"
		exit
		;;
esac

#	Check if a custom JSS location was entered
if [ $CUSTOM_JSS ]
then
	MAIN_JSS=$CUSTOM_JSS 
fi
echo $TIMELOG"JSS-- Reporting "$MAIN_JSS" as the jss location" >> "$LOG_LOCATION"

#	Path to UI.HTML
UI_FILE=$MAIN_JSS"ui.html"
UI_BAK="ui"

#	Path to MAIN.CSS
MAIN_CSS_FILE=$MAIN_JSS"styles"$PATH_SEPERATOR"main.css"
MAIN_BAK="main"


#####################################################################################
#																					#
#	UPDATE FUNCTIONS																#
#																					#
#	These are the functions of updating the individual files.						#
#	Alter these at your own risk!													#
#																					#
#####################################################################################
echo "" >> "$LOG_LOCATION"
echo "" >> "$LOG_LOCATION"
echo $TIMELOG"BEGIN JSS UPDATE-- This is to mark the start of the install for log legibility" >> "$LOG_LOCATION"
echo "" >> "$LOG_LOCATION"
#####################################################################################
#	Create a backup of the current files before making changes.						#
#####################################################################################

#	Verify MAIN.CSS and UI.HTML exist where they are expected.
[ -f $MAIN_CSS_FILE ] && echo $TIMELOG"JSS-- MAIN.CSS present" >> "$LOG_LOCATION" || (echo $TIMELOG"JSS-- MAIN.CSS missing. Terminating update" >> "$LOG_LOCATION" && exit)
[ -f $UI_FILE ] && echo $TIMELOG"JSS-- UI.HTML present" >> "$LOG_LOCATION" || (echo $TIMELOG"JSS-- UI.HTML missing. Terminating update" >> "$LOG_LOCATION" && exit)

#	Path to backup files
BAK_PATH=$MAIN_JSS"bak"$PATH_SEPERATOR

#	Create the BAK folder where backups and BAKorary files will go.
if [ ! -d $BAK_PATH ] ; then
	echo $TIMELOG"BACKUP-- The backup folder was not present. Making it now" >> "$LOG_LOCATION"
	mkdir $BAK_PATH
else
	echo $TIMELOG"BACKUP-- Backup folder detected" >> "$LOG_LOCATION"
	
fi

#	Create a backup of the current UI.HTML file in the $BAK_PATH location.
if [[ -e $BAK_PATH$UI_BAK.html ]] ; then
	i=0
	while [[ -e $BAK_PATH$UI_BAK-$i.html ]] ; do
		let i++
	done
	UI_BAK=$UI_BAK-$i
fi
cp $UI_FILE $BAK_PATH$UI_BAK.html

if [[ -e $BAK_PATH$UI_BAK.html ]] ; then
	echo $TIMELOG"BACKUP-- A backup of UI.HTML has been created and labeled: "$UI_BAK.html >> "$LOG_LOCATION"
else
	echo $TIMELOG"BACKUP-- A backup file of UI.HTML could not be created. Please review the script. The file should have been titled: "$UI_BAK.html >> "$LOG_LOCATION"
fi

#	Create a backup of the current MAIN.CSS file in the $BAK_PATH location.
if [[ -e $BAK_PATH$MAIN_BAK.css ]] ; then
	i=0
	while [[ -e $BAK_PATH$MAIN_BAK-$i.css ]] ; do
		let i++
	done
	MAIN_BAK=$MAIN_BAK-$i
fi
cp $MAIN_CSS_FILE $BAK_PATH$MAIN_BAK.css

if [[ -e $BAK_PATH$MAIN_BAK.css ]] ; then
	echo $TIMELOG"BACKUP-- A backup of MAIN.CSS has been created and labeled: "$MAIN_BAK.css >> "$LOG_LOCATION"
else
	echo $TIMELOG"BACKUP-- A backup file of MAIN.CSS could not be created. Please review the script. The file should have been titled: "$MAIN_BAK.css >> "$LOG_LOCATION"
fi


#####################################################################################
#	Add the banner, if you opted for a banner message above.						#
#####################################################################################

#	Check if the banner message has already been added. It is identified by the "BANNER-HEADER" div id.
#	If you have created your own banner in the past, this will not know how to recognize it.
	BANNER_LINE=0
	BANNER_LINE="$(grep -n 'BANNER-HEADER' $UI_FILE | head -n 1 | cut -d: -f1)"

#	Compile the header into the html format
	HEADER_HTML='<div id='BANNER-HEADER' style="background-color: '$HEADER_COLOR'; text-align:center; font-size: '$HEADER_FONT_SIZE'; color: '$HEADER_FONT_COLOR';"> '$HEADER_MESSAGE' </div>'


if [[ $BANNER_LINE < 1 ]]; then
	echo $TIMELOG"BANNER-- An existing banner was not detected" >> "$LOG_LOCATION"

#	Check for a message to inset in the banner. If $HEADER_MESSAGE was left empty, this will skip.
	if [[ $HEADER_MESSAGE ]] ; then
		echo $TIMELOG"BANNER-- A header message was included. Adding it to UI.HTML now" >> "$LOG_LOCATION"

#		Add the banner header to the UI.HTML file.
		ex -s -c "1i|$HEADER_HTML" -c x $UI_FILE && echo $TIMELOG"BANNER-- Added banner message to top of UI.HTML" >> "$LOG_LOCATION" || echo $TIMELOG"EULA-- Unable to add banner message to top of UI.HTML" >> "$LOG_LOCATION"

#		Update the MAIN.CSS file to ensure the banner goes all the way across
		ORIGINAL_SIDEBAR='#main-sidebar-left{position:fixed;top:0'
		UPDATED_SIDEBAR='#main-sidebar-left{position:fixed;top:'$HEADER_SIZE
		ORIGINAL_HEIGHT='##main-body-wrapper{padding:0;margin:0;width:100%;height:100%;'
		UPDATED_HEIGHT='##main-body-wrapper{padding:0;margin:0;width:100%;height:99%;'
		$SED_COM "s/$ORIGINAL_SIDEBAR/$UPDATED_SIDEBAR/g" $MAIN_CSS_FILE
		$SED_COM "s/$ORIGINAL_HEIGHT/$UPDATE_HEIGHT/g" $MAIN_CSS_FILE
		echo $TIMELOG"BANNER-- The sidebar has been updated to reveal the header all the way across" >> "$LOG_LOCATION"
	else
		echo $TIMELOG"BANNER-- No banner message was entered. Bypassing" >> "$LOG_LOCATION"
	fi
else
	echo $TIMELOG"BANNER-- A banner already exists. Replacing it with new content now" >> "$LOG_LOCATION"
	BANNER_LINE=$BANNER_LINE"d"
	$SED_COM "$BANNER_LINE"  $UI_FILE
	ex -s -c "1i|$HEADER_HTML" -c x $UI_FILE 

fi

#	Verify the header now matches the update.
BANNER_LINE=0
BANNER_LINE="$(grep -n "$HEADER_HTML" $UI_FILE | head -n 1 | cut -d: -f1)"
if [[ $BANNER_LINE != 0 ]] ; then
	echo $TIMELOG"BANNER-- Banner header updated successfully on line "$BANNER_LINE >> "$LOG_LOCATION" 
else
	echo $TIMELOG"BANNER-- There was a problem adding the header" >> "$LOG_LOCATION"
fi

#####################################################################################
#						EULA FORMATTING VARIABLES									#
#####################################################################################

#	Formatting for the EULA message to appear properly. 
#	This is added to the bottom of the MAIN.CSS file.
MAIN_CSS_FORMATING='
/*##########----- EULA--START -----##########*/
#ac-wrapper {
	position: absolute;
	height: 101%;
	background: rgba(112,112,112,.6);
	z-index: 1001;
	margin-top: -'$HEADER_SIZE'px;
	margin-left: -8px;
	width: 101%;
}

#popup{
	margin-top: 10%;
	width: 50%;
	height: auto;
	background: #FFFFFF;
	border-radius: 8px;
	position: relative;
	margin-left: 25%;
}

#poptext1{
	color: #5F5F5F;
	margin: 4%;
	font-size: 20px;
	text-align: left;
}

#poptext2{
	text-align: left;
	margin: 4%;
	color: #000000;
	font-weight: 400
}

.btn {
    background-color: #2f8dfb;
    border: 8px solid #2f8dfb;
    color: white;
    padding: 12px 16px
    font-size: 20px; 
    cursor: pointer;
	border-radius: 35px;
	position: absolute;
	right: 5%;
}

.btn:hover {
    background-color: #5f5f5f;
    border: 8px solid #5f5f5f;
}
/*##########----- EULA--END -----##########*/'

#	The hide-or-show variable and script. Added to UI.HTML so the EULA goes away when accepted.
HIDE_CREATE="<script>var hideOrshow = 'hide'</script>"
HIDE_SCRIPT='
<!–– SCRIPT TO LOAD THE EULA --START ––>
<script type="text/javascript">
	function clickedIt(){
	var hideOrshow = "hide";
	PopUp(hideOrshow);
	}
    
    function PopUp(hideOrshow) {
    if (hideOrshow == "hide") document.getElementById("ac-wrapper").style.display = "none";
    else document.getElementById("ac-wrapper").removeAttribute("style");
	}
	
	window.onload = function () {
    setTimeout(function () {
        PopUp(hideOrshow);}, 00);
	}
</script>
<!–– SCRIPT TO LOAD THE EULA --END ––>'

HIDE_LOAD_ORIGINAL="config = 'ui/auth/loginApp';"
HIDE_LOAD_UPDATED="		var hideOrshow = 'show';"


#	Compile the EULA message for insertion into the UI.HTML
EULA_MESSAGE_CODED='
<!–– EULA--START ––>
<div id="ac-wrapper">
<div id="popup">
<center>	
	<div id="poptext1">
		<br><br>'$EULA_HEADER'
	</div>
	<div><hr></div>
	<div id="poptext2">'$EULA_MESSAGE'
	</div>  
		<button class="btn" onClick="clickedIt()"><i class=""></i>I Agree</button>
		<br><br><br><br>
</div>
</center>
</div>
<!–– EULA--END ––>'

#####################################################################################
#							INSERT THE EULA			1 of 3							#   
#	Check if the formatting data already exists										#
#	If it does, mark the beginning and end of the insert for deletion				#
#####################################################################################

#	These are the identifiers for each segment that gets inserted. 
EULA_FORMAT_START="EULA--START"
EULA_FORMAT_END="EULA--END"
EULA_SCRIPT_START='SCRIPT TO LOAD THE EULA --START'
EULA_SCRIPT_END='SCRIPT TO LOAD THE EULA --END'


#	Check for the formatting code in MAIN.CSS
FORMAT_START="$(grep -n "$EULA_FORMAT_START" $MAIN_CSS_FILE | head -n 1 | cut -d: -f1)"
FORMAT_END="$(grep -n "$EULA_FORMAT_END" $MAIN_CSS_FILE | head -n 1 | cut -d: -f1)"

(( FORMAT_START -= 1 ))
(( FORMAT_END += 1 ))
FORMAT_RANGE=""
[[ $FORMAT_START > 0 ]] && FORMAT_RANGE="$FORMAT_START","$FORMAT_END""d"

#	Check for the script in UI.HTML
SCRIPT_START="$(grep -n "$EULA_SCRIPT_START" $UI_FILE | head -n 1 | cut -d: -f1)"
SCRIPT_END="$(grep -n "$EULA_SCRIPT_END" $UI_FILE | head -n 1 | cut -d: -f1)"

	(( SCRIPT_START -= 1 ))
#	(( SCRIPT_END += 2 ))
SCRIPT_RANGE=""
[[ $SCRIPT_START > 0 ]] && SCRIPT_RANGE="$SCRIPT_START","$SCRIPT_END""d"

#	Check for the EULA in UI.HTML
EULA_START="$(grep -n "$EULA_FORMAT_START" $UI_FILE | head -n 1 | cut -d: -f1)"
EULA_END="$(grep -n "$EULA_FORMAT_END" $UI_FILE | head -n 1 | cut -d: -f1)"

	(( EULA_START -= 1 ))
	(( EULA_END += 1 ))
EULA_RANGE=""
[[ $EULA_START > 0 ]] && EULA_RANGE="$EULA_START","$EULA_END""d"

HIDE_SHOW_COUNT=""
HIDE_SHOW_COUNT="$(grep -n "$HIDE_LOAD_UPDATED" $UI_FILE | head -n 1 | cut -d: -f1)"

#####################################################################################
#							INSERT THE EULA			2 of 3							#
#	Delete the existing EULA message data. If no message was included				#
#	above, this will result in deleting the EULA all together.						#
#####################################################################################

[[ ! $FORMAT_RANGE = "" ]] && $SED_COM "$FORMAT_RANGE" $MAIN_CSS_FILE && echo $TIMELOG"EULA-- Cleared formatting from MAIN.CSS" >> "$LOG_LOCATION" || echo $TIMELOG"EULA-- No formatting present in MAIN.CSS, ready to add it" >> "$LOG_LOCATION"
[[ ! $EULA_RANGE = "" ]] && $SED_COM "$EULA_RANGE" $UI_FILE && echo $TIMELOG"EULA-- Cleared formatting from UI.HTML" >> "$LOG_LOCATION" || echo $TIMELOG"EULA-- No formatting present in UI.HTML, ready to add it" >> "$LOG_LOCATION"
[[ ! $SCRIPT_RANGE = "" ]] && $SED_COM "$SCRIPT_RANGE" $UI_FILE && echo $TIMELOG"EULA-- Cleared script from UI.HTML" >> "$LOG_LOCATION" || echo $TIMELOG"EULA-- No script present in UI.HTML, ready to add it" >> "$LOG_LOCATION"
[[ $HIDE_SHOW_COUNT > 0 ]] && $SED_COM "{/hideOrshow/d;}" $UI_FILE && echo $TIMELOG"EULA-- Cleared hideOrshow variable from UI.HTML" >> "$LOG_LOCATION" || echo $TIMELOG"EULA-- No hideOrshow variable present in UI.HTML, ready to add it" >> "$LOG_LOCATION"

#####################################################################################
#							INSERT THE EULA			3 of 3							#
#	Any old script, format, and EULA data has been deleted.							#
#	Now the data from above will be added back in.									#
#####################################################################################

#	Begin adding the EULA popup
if [[ $EULA_HEADER ]] || [[ $EULA_MESSAGE ]]; then
	echo $TIMELOG"EULA-- EULA data found. Beginning process to add it to JSS" >> "$LOG_LOCATION"
	
#	Adding formating to the end of the MAIN.CSS
	echo "$MAIN_CSS_FORMATING" >> "$MAIN_CSS_FILE" && echo $TIMELOG"EULA-- Formatting for EULA added to MAIN.CSS" >> "$LOG_LOCATION" || echo $TIMELOG"EULA-- Unable to add formatting to MAIN.CSS" >> "$LOG_LOCATION"

#	Adding the hide/show details to UI.HTML
	ex -s -c "1i|$HIDE_CREATE" -c x $UI_FILE && echo $TIMELOG"EULA-- Added hide/show to top of UI.HTML" >> "$LOG_LOCATION" || echo $TIMELOG"EULA-- Unable to add hide/show variable to top of UI.HTML" >> "$LOG_LOCATION"
	
	LINE="$(grep -n "$HIDE_LOAD_ORIGINAL" $UI_FILE | head -n 1 | cut -d: -f1)""i"
	ex -s -c "$LINE|$HIDE_LOAD_UPDATED" -c x $UI_FILE && echo $TIMELOG"EULA-- Added hide/show trigger to UI.HTML" >> "$LOG_LOCATION" || echo $TIMELOG"EULA-- Unable to add hide/show trigger to UI.HTML" >> "$LOG_LOCATION"
	
#	$SED_COM "s/$HIDE_LOAD_ORIGINAL/$HIDE_LOAD_UPDATED/g" "$UI_FILE"
	echo "$HIDE_SCRIPT" >> "$UI_FILE" && echo $TIMELOG"EULA-- Added hide/show logic to bottom of UI.HTML" >> "$LOG_LOCATION" || echo $TIMELOG"EULA-- Unable to add hide/show logic to bottom of UI.HTML" >> "$LOG_LOCATION"
	echo "$EULA_MESSAGE_CODED" >> "$UI_FILE" && echo $TIMELOG"EULA-- Added EULA message to bottom of UI.HTML" >> "$LOG_LOCATION" || echo $TIMELOG"EULA-- Unable to add EULA message to bottom of UI.HTML" >> "$LOG_LOCATION"
else
	echo $TIMELOG"EULA-- No EULA data was found. Bypassing" >> "$LOG_LOCATION"
fi

echo $TIMELOG"UPDATE-- The update has finished" >> "$LOG_LOCATION"