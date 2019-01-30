#!/bin/bash

##########################################################################################
#
# DESCRIPTION
# Deletes Non-MAS Microsoft Office for Mac Apps, including receipt files.
#
##########################################################################################

##########################################################################################
################################### Global Variables #####################################
##########################################################################################


# Overall name of the script for logging
scriptTitle="RemoveNonMASMicrosoftAppsCleanly"

# Log directory
debugDir="/var/log"

# Log file
debugFile="${debugDir}/${scriptTitle}.log"

# Apps to delete
appsArray=(Excel OneNote Outlook PowerPoint Word)

# Package receipts to delete
receiptsArray=(com.microsoft.package.Microsoft_Word.app com.microsoft.pkg.licensing com.microsoft.package.Microsoft_Excel.app com.microsoft.package.Microsoft_OneNote.app com.microsoft.package.Microsoft_Outlook.app com.microsoft.package.Microsoft_PowerPoint.app)

##########################################################################################
#################################### Start functions #####################################
##########################################################################################


setup()
{

    # Make sure we're root & creating logging file

    if [ "$(id -u)" != "0" ]
    then
        /bin/echo "This script must be run as root" 1>&2
        exit 1
    fi

    if [ ! -f "${debugFile}" ]
    then
        /usr/bin/touch "${debugFile}"
    fi

}


start()
{

    # Logging start

    {

        /bin/echo
        /bin/echo "###################-START-##################"
        /bin/echo
        /bin/echo "Running ${swTitle}"
        /bin/echo
        /bin/echo "Started: $(/bin/date)"
        /bin/echo

    } | /usr/bin/tee "${debugFile}"

}


finish()
{

    # Logging finish

    {

        /bin/echo
        /bin/echo "Finished: $(/bin/date)"
        /bin/echo
        /bin/echo "###################-END-###################"

    } | /usr/bin/tee -a "${debugFile}"

}


deleteapps()
{

    # Delete the apps in appsArray, if installed.

    {
        for appTitle in "${appsArray[@]}"
        do
            if [ -d /Applications/"Microsoft ${appTitle}".app ]
            then
            	/bin/echo "Found Microsoft ${appTitle}.app..."
            	if [ -d /Applications/"Microsoft ${appTitle}".app/Contents/_MASRecipt ]
            	then
            		/bin/echo "Microsoft ${appTitle}.app has _MASRecipt folder, skipping..."
            	else
                	/bin/echo "Microsoft ${appTitle}.app does not have a _MASReceipt folder, deleting..."
                	/bin/rm -rf /Applications/"Microsoft ${appTitle}".app
                fi
            else
                /bin/echo "Cannot find Microsoft ${appTitle}.app..."
            fi
        done

    } | /usr/bin/tee -a "${debugFile}"
}


forgetpackagerecipts()
{
	# Remove the package receipts in receiptsArray
	{
	for receiptName in "${receiptsArray[@]}"
        do
            if [[ $( pkgutil --pkg-info ${receiptName} ) ]]
            then
            	/bin/echo "Found ${receiptName}"
            	pkgutil --forget "${receiptName}"
            else
                /bin/echo "Cannot find ${receiptName}..."
            fi
        done
	} | /usr/bin/tee -a "${debugFile}"
}


runrecon()
{
	# Run Jamf recon
	{
	/usr/local/bin/jamf recon
	} | /usr/bin/tee -a "${debugFile}"
}

##########################################################################################
#################################### End functions #######################################
##########################################################################################

setup
start
deleteapps
forgetpackagerecipts
runrecon
finish
