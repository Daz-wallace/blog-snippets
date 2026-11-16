#!/bin/zsh

##########################################################################################
# 
# adobeAppAudit-AppRunningCheck
#
# This script is designed to audit if an Adobe App is installed or not. If not, it'll 
# exit 1 to trigger an installation in an Iru Custom App Library Item. If found, we'll
# then carry out a version comparison using the value of the key specified against the 
# version specified. If the device is running an older version, then we will also exit 1
# If the App is present and an installation is required, we'll try and check if the app 
# is running.
# https://docs.iru.com/en/endpoint/library/library-items-profiles/custom-apps-overview#audit-script-considerations
#
# Change History
#
# 2026.11.16    -   v1.0    -   Daz Wallace  -   Initial version
# 
##########################################################################################

####################################### Variables ########################################

# This should be the full path to the Adobe .app we're looking for.
# e.g "/Applications/Adobe Photoshop 2027/Adobe Photoshop 2027.app"
PathToAdobeApp="/Applications/Adobe Photoshop 2027/Adobe Photoshop 2027.app"

# This should match the version of the application you are deploying, as shown in the 
# info.plist within the deployed application bundle using the key set below in the 
# versionKey variable. If the installed version is less than this, we will trigger the 
# install
# e.g. "28.0.0"
versionToDeploy="28.0.0"

# This should be the key in the Info.plist file that you want to use for version comparison
# e.g. "CFBundleVersion"
versionKey="CFBundleVersion"

# This should be left as-is and will load in the App name set above so we can check if it
# is running
isAppRunningProcess="${PathToAdobeApp##*/}"
isAppRunningProcess="${isAppRunningProcess%.*}"

######################################## Script ##########################################

if [ -e "${PathToAdobeApp}" ]; then
	/bin/echo "Adobe App found at ${PathToAdobeApp}"
	installedVersion=$(/usr/bin/defaults read "${PathToAdobeApp}/Contents/Info.plist" "${versionKey}")
	/bin/echo "Installed version detected as ${installedVersion}"
	/bin/echo "Version to deploy is ${versionToDeploy}"	
	if [[ $installedVersion < $versionToDeploy ]] ; then
		/bin/echo "Installed version is less than version to deploy. Install required"
		/bin/echo "Checking for process called ${isAppRunningProcess}"
		isAppRunning=$(/usr/bin/pgrep -x "${isAppRunningProcess}")
		if [[ "$isAppRunning" == "" ]]; then
			/bin/echo "App not running, triggering install"
			exit 1
		else
			/bin/echo "App IS running, skipping install"
			exit 0
		fi
	else
		/bin/echo "Installed version is the same or greater than the version to deploy."				
		exit 0
	fi
else
	/bin/echo "Adobe App NOT found at ${PathToAdobeApp}"
	exit 1
fi