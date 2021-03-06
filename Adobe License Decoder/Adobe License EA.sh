#!/bin/bash

##########################################################################################
#
# NAME:		Adobe License EA
#
# DESCRIPTION
# Will use the Adobe License Decoder tool (https://github.com/adobe/adobe-license-decoder.rs)
# to check the local license installed on a Mac. If found, it'll display the type and 
# expiry date.
#
# PLEASE NOTE: This script is provided as is with no promises of support!
# Please test in your environment before any rollout!
#
##########################################################################################

##########################################################################################
################################### Global Variables #####################################
##########################################################################################

# Set the location of your installed Adobe License Decoder tool here.
adl="/Library/Adobe License Decoder/adobe-license-decoder"

##########################################################################################
##################################### Script #############################################
##########################################################################################

# Check if ADL is present

if [[ ! -a "${adl}" ]]; then
	/bin/echo "Adobe License Decoder not detected"
	result="Adobe License Decoder not installed"
	/bin/echo "<result>${result}</result>"
	exit
else
	/bin/echo "Adobe License Decoder detected, moving on..."
fi

# Run ADL and capture the output
runADL=$("${adl}")
exitcode="${?}"
/bin/echo "Detected as ${exitcode}"

if [[ "${exitcode}" != 0 ]]; then
	/bin/echo "Adobe License not detected, device may be unlicensed or using NUL"
	result="NUL / Unlicensed"
	/bin/echo "<result>${result}</result>"
	exit	
elif [[ "${exitcode}" == 0 ]] && [[ "${runADL}" == *"License type"* ]]; then
	/bin/echo "Adobe License detected, storing data for EA..."
	result=$(/bin/echo "${runADL}" | /usr/bin/grep License | /usr/bin/grep -v files)
	/bin/echo "<result>${result}</result>"
	exit	
else
	/bin/echo "Unexpected output, please review"
	result="Unexpected output, please review"
	/bin/echo "<result>${result}</result>"
	exit 1
fi