#!/bin/zsh

##########################################################################################
# 
# adobeUninstallList
#
# This script is designed to use an already-deployed copy of the Adobe Uninstaller utility
# to get a list of the installed Adobe applications and meta data on a device.
# https://helpx.adobe.com/business/enterprise/deploy-apps-updates/deploy-packages/uninstall-cc-apps.html 
#
# Change History
#
# 2026.11.17    -   v1.0    -   Daz Wallace  -   Initial version
# 
##########################################################################################

####################################### Variables ########################################

# This should be the full path to the Adobe Uninstaller Binary.
# e.g "/Library/My Company Name/Tools/AdobeUninstaller"
PathToAdobeUninstaller="/Library/My Company Name/Tools/AdobeUninstaller"

# Set this to "yes" to have the output as an XML file instead of the default tabular format
# e.g. "Yes"
setOutputToXML="Yes"


######################################## Script ##########################################

if [ -e "${PathToAdobeUninstaller}" ]; then
	/bin/echo "Adobe Uninstaller found at ${PathToAdobeUninstaller}"
	if [[ "${setOutputToXML}" == [yY]([eE][sS]|) ]]; then
		/bin/echo "Output requested as XML"
		"${PathToAdobeUninstaller}" --list --format=XML
		exit 0
	else
		/bin/echo "Output NOT requested as XML. will use tabular output"
		"${PathToAdobeUninstaller}" --list
		exit 0
	fi
else
	/bin/echo "Adobe Uninstaller NOT found at ${PathToAdobeUninstaller}"
	exit 1
fi
	