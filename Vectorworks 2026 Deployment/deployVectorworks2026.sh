#!/bin/zsh

##########################################################################################
# 
# deployVectorworks2026
#
# This script is designed to help deploy Vectorworks 2026 using their install Manager.
# This will also license the install, set it up to talk to an license server, and config
# the default module.
#
# Credit to:
#	-	Vaughn Miller's blogs on the topic
#		-	https://www.vaughnemiller.com/2025/11/19/deploying-vectorworks-2026/
#		-	https://www.vaughnemiller.com/2025/11/24/deploying-vectorworks-2026-with-munki/
#	-	Allan P's MacAdmins Slack message with the core of this script
#		-	https://macadmins.slack.com/archives/C6ABT55H9/p1761642039824429
#
# Change History
#
# 2026.05.06    -   v1.0    -   Daz Wallace  -   Initial version
# 
##########################################################################################

####################################### Variables ########################################

vectorworksInstallerPath="/private/tmp/Vectorworks 2026 Install Manager.app"
logFile="/tmp/Vectorworks2026.log"
vectorworksSerialNumber="XXXXXX-XXXXXX-XXXXXX-XXXXXX"
vectorworksServerAddress="xxx.yyy.zzzz"
vectorworksServerPort="5053"
vectorworksMainModule="landmark" 


######################################## Script ##########################################


if [ -d "${vectorworksInstallerPath}" ]; then
    /bin/echo "Launching Vectorworks Install Manager..."
    CURRENT_LOGGEDIN_USER="$(/usr/sbin/scutil <<<"show State:/Users/ConsoleUser" | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }' | /usr/bin/awk -F '@' '{print $1}')" 
    myUid=$(/usr/bin/id -u "${CURRENT_LOGGEDIN_USER}")
    myGid=$(/usr/bin/id -g "${CURRENT_LOGGEDIN_USER}")

     "${vectorworksInstallerPath}/Contents/Resources/cli.sh" install -I "/Applications/Vectorworks 2026/" --serial "${vectorworksSerialNumber}" --uid "${myUid}" --gid "${myGid}" | /usr/bin/tee -a "${logFile}"

    if [ ! -e "/Applications/Vectorworks 2026/Settings/SeriesG" ]; then
        /bin/mkdir -p "/Applications/Vectorworks 2026/Settings/SeriesG"
        /usr/sbin/chown -R root:admin "/Applications/Vectorworks 2026"
    fi

    /bin/echo "Setting up the LoginDialog.xml file"
    OUTFILE="/Applications/Vectorworks 2026/Settings/SeriesG/LoginDialog.xml"


(
/bin/cat <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<LoginDialog>

  <Days>1</Days>
  
  <AutoFindServer>0</AutoFindServer>
  
  <AutoFindMaxTime>1</AutoFindMaxTime>
  
  <DontShowAtStartup>1</DontShowAtStartup>
  
  <Servers>
    <Server>${vectorworksServerAddress}:${vectorworksServerPort}</Server>
  </Servers>
  
  <Modules>
    <MainModule>${vectorworksMainModule}</MainModule>
  </Modules>
  
</LoginDialog>
EOF
) > "${OUTFILE}"
else
    /bin/echo "Install Manager not found at ${vectorworksInstallerPath}"
    exit 1
 fi

exit 0