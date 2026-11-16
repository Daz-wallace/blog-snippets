#!/bin/zsh

##########################################################################################
# 
# adobeAppAudit-AppCheckOnly
#
# This script is designed to audit if an Adobe App is installed or not. If not, it'll 
# exit 1 to trigger an installation in an Iru Custom App Library Item. 
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


######################################## Script ##########################################

if [ -e "${PathToAdobeApp}" ]; then
	/bin/echo "Adobe App found at ${PathToAdobeApp}"		
	exit 0
else
	/bin/echo "Adobe App NOT found at ${PathToAdobeApp}"
	exit 1
fi