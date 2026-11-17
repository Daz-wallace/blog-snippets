#!/bin/zsh

##########################################################################################
# 
# adobeUninstallApps
#
# This script is designed to use an already-deployed copy of the Adobe Uninstaller utility
# to remove Adobe Applications from a device. Any applications specified that are missing
# from the local device will be automatically skipped
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

# This should be set to the SAP Code, along with the base version of the title you wish
# to remove. 
# e.g. "PHSP#22.0"
# If you wish to remove multiple version, use a comma to separate the values
# e.g. "PHSP#22.0,ILST#25.0"
# If you wish to remove _all_ Adobe software locally, set this to "all"
# See this for more details: 
# https://helpx.adobe.com/business/enterprise/deploy-apps-updates/deploy-packages/uninstall-cc-apps.html#:~:text=Uninstall%20specific%20apps%20by%20SAP%20code
productsToRemove="PHSP#22.0"

######################################## Script ##########################################

if [ -e "${PathToAdobeUninstaller}" ]; then
	/bin/echo "Adobe Uninstaller found at ${PathToAdobeUninstaller}"
	if [[ "${productsToRemove}" == "all" ]]; then
		/bin/echo "Removal of all Adobe Apps requested"
		"${PathToAdobeUninstaller}" --all
		exit 0
	else
		/bin/echo "Removal of specific Apps requested: ${productsToRemove}"
		"${PathToAdobeUninstaller}" --products="${productsToRemove}" --skipNotInstalled
		exit 0
	fi
else
	/bin/echo "Adobe Uninstaller NOT found at ${PathToAdobeUninstaller}"
	exit 1
fi
	