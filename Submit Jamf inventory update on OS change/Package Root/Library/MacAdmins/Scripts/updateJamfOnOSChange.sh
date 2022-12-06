#!/bin/zsh

##########################################################################################
# 
# updateJamfOnOSChange
#
# This script is designed to check the booted OS against the last OS version seen.
# If this changes, run a Jamf recon. Would typically be used with a LaunchDaemon.
# Inspired by:
# https://derflounder.wordpress.com/2022/10/09/running-jamf-pro-inventory-updates-at-startup-time/
#
# Change History
#
# 2022.12.08    -   v1.0    -   Darren Wallace  -   Initial version
# 
##########################################################################################

####################################### Variables ########################################

# Editable Variables
scriptVersion="1.0"
scriptName="updateJamfOnOSChange"

# Other Variables
logDirectory="/Library/Logs/Management"
logFile="${logDirectory}/${scriptName}-${scriptVersion}.log"
jamfBinary="/usr/local/bin/jamf"
preferenceFile="/Library/Preferences/org.macadmins.macoscheck"
preferenceKey="LastOSChecked"
lastcheckedOS="$(/usr/bin/defaults read ${preferenceFile} ${preferenceKey})"
currentOS="$(/usr/bin/sw_vers -productVersion)"

####################################### Functions ########################################

# Functions

checksAndLoggingSetup () {
    # Make sure we're running as root
    if [ "$(id -u)" != "0" ]; then
        /bin/echo "This script must be run as root" 1>&2
        exit 1
    fi
    
    # Make sure our log directories exist
    if [ ! -d "${logDirectory}" ]; then
        /bin/echo "Log directory missing, creating..." 1>&2
        /bin/mkdir -p "${logDirectory}"
        /bin/chmod 775 "${logDirectory}"
    fi
        
    # Make sure our log file exists
    if [ ! -f "${logFile}" ]; then
        /bin/echo "Log file missing, creating..." 1>&2
        /usr/bin/touch "${logFile}"
        /bin/chmod 755 "${logDirectory}"
    fi
}

startLogging (){
    # Starting log entry
        {
        /bin/echo
        /bin/echo "###################-START-##################"
        /bin/echo
        /bin/echo "Running ${scriptName}-${scriptVersion}"
        /bin/echo
        /bin/echo "Started: $(/bin/date)"
        /bin/echo
    } | /usr/bin/tee -a "${logFile}"
}

finishLogging(){
    # Logging finish
        {
        /bin/echo
        /bin/echo "Finished: $(/bin/date)"
        /bin/echo
        /bin/echo "###################-END-###################"
    } | /usr/bin/tee -a "${logFile}"
}

checkOSVersion(){
    # Run a check to see if the booted OS has been checked or not
    /bin/echo "Checking OS versions to confirm if the booted OS has been checked or not"
    /bin/echo "Previous checked OS found to be: ${lastcheckedOS}"
    /bin/echo "Current running OS found to be: ${currentOS}"
    if [[ "${lastcheckedOS}" != "${currentOS}" ]]; then
        /bin/echo "Current OS and previously checked OS differ, we need to run a Jamf recon"
        return 1
    else
        /bin/echo "Current OS and previously checked OS are the same, nothing to do"
        return 0
    fi  
}

checkJSSConnection(){
    # Run a check to see if the Jamf Connection is active or not
    /bin/echo "Running Jamf check JSS Connection command for up to 5 minutes"
    "${jamfBinary}" -checkjssconnection -retry 300
    if [[ "${?}" != 0 ]]; then
        /bin/echo "JSS connection not active"
        return 1
    else
        /bin/echo "JSS connection active!"
        return 0    
    fi
}

OSCheck(){
    # Checking OS for changes
    {
    if checkOSVersion; then
        /bin/echo "Nothing to do, exiting successfully..."
        exit 0
    fi
    /bin/echo "Need to run a Jamf recon, checking for connectivity to Jamf Server..."
    if ! checkJSSConnection; then
        /bin/echo "Unable to connect to Jamf server within 5 minutes, exiting with error"
        /bin/echo "ERROR 2: Unable to connect to Jamf server within 5 minutes"
        exit 2
    fi
    /bin/echo "Jamf Server is avalible, running Jamf recon"
    "${jamfBinary}" recon
    if [[ "${?}" != 0 ]]; then
        /bin/echo "Jamf recon unsuccessful, exiting with error"
        /bin/echo "ERROR 3: Jamf recon unsuccessful, exiting with error"
        exit 3
    fi
    /bin/echo "Jamf recon successful! Updating local record with ${currentOS}"
    /usr/bin/defaults write "${preferenceFile}" "${preferenceKey}" "${currentOS}"
    /bin/echo "Script complete!"
    exit 0
    } | /usr/bin/tee -a "${logFile}"
}


######################################## Script ##########################################

checksAndLoggingSetup
startLogging
OSCheck
finishLogging