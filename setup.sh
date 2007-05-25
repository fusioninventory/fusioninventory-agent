#!/bin/sh
################################################################################
#
# OCS Inventory NG Unified Unix Agent Setup
#
# Copyleft 2007 Didier LIROULET
# Web: http://www.ocsinventory-ng.org
#
# This code is open source and may be copied and modified as long as the source
# code is always made freely available.
# Please refer to the General Public Licence http://www.gnu.org/ or Licence.txt
################################################################################
#
# By default, run installer in user interactive mode
# In silent mode
#      param 1 must be ocs server address (__local__ for local inventory method)
#      param 2 can be ocs server port (optional, default to 80)
#      param 3 can be TAG value between quotes (optional)
#      param 4 can be 1 if you want to use daemon mode or 0 for cron task mode (optional, default use cron task)
#              needs Perl Module Proc::Daemon
# Example: sh setup.sh communication_server_address communication_server_port "my site" 1
#          sh setup.sh communication_server_address communication_server_port "my site"
#          sh setup.sh communication_server_address communication_server_port 
#          sh setup.sh __local__
#
# Installer exit with 0 if no errors, 1 if errors while installing agent
#

# Which method is OCS Inventory NG Agent using (http/local)
OCS_AGENT_METHOD="http"

# Which host run OCS Inventory NG Communication Server
# Valid values are 
#     - "__local__" for local inventory generated to file
#     - hostname or ip address to connect to a valid Communicataion Server
OCS_SERVER_HOST="ocsinventory-ng"

# On which port run OCS Inventory NG Communication Server
OCS_SERVER_PORT="80"

# What is the value of TAG administrative information
OCS_AGENT_TAG_VALUE=""

###################### DO NOT MODIFY BELOW #######################

# What is the current operating system (Linux, BSD, AIX...)
OCS_CURRENT_OS=`uname`

# Host value to use if local inventory mode to file
OCS_AGENT_LOCAL_HOST="__local__"

# Where are located OCS Inventory NG Agent configuration files
OLD_OCS_AGENT_CONFIG_DIR="/etc/ocsinventory-client"
OCS_AGENT_CONFIG_DIR="/etc/ocsinventory-agent"
# OCS Inventory NG Agent configuration file name
OCS_AGENT_CONF_FILE="ocsinventory-agent"
# OCS Inventory NG Agent option modules configuration file name
OCS_AGENT_MODULES_FILE="modules.conf"

# Where are located OCS Inventory NG Agent state files
OCS_AGENT_STATE_DIR="/var/lib/ocsinventory-agent"
# OCS Inventory NG Agent state file name
OCS_AGENT_STATE_FILE="ocsinv.conf"
# OCS Inventory NG Agent administrative information file name
OCS_AGENT_ADMININFO_FILE="ocsinv.adm"

# Where are located OCS Inventory NG Agent log files
OLD_OCS_AGENT_LOG_DIR="/var/log/ocsinventory-client"
OCS_AGENT_LOG_DIR="/var/log/ocsinventory-agent"

# Where is located cron configuration directory
CRON_CONF_DIR="/etc/cron.d"
# OCS Inventory NG Agent cron configuration file name
OLD_OCS_AGENT_CRON_FILE="ocsinventory-client"
OCS_AGENT_CRON_FILE="ocsinventory-agent"

# Where is located logrotate configuration directory
LOGROTATE_CONF_DIR="/etc/logrotate.d"
# OCS Inventory NG Agent logrotate configuration file name
OLD_OCS_AGENT_LOGROTATE_FILE="ocsinventory-client"
OCS_AGENT_LOGROTATE_FILE="ocsinventory-agent"

# Where is daemon startup/shutdown scripts system directory
DAEMON_SCRIPT_DIR="/etc/init.d"
OCS_AGENT_DAEMON_SCRIPT_FILE="ocsinventory-agent"

# Where is localted ipdiscover
OCS_AGENT_IPDISCOVER_BIN=`which ipdiscover 2>/dev/null`
OCS_AGENT_IPDISCOVER_VERSION=""

# Where is localted dmidecode
OCS_AGENT_DMIDECODE_BIN=`which dmidecode 2>/dev/null`
OCS_AGENT_DMIDECODE_VERSION=""

# Local computer Device ID
OCS_LOCAL_HOST=`hostname`
OCS_LOCAL_DATE=`date +%Y-%m-%d-%H-%M-%S`
OCS_AGENT_DEVICE_ID="$OCS_LOCAL_HOST-$OCS_LOCAL_DATE"

# OS supporting dmidecode
OCS_OS_LINUX="Linux"
OCS_OS_BSD="BSD"

# By default, run installer in user interactive mode
# In silent mode
#      param 1 must be ocs server address (__local__ for local inventory method)
#      param 2 can be ocs server port (optional, default to 80)
#      param 3 can be TAG value between quotes (optional)
# Example: sh setup.sh communication_server_address communication_server_port "my site"
#          sh setup.sh communication_server_address communication_server_port 
#          sh setup.sh __local__
INSTALLER_INTERACTIVE=1

# Where is located perl interpreter
PERL_BIN=`which perl`

# Where is located C compiler
CC=`which cc`

# Where is located make utility
MAKE=`which make`

# Where to store setup log
SETUP_LOG=`pwd`/ocs_agent_setup.log

echo
echo "+----------------------------------------------------------+"
echo "|                                                          |"
echo "| Welcome to OCS Inventory NG Unified Unix Agent setup !   |"
echo "|                                                          |"
echo "+----------------------------------------------------------+"
echo "Writing log to file $SETUP_LOG"
echo

echo > $SETUP_LOG
echo "Starting OCS Inventory NG Unified Unix Agent setup on $OCS_LOCAL_DATE" >> $SETUP_LOG
echo "Writing log to file $SETUP_LOG" >> $SETUP_LOG
echo >> $SETUP_LOG

echo
echo "+----------------------------------------------------------+"
echo "| Checking for previous installation...                    |"
echo "+----------------------------------------------------------+"
echo
echo "Checking for previous installation" >> $SETUP_LOG
# Checking for Linux agent old setup
if [ -d $OLD_OCS_AGENT_CONFIG_DIR ]
then
    # Previous installation of old Linux agent found
    echo "Previous installation of OCS Inventory NG Linux agent was found."
    echo "Previous installation of OCS Inventory NG Linux agent was found." >> $SETUP_LOG
    # Retreiving OCS Communication server host
    OCS_SERVER_HOST=`eval cat $OLD_OCS_AGENT_CONFIG_DIR/$OCS_AGENT_STATE_FILE | grep OCSFSERVER | cut -d'>' -f2 | cut -d'<' -f1 | cut -d':' -f1` 
    OCS_SERVER_PORT=`eval cat $OLD_OCS_AGENT_CONFIG_DIR/$OCS_AGENT_STATE_FILE | grep OCSFSERVER | cut -d'>' -f2 | cut -d'<' -f1 | cut -d':' -f2`
    OCS_AGENT_DEVICE_ID=`eval cat $OLD_OCS_AGENT_CONFIG_DIR/$OCS_AGENT_STATE_FILE | grep DEVICEID | cut -d'>' -f2 | cut -d'<' -f1 | cut -d':' -f2`
    if [ -z $OCS_SERVER_PORT ] || [ $OCS_SERVER_PORT = $OCS_SERVER_HOST ]
    then
        OCS_SERVER_PORT="80"
    fi
    echo "Found OCS Inventory NG Communication Server host <$OCS_SERVER_HOST>" >> $SETUP_LOG
    echo "Found OCS Inventory NG Communication Server port <$OCS_SERVER_PORT>" >> $SETUP_LOG
    echo "Found OCS Inventory Agent Device ID <$OCS_AGENT_DEVICE_ID>" >> $SETUP_LOG
    OCS_AGENT_PREVIOUS=1
else
    if [ -d $OCS_AGENT_CONFIG_DIR ]
    then
        # Previous installation of unified unix agent found
        echo "Previous installation of OCS Inventory NG Unified Unix Agent was found."
        echo "Previous installation of OCS Inventory NG Unified Unix Agent was found." >> $SETUP_LOG
        # Retreiving OCS Communication server host
        OCS_SERVER_HOST=`eval cat $OCS_AGENT_CONFIG_DIR/$OCS_AGENT_CONF_FILE | grep "server=" | cut -d'"' -f2 | cut -d':' -f1`
        if [ -z "$OCS_SERVER_HOST" ]
        then
            OCS_SERVER_PORT="80"
        fi
        echo "Found OCS Inventory NG Communication Server host <$OCS_SERVER_HOST>" >> $SETUP_LOG
        echo "Found OCS Inventory NG Communication Server port <$OCS_SERVER_PORT>" >> $SETUP_LOG
        echo "Found OCS Inventory Agent Device ID <$OCS_AGENT_DEVICE_ID>" >> $SETUP_LOG
        OCS_AGENT_PREVIOUS=1
    else
        echo "Previous installation of OCS Inventory NG Agent not found"
        echo "Previous installation of OCS Inventory NG Agent not found" >> $SETUP_LOG
        OCS_AGENT_PREVIOUS=0
    fi
fi

echo
echo "+----------------------------------------------------------+"
echo "| Checking for supplied parameters...                      |"
echo "+----------------------------------------------------------+"
echo
echo "Checking for supplied parameters" >> $SETUP_LOG
# Checking if parameters supplied
if [ -z "$1" ]
then
    # No parameters, user intercative installer
    echo "No parameter found"
    echo "OCS Inventory NG Agent setup running in user interactive mode"
    echo "No parameter found" >> $SETUP_LOG
    echo "OCS Inventory NG Agent setup running in user interactive mode" >> $SETUP_LOG
    INSTALLER_INTERACTIVE=1
else
    # Parameters provided, assume silent installer
    echo "Parameters <$1 $2 $3 $4>"
    echo "OCS Inventory NG Agent setup running in silent mode"
    echo "Parameters <$1 $2 $3 $4>" >> $SETUP_LOG
    echo "OCS Inventory NG Agent setup running in silent mode" >> $SETUP_LOG
    INSTALLER_INTERACTIVE=0
    # Which host run OCS Inventory NG Communication Server
    if [ -z "$1" ]
    then
        echo "*** ERROR: Missing parameter 1 Communication Server address"
        echo "Usage: <sh setup.sh> to run installer in interactive mode"
        echo "       <sh setup.sh Param1 Param2 [Param3]> to run installer in silent mode"
        echo "    Parameter 1 must be ocs server address ($OCS_AGENT_LOCAL_HOST for local inventory method)"
        echo "    Parameter 2 can be ocs server port (optional, default to 80)"
        echo "    Parameter 3 can be TAG value between quotes (optional)"
        echo "    Parameter 4 can be 1 if you want to use daemon mode or 0 for cron task mode (optional, default use cron task)"
        echo "Installation aborted !"
        echo "*** ERROR: Missing parameter 1 Communication Server address, installation aborted !" >> $SETUP_LOG
        exit 1
    else
        if [ "$1" = "$OCS_AGENT_LOCAL_HOST" ]
        then
            OCS_AGENT_METHOD="$OCS_AGENT_LOCAL_HOST"
            OCS_SERVER_HOST=$2
        else
            OCS_AGENT_METHOD="http"
            OCS_SERVER_HOST=$2
        fi
    fi
    # On which port run OCS Inventory NG Communication Server
    if [ -z "$2" ]
    then
        OCS_SERVER_PORT="80"
    else
        OCS_SERVER_PORT=$2
    fi
    # What is the value of TAG administrative information
    if [ -z "$3" ]
    then
        OCS_AGENT_TAG_VALUE=""
    else
        OCS_AGENT_TAG_VALUE=$3
    fi
    # What is the value of launch mode
    if [ -z "$4" ]
    then
        INSTALLER_PERL_DAEMON_MODE=0
    else
        INSTALLER_PERL_DAEMON_MODE=$4
    fi
fi
echo

if [ $OCS_AGENT_PREVIOUS -eq 1 ] && [ $INSTALLER_INTERACTIVE -eq 1 ]
then
    # Ask user what to do
    echo "Previous installation of OCS Inventory NG Agent was found."
    if [ "$OCS_SERVER_HOST" = "$OCS_AGENT_LOCAL_HOST" ]
    then
        echo "This installation was generating inventory in local mode to a file."
        OCS_AGENT_METHOD="$OCS_AGENT_LOCAL_HOST"
    else
        echo "This installation was using OCS Inventory NG Communication Server on host"
        echo "$OCS_SERVER_HOST and port $OCS_SERVER_PORT."
        OCS_AGENT_METHOD="http"
    fi
    echo -n "Do you wish to re-install/upgrade existing installation ([y]/n) ?"
    read ligne
    if [ "$ligne" = "y" ] || [ -z "$ligne" ]
    then
        echo "User asked to re-install/upgrade OCS Inventory NG Agent" >> $SETUP_LOG
    else
        echo "Installation aborted !"
        echo "User aborted installation !" >> $SETUP_LOG
        exit 1
    fi
fi


echo
echo "+----------------------------------------------------------+"
echo "| Checking for OCS Inventory NG Agent running method...    |"
echo "+----------------------------------------------------------+"
echo
echo "Checking for OCS Inventory NG Agent running method" >> $SETUP_LOG
if [ $INSTALLER_INTERACTIVE -eq 1 ]
then
    # Ask user for inventory mode (http/__local__)
    echo "OCS Inventory NG Agent can be run through 2 methods:"
    echo "- $OCS_AGENT_LOCAL_HOST: inventory will be generated locally to a file, without"
    echo "         interacting with Communication Server. Inventory results"
    echo "         must then be imported manually into the server through"
    echo "         Administration Console."
    echo "- http: Agent can connect to Communication Server and will interact"
    echo "        with it to know what is has to do (inventory, ipdiscover,"
    echo "        deployment...)"
    res=0
    while [ $res -eq 0 ]
    do
        if [ $OCS_AGENT_METHOD = "$OCS_AGENT_LOCAL_HOST" ]
        then
            # Previous install using local inventory mode
            echo -n "Which method will you use to generate the inventory (http/[local]) ?"
            read ligne
            if [ -z "$ligne" ] || [ "$ligne" = "local"]
            then
                OCS_AGENT_METHOD="$OCS_AGENT_LOCAL_HOST"
                OCS_SERVER_HOST="$OCS_AGENT_LOCAL_HOST"
                res=1
            else
                if [ "$ligne" = "http" ]
                then
                    OCS_AGENT_METHOD="http"
                    res=1
                else
                    res=0
                fi
            fi
        else
            # Previous install using http inventory mode
            echo -n "Which method will you use to generate the inventory ([http]/local) ?"
            read ligne
            if [ -z "$ligne" ] || [ "$ligne" = "http" ]
            then
                OCS_AGENT_METHOD="http"
                res=1
            else
                if [ "$ligne" = "local" ]
                then
                    OCS_AGENT_METHOD="$OCS_AGENT_LOCAL_HOST"
                    OCS_SERVER_HOST="$OCS_AGENT_LOCAL_HOST"
                    res=1
                else
                    res=0
                fi
            fi
        fi
    done
fi
echo "OK, OCS Inventory NG Agent will be running in <$OCS_AGENT_METHOD> mode ;-)"
echo "OCS Inventory NG Agent will be running in <$OCS_AGENT_METHOD> mode" >> $SETUP_LOG
echo

if [ $OCS_AGENT_METHOD = "http" ]
then
    echo
    echo "+----------------------------------------------------------+"
    echo "| Checking for OCS Inventory NG Communication Server...    |"
    echo "+----------------------------------------------------------+"
    echo
    echo "Checking for OCS Inventory NG Communication Server" >> $SETUP_LOG
    if [ $INSTALLER_INTERACTIVE -eq 1 ]
    then
        # Ask user for OCS Inventory NG Communication Server host
        res=0
        while [ $res -eq 0 ]
        do
            echo -n "Which host is running OCS Inventory NG Communication Server [$OCS_SERVER_HOST] ?"
            read ligne
            if [ -z "$ligne" ]
            then
                res=1
            else
                OCS_SERVER_HOST="$ligne"
                res=1
            fi
        done
        # Ask user for OCS Inventory NG Communication Server port
        res=0
        while [ $res -eq 0 ]
        do
            echo -n "On which port is running OCS Inventory NG Communication Server [$OCS_SERVER_PORT] ?"
            read ligne
            if [ -z "$ligne" ]
            then
                res=1
            else
                OCS_SERVER_PORT="$ligne"
                res=1
            fi
        done
    fi
    echo "OK, OCS Inventory NG Communication Server is running on host"
    echo "<$OCS_SERVER_HOST> and port <$OCS_SERVER_PORT> ;-)"
    echo "Using OCS Inventory NG Communication Server running on host <$OCS_SERVER_HOST>, port <$OCS_SERVER_PORT>" >> $SETUP_LOG
    echo
fi

if [ "$OCS_AGENT_METHOD" = "$OCS_AGENT_LOCAL_HOST" ]
then
    # Local mode
    OCS_SERVER_DIR=$OCS_AGENT_LOCAL_HOST
else
    # HTTP mode
    OCS_SERVER_DIR=$OCS_SERVER_HOST:$OCS_SERVER_PORT
fi
echo "OCS Inventory NG Communication Server is located at <$OCS_SERVER_DIR>." >> $SETUP_LOG
echo "Using directory <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR> to store Agent state files." >> $SETUP_LOG

echo
echo "+----------------------------------------------------------+"
echo "| Checking for TAG administrative information value...     |"
echo "+----------------------------------------------------------+"
echo
echo "Checking for TAG administrative information value" >> $SETUP_LOG
if [ -r "$OLD_OCS_AGENT_CONFIG_DIR/label" ]
then
    LABEL=`cat $OLD_OCS_AGENT_CONFIG_DIR/label`
else
    if [ -r "$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR/label" ]
    then
        LABEL=`cat $OCS_AGENT_CONFIG_DIR/$OCS_SERVER_DIR/label`
    else
        LABEL="TAG"
    fi
fi
if [ $INSTALLER_INTERACTIVE -eq 1 ]
then
    if [ -r "$OCS_AGENT_CONFIG_DIR/$OCS_AGENT_ADMININFO_FILE" ]
    then
        # TAG value already inserted => skip
        echo "<$LABEL> already exist, skipping (use Administration Console to update)"
        echo "<$LABEL> already exist, skipping" >> $SETUP_LOG
    else
        # Ask user for TAG value
        res=0
        while [ $res -eq 0 ]
        do
            echo -n "What is the value of $LABEL ([$OCS_AGENT_TAG_VALUE]) ?"
            read ligne
            if [ -z "$ligne" ]
            then
                res=1
            else
                res=1
                OCS_AGENT_TAG_VALUE=$ligne
            fi
        done
        echo "OK, OCS Inventory NG Agent will use <$OCS_AGENT_TAG_VALUE> as <$LABEL> ;-)"
        echo "OCS Inventory NG Agent will use <$OCS_AGENT_TAG_VALUE> as <$LABEL>" >> $SETUP_LOG
    fi
else
    echo "OK, OCS Inventory NG Agent will use <$OCS_AGENT_TAG_VALUE> as <$LABEL> ;-)"
    echo "OCS Inventory NG Agent will use <$OCS_AGENT_TAG_VALUE> as <$LABEL>" >> $SETUP_LOG
fi
echo


# Check if Linux or BSD, which can use dmidecode and/or ipdiscover
echo
echo "+----------------------------------------------------------+"
echo "| Checking for operating system...                         |"
echo "+----------------------------------------------------------+"
echo
OCS_CURRENT_OS_FULL=`uname -a`
OCS_CURRENT_OS=`uname|grep $OCS_OS_LINUX`
if [ -z "$OCS_CURRENT_OS" ]
then
    # Linux not detected, try BSD
    OCS_CURRENT_OS=`uname|grep $OCS_OS_BSD`
    if [ -z "$OCS_CURRENT_OS" ]
    then
         # BSD or Linux not deteted, do not install dmidecode and ipdiscover
         INSTALLER_REQUIRE_DMIDECODE=0
         INSTALLER_REQUIRE_IPDISCOVER=0
         echo "Operating system is $OCS_CURRENT_OS_FULL, not based on Linux or BSD"
         echo "Operating system is $OCS_CURRENT_OS_FULL, not based on Linux or BSD" >> $SETUP_LOG
    else
         # BSD require dmidecode, but not ipdiscover
         INSTALLER_REQUIRE_DMIDECODE=1
         INSTALLER_REQUIRE_IPDISCOVER=0
         echo "Operating system is $OCS_CURRENT_OS_FULL, based on BSD"
         echo "Operating system is $OCS_CURRENT_OS_FULL, based on BSD" >> $SETUP_LOG
    fi
else
    # Linux require dmidecode and ipdiscover
    INSTALLER_REQUIRE_DMIDECODE=1
    INSTALLER_REQUIRE_IPDISCOVER=1
    echo "Operating system is <$OCS_CURRENT_OS_FULL>, based on Linux"
    echo "Operating system is <$OCS_CURRENT_OS_FULL>, based on Linux" >> $SETUP_LOG
fi


echo
echo "+----------------------------------------------------------+"
echo "| Checking for PERL Interpreter...                         |"
echo "+----------------------------------------------------------+"
echo
echo "Checking for PERL Interpreter" >> $SETUP_LOG
if [ -z "$PERL_BIN" ]
then
    echo "*** ERROR: PERL Interpreter not found !"
    echo "OCS Inventory NG is not able to work without PERL Interpreter."
    echo "Setup manually PERL first. Installation aborted !"
    echo "*** ERROR: PERL Interpreter not found. Installation aborted" >> $SETUP_LOG
    exit 1
else
    echo "OK, PERL Intrepreter found at <$PERL_BIN> ;-)"
    echo "PERL Intrepreter found at <$PERL_BIN>" >> $SETUP_LOG
fi
echo


echo
echo "+----------------------------------------------------------+"
echo "| Checking for Make utility...                             |"
echo "+----------------------------------------------------------+"
echo
echo "Checking for Make utility" >> $SETUP_LOG
if [ -z "$MAKE" ]
then
    echo "*** ERROR: Make utility not found !"
    echo "Setup is not able to build OCS Inventory NG Agent Perl module. Installation aborted !"
    echo "*** ERROR: Make utility not found. Installation aborted !" >> $SETUP_LOG
    exit 1
else
    echo "OK, Make utility found at <$MAKE> ;-)"
    echo "Make utility found at <$MAKE>" >> $SETUP_LOG
fi
echo

if [ $INSTALLER_REQUIRE_DMIDECODE -eq 1 ]
then
    # Under Linux and BSD, agent requires dmidecode
    echo
    echo "+----------------------------------------------------------+"
    echo "| Checking for dmidecode binaries...                       |"
    echo "+----------------------------------------------------------+"
    echo
    echo "Checking for dmidecode binaries" >> $SETUP_LOG
    if [ -z "$OCS_AGENT_DMIDECODE_BIN" ]
    then
        echo "WARNING: dmidecode binaries not found !"
        echo "WARNING: dmidecode binaries not found" >> $SETUP_LOG
        if [ $INSTALLER_INTERACTIVE -eq 1 ]
        then
            # Ask user to setup dmidecode
            echo "OCS Inventory NG Agent requires dmidecode to get information from BIOS."
            echo "But dmidecode is not installed on this computer."
            echo -n "Do you wish to continue (y/[n]) ?"
            read ligne
            if [ -z "$ligne" ] || [ "$ligne" = "n" ]
            then
                echo "OCS Inventory NG is not able to get BIOS informations without dmidecode."
                echo "Setup manually dmidecode first. Installation aborted !"
                echo "*** ERROR: User aborted installation !" >> $SETUP_LOG
                exit 1
            else
                echo "OK, dmidecode missing, but user asks to continue :-("
                echo "dmidecode missing but user ask to continue" >> $SETUP_LOG
            fi
        else
            # Silent setup
            echo "WARNING: OCS Inventory NG is not able to get BIOS informations without dmidecode." 
            echo "WARNING: OCS Inventory NG is not able to get BIOS informations without dmidecode." >> $SETUP_LOG
            echo "But dmidecode is not installed on this computer. Some functionality may lack !"
            echo "But dmidecode is not installed on this computer. Some functionality may lack !" >> $SETUP_LOG
        fi
    else
        # Get installed dmidecode version
        INSTALLED_DMIDECODE_VERSION=`$OCS_AGENT_DMIDECODE_BIN | grep "# dmidecode" | cut -d' ' -f3`
        echo "Found dmidecode binaries version <$INSTALLED_DMIDECODE_VERSION> at <$OCS_AGENT_DMIDECODE_BIN> ;-)"
        echo "Found dmidecode binaries version <$INSTALLED_DMIDECODE_VERSION> at <$OCS_AGENT_DMIDECODE_BIN>" >> $SETUP_LOG
    fi
    echo
else
    # 0ther OS do not use dmidecode
    INSTALLER_REQUIRE_DMIDECODE=0
fi


if [ $INSTALLER_REQUIRE_IPDISCOVER -eq 1 ]
then
    # Under Linux, agent requires ipdiscover
    echo
    echo "+----------------------------------------------------------+"
    echo "| Checking for ipdiscover binaries...                      |"
    echo "+----------------------------------------------------------+"
    echo
    echo "Checking for ipdiscover binary" >> $SETUP_LOG
    if [ -z "$OCS_AGENT_IPDISCOVER_BIN" ]
    then
        echo "WARNING: ipdiscover binary not found !"
        echo "WARNING: ipdiscover binary not found" >> $SETUP_LOG
        if [ $INSTALLER_INTERACTIVE -eq 1 ]
        then
            # Ask user to setup dmidecode
            echo "OCS Inventory NG Agent requires ipdiscover to launch network discovery."
            echo "But ipdiscover is not installed on this computer."
            echo -n "Do you wish to continue (y/[n]) ?"
            read ligne
            if [ -z "$ligne" ] || [ "$ligne" = "n" ]
            then
                echo "OCS Inventory NG is not able to get launch network discovery without ipdiscover."
                echo "Setup manually ipdiscover first. Installation aborted !"
                echo "*** ERROR: User aborted installation !" >> $SETUP_LOG
                exit 1
            else
                echo "OK, ipdiscover missing, but user asks to continue :-("
                echo "ipdiscover missing but user ask to continue" >> $SETUP_LOG
            fi
        else
            # Silent setup
            echo "WARNING: OCS Inventory NG is not able to launch network discovery without ipdiscover." 
            echo "WARNING: OCS Inventory NG is not able to launch network discovery without ipdiscover." >> $SETUP_LOG
            echo "But ipdiscover is not installed on this computer. Some functionality may lack !"
            echo "But ipdiscover is not installed on this computer. Some functionality may lack !" >> $SETUP_LOG
        fi
    else
        # Get installed ipdiscover version
        INSTALLED_IPDISCOVER_VERSION=`$OCS_AGENT_IPDISCOVER_BIN | grep "IPDISCOVER binary ver." | cut -d' ' -f4`
        echo "Found ipdiscover binary version <$INSTALLED_IPDISCOVER_VERSION> at <$OCS_AGENT_IPDISCOVER_BIN> ;-)"
        echo "Found ipdiscover binary version <$INSTALLED_IPDISCOVER_VERSION> at <$OCS_AGENT_IPDISCOVER_BIN>" >> $SETUP_LOG
    fi
    echo
else
    # Never setup ipdiscover under other OS
    INSTALLER_REQUIRE_IPDISCOVER=0
fi


echo
echo "+----------------------------------------------------------+"
echo "| Checking for Compress::Zlib PERL module...               |"
echo "+----------------------------------------------------------+"
echo
echo "Checking for Compress::Zlib PERL module" >> $SETUP_LOG
$PERL_BIN -mCompress::Zlib -e 'print "PERL module Compress::Zlib is available\n"' >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "*** ERROR: OCS Inventory NG Agent requires PERL module Compress::Zlib."
    echo "Install it manually first. Installation aborted !"
    echo "*** ERROR: PERL module Compress::Zlib not installed, installation aborted" >> $SETUP_LOG
    exit 1
else
    echo "OK, PERL module Compress::Zlib is available ;-)"
fi
echo


echo
echo "+----------------------------------------------------------+"
echo "| Checking for XML::Simple PERL module...                  |"
echo "+----------------------------------------------------------+"
echo
echo "Checking for XML::Simple PERL module" >> $SETUP_LOG
$PERL_BIN -mXML::Simple -e 'print "PERL module XML::Simple is available\n"' >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "*** ERROR: OCS Inventory NG Agent requires PERL module XML::Simple."
    echo "Install it manually first. Installation aborted !"
    echo "*** ERROR: PERL module XML::Simple not installed, installation aborted" >> $SETUP_LOG
    exit 1
else
    echo "OK, PERL module XML::Simple is available ;-)"
fi
echo


echo
echo "+----------------------------------------------------------+"
echo "| Checking for Net::IP PERL module...                      |"
echo "+----------------------------------------------------------+"
echo
echo "Checking for Net::IP PERL module" >> $SETUP_LOG
$PERL_BIN -mNet::IP -e 'print "PERL module Net::IP is available\n"' >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "*** ERROR: OCS Inventory NG Agent requires PERL module Net::IP."
    echo "Install it manually first. Installation aborted !"
    echo "*** ERROR: PERL module Net::IP not installed, installation aborted" >> $SETUP_LOG
    exit 1
else
    echo "OK, PERL module Net::IP is available ;-)"
fi
echo


echo
echo "+----------------------------------------------------------+"
echo "| Checking for LWP::UserAgent PERL module...               |"
echo "+----------------------------------------------------------+"
echo
echo "Checking for LWP::UserAgent PERL module" >> $SETUP_LOG
$PERL_BIN -mLWP::UserAgent -e 'print "PERL module LWP::UserAgent is available\n"' >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "*** ERROR: OCS Inventory NG Agent requires PERL module LWP::UserAgent."
    echo "Install it manually first. Installation aborted !"
    echo "*** ERROR: PERL module LWP::UserAgent not installed, installation aborted" >> $SETUP_LOG
    exit 1
else
    echo "OK, PERL module LWP::UserAgent is available ;-)"
fi
echo


echo
echo "+----------------------------------------------------------+"
echo "| Checking for Digest::MD5 PERL module...                  |"
echo "+----------------------------------------------------------+"
echo
echo "Checking for Digest::MD5 PERL module" >> $SETUP_LOG
$PERL_BIN -mDigest::MD5 -e 'print "PERL module Digest::MD5 is available\n"' >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "*** ERROR: OCS Inventory NG Agent requires PERL module Digest::MD5."
    echo "Install it manually first. Installation aborted !"
    echo "*** ERROR: PERL module Digest::MD5 not installed, installation aborted" >> $SETUP_LOG
    exit 1
else
    echo "OK, PERL module Digest::MD5 is available ;-)"
fi
echo


echo
echo "+----------------------------------------------------------+"
echo "| Checking for Net::SSLeay PERL module...                  |"
echo "+----------------------------------------------------------+"
echo
echo "Checking for Net::SSLeay PERL module" >> $SETUP_LOG
$PERL_BIN -mNet::SSLeay -e 'print "PERL module Net::SSLeay is available\n"' >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "*** ERROR: OCS Inventory NG Agent requires PERL module Net::SSLeay."
    echo "Install it manually first. Installation aborted !"
    echo "*** ERROR: PERL module Net::SSLeay not installed, installation aborted" >> $SETUP_LOG
    exit 1
else
    echo "OK, PERL module Net::SSLeay is available ;-)"
fi
echo


echo
echo "+----------------------------------------------------------+"
echo "| Checking for Proc::Daemon PERL module...                 |"
echo "+----------------------------------------------------------+"
echo
echo "Checking for Proc::Daemon PERL module" >> $SETUP_LOG
$PERL_BIN -mProc::Daemon -e 'print "PERL module Proc::Daemon is available\n"' >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "WARNING: PERL module Proc::Daemon not installed !"
    echo "WARNING: PERL module Proc::Daemon not installed" >> $SETUP_LOG
    if [ $INSTALLER_INTERACTIVE -eq 1 ]
    then
        # Ask user to setup dmidecode
        echo "OCS Inventory NG Agent requires PERL module Proc::Daemon to run as a daemon."
        echo "But PERL module Proc::Daemon is not installed on this computer."
        echo "So you must run OCS Inventory NG Agent through a cron task."
        echo -n "Do you wish to continue (y/[n]) ?"
        read ligne
        if [ -z "$ligne" ] || [ "$ligne" = "n" ]
        then
            echo "OCS Inventory NG Agent is not able to run as a daemon without PERL module Proc::Daemon."
            echo "Setup manually PERL module Proc::Daemon first. Installation aborted !"
            echo "*** ERROR: User aborted installation !" >> $SETUP_LOG
            exit 1
        else
            echo "OK, PERL module Proc::Daemon missing, but user asks to continue, so using cron task :-("
            echo "PERL module Proc::Daemon missing but user ask to continue, so using cron task" >> $SETUP_LOG
        fi
    else
        # Silent setup
        if [ INSTALLER_PERL_DAEMON_MODE -eq 1 ]
        then
            # User asked by command line to use daemon mode
            echo "*** ERROR: OCS Inventory NG is not able to run as a daemon without PERL module Proc::Daemon." 
            echo "*** ERROR: OCS Inventory NG is not able to run as a daemon without PERL module Proc::Daemon." >> $SETUP_LOG
            exit 1
        else
            # Userasked to use cron task
            echo "WARNING: OCS Inventory NG Agent is not able to run as a daemon without PERL module Proc::Daemon." 
            echo "WARNING: OCS Inventory NG Agent is not able to run as a daemon without PERL module Proc::Daemon." >> $SETUP_LOG
            echo "But user asked running Agent through a cron task ;-)"
            echo "But user asked running Agent through a cron task" >> $SETUP_LOG
        fi
    fi
    INSTALLER_PERL_DAEMON_MODE=0
else
    echo "OK, PERL module Proc::Daemon is available ;-)"
    if [ $INSTALLER_INTERACTIVE -eq 1 ]
    then
        # Ask user which method to use (cron task or daemon)
        echo "OCS Inventory NG Agent is able to run as a daemon, or through a cron task."
        echo "Using daemon enables you to configure from Administration Console how"
        echo "many times a day Agent will contact with Communication Server (from 1 up"
        echo "to 99 hours), and others options."
        echo "By default, cron task only launch OCS Inventory NG Agent once a day."
        echo -n "Which method do you want to use (cron/[daemon]) ?"
        read ligne
        if [ -z "$ligne" ] || [ "$ligne" = "daemon" ]
        then
            echo "Setup will NOT create cron task, because you want to use daemon mode."
            echo "User asked to use daemon mode !" >> $SETUP_LOG
            echo "Setup need to know where to store daemon start/stop script used in runlevels."
            echo -n "Where is located init.d system directory [$DAEMON_SCRIPT_DIR] ?"
            read ligne
            if [ -n "$ligne" ]
            then
                DAEMON_SCRIPT_DIR=$ligne
            fi
            echo "OK. Using <$DAEMON_SCRIPT_DIR> for system init.d directory." 
            echo "Using <$DAEMON_SCRIPT_DIR> for system init.d directory." >> $SETUP_LOG 
            INSTALLER_PERL_DAEMON_MODE=1
        else
            echo "Setup will automtically create cron task to launch OCS Inventory NG Agent once a day."
            echo "User asked to use cron task mode !" >> $SETUP_LOG
            INSTALLER_PERL_DAEMON_MODE=0
        fi
    else
        # Silent installer
        if [ INSTALLER_PERL_DAEMON_MODE -eq 1 ]
        then
            # User asked by command line to use daemon mode
            echo "OCS Inventory NG Agent will be run as daemon with PERL module Proc::Daemon." 
            echo "OCS Inventory NG Agent will be run as daemon with PERL module Proc::Daemon." >> $SETUP_LOG
        else
            # Userasked to use cron task
            echo "WARNING: OCS Inventory NG Agent will be launched as a cron task, even with PERL module Proc::Daemon installed." 
            echo "WARNING: OCS Inventory NG Agent will be launched as a cron task, even with PERL module Proc::Daemon installed." >> $SETUP_LOG
            echo "Because user asked running Agent through a cron task ;-)"
            echo "Because user asked running Agent through a cron task" >> $SETUP_LOG
        fi
    fi
fi
echo


echo
echo "+----------------------------------------------------------+"
echo "| Installing OCS Inventory NG Unified Unix Agent...        |"
echo "+----------------------------------------------------------+"
echo
echo "Configuring OCS Inventory NG Unified Unix Agent"
echo "Configuring OCS Inventory NG Unified Unix Agent" >> $SETUP_LOG
$PERL_BIN Makefile.PL >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "*** ERROR: Unable to configure OCS Inventory NG Agent !"
    echo "*** ERROR: Unable to configure OCS Inventory NG Agent" >> $SETUP_LOG
    echo "Look at file $SETUP_LOG for detailled error and fix it manually"
    echo "before running another time OCS Inventory NG Agent setup."
    echo "Installation aborted !"
    exit 1
fi 
echo "Building OCS Inventory NG Unified Unix Agent"
echo "Building OCS Inventory NG Unified Unix Agent" >> $SETUP_LOG
$MAKE >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "*** ERROR: Unable to build OCS Inventory NG Agent !"
    echo "*** ERROR: Unable to build OCS Inventory NG Agent" >> $SETUP_LOG
    echo "Look at file $SETUP_LOG for detailled error and fix it manually"
    echo "before running another time OCS Inventory NG Agent setup."
    echo "Installation aborted !"
    exit 1
fi 
echo "Installing OCS Inventory NG Unified Unix Agent"
echo "Installing OCS Inventory NG Unified Unix Agent" >> $SETUP_LOG
$MAKE install >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "*** ERROR: Unable to install OCS Inventory NG Agent !"
    echo "*** ERROR: Unable to install OCS Inventory NG Agent" >> $SETUP_LOG
    echo "Look at file $SETUP_LOG for detailled error and fix it manually"
    echo "before running another time OCS Inventory NG Agent setup."
    echo "Installation aborted !"
    exit 1
fi 
echo "Creating OCS Inventory NG Agent symbolic link </bin/ocsinv>"
echo "Creating OCS Inventory NG Agent symbolic link </bin/ocsinv>" >> $SETUP_LOG
rm -f /bin/ocsinv
ln -s /usr/bin/ocsinventory-agent /bin/ocsinv >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "*** ERROR: Unable to create OCS Inventory NG Agent symbolic link </bin/ocsinv> !"
    echo "*** ERROR: Unable to install OCS Inventory NG Agent symbolic link </bin/ocsinv>" >> $SETUP_LOG
    echo "Look at file $SETUP_LOG for detailled error and fix it manually"
    echo "before running another time OCS Inventory NG Agent setup."
    echo "Installation aborted !"
    exit 1
fi 
echo "OK, OCS Inventory NG Agent setup successfully ;-)"
echo "OCS Inventory NG Agent setup successfully" >> $SETUP_LOG
echo


echo
echo "+----------------------------------------------------------+"
echo "| Creating OCS Inventory NG Agent log directory...         |"
echo "+----------------------------------------------------------+"
echo
if [ -d $OLD_OCS_AGENT_LOG_DIR ]
then
    echo "Removing old OCS Inventory NG Agent for Linux log directory <$OLD_OCS_AGENT_LOG_DIR>."
    echo "Removing old OCS Inventory NG Agent for Linux log directory <$OLD_OCS_AGENT_LOG_DIR>." >> $SETUP_LOG
    rm -Rf $OLD_OCS_AGENT_LOG_DIR >> $SETUP_LOG 2>&1
fi
echo "Creating OCS Inventory NG Agent log directory <$OCS_AGENT_LOG_DIR>."
echo "Creating OCS Inventory NG Agent log directory <$OCS_AGENT_LOG_DIR>" >> $SETUP_LOG
mkdir -p $OCS_AGENT_LOG_DIR >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "*** ERROR: Unable to create OCS Inventory NG Agent log directory <$OCS_AGENT_LOG_DIR> !"
    echo "*** ERROR: Unable to create OCS Inventory NG Agent log directory <$OCS_AGENT_LOG_DIR>" >> $SETUP_LOG
    echo "Look at file $SETUP_LOG for detailled error and fix it manually"
    echo "before running another time OCS Inventory NG Agent setup."
    echo "Installation aborted !"
    exit 1
fi
if [ -r $LOGROTATE_CONF_DIR/$OLD_OCS_AGENT_LOGROTATE_FILE ]
then
    echo "Removing old OCS Inventory NG Agent for Linux logrotate conf <$LOGROTATE_CONF_DIR/$OLD_OCS_AGENT_LOGROTATE_FILE>."
    echo "Removing old OCS Inventory NG Agent for Linux logrotate conf <$LOGROTATE_CONF_DIR/$OLD_OCS_AGENT_LOGROTATE_FILE>." >> $SETUP_LOG
    rm -f $LOGROTATE_CONF_DIR/$OLD_OCS_AGENT_LOGROTATE_FILE >> $SETUP_LOG 2>&1
fi
echo "Creating logrotate configuration for OCS Inventory NG Agent."
echo "Creating logrotate configuration for OCS Inventory NG Agent" >> $SETUP_LOG
cp etc/logrotate.d/$OCS_AGENT_LOGROTATE_FILE etc/logrotate.d/$OCS_AGENT_LOGROTATE_FILE.local >> $SETUP_LOG 2>&1
$PERL_BIN -pi -e "s#PATH_TO_LOG_DIRECTORY#$OCS_AGENT_LOG_DIR#g" etc/logrotate.d/$OCS_AGENT_LOGROTATE_FILE.local >> $SETUP_LOG 2>&1
echo "******** Begin updated logrotate configuration file <$OCS_AGENT_LOGROTATE_FILE> ***********" >> $SETUP_LOG
cat etc/logrotate.d/$OCS_AGENT_LOGROTATE_FILE.local >> $SETUP_LOG
echo "******** End updated logrotate configuration file <$OCS_AGENT_LOGROTATE_FILE> ***********" >> $SETUP_LOG
echo "Installing OCS Inventory NG Agent logrotate configuration file <$LOGROTATE_CONF_DIR/$OCS_AGENT_LOGROTATE_FILE>"
echo "Installing OCS Inventory NG Agent logrotate configuration file <$LOGROTATE_CONF_DIR/$OCS_AGENT_LOGROTATE_FILE>" >> $SETUP_LOG
cp -f etc/logrotate.d/$OCS_AGENT_LOGROTATE_FILE.local $LOGROTATE_CONF_DIR/$OCS_AGENT_LOGROTATE_FILE >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "*** ERROR: Unable to write OCS Inventory NG Agent logrotate configuration file <$LOGROTATE_CONF_DIR/$OCS_AGENT_LOGROTATE_FILE> !"
    echo "*** ERROR: Unable to write OCS Inventory NG Agent logrotate configuration file <$LOGROTATE_CONF_DIR/$OCS_AGENT_LOGROTATE_FILE>" >> $SETUP_LOG
    echo "Look at file $SETUP_LOG for detailled error and fix it manually"
    echo "before running another time OCS Inventory NG Agent setup."
    echo "Installation aborted !"
    exit 1
fi
echo


echo
echo "+----------------------------------------------------------+"
echo "| Installing OCS Inventory NG Agent configuration files... |"
echo "+----------------------------------------------------------+"
echo
echo "Creating OCS Inventory NG Agent configuration directory <$OCS_AGENT_CONFIG_DIR>"
echo "Creating OCS Inventory NG Agent configuration directory <$OCS_AGENT_CONFIG_DIR>" >> $SETUP_LOG
mkdir -p "$OCS_AGENT_CONFIG_DIR" >> $SETUP_LOG 2>&1
echo "Creating OCS Inventory NG Agent configuration file"
echo "Creating OCS Inventory NG Agent configuration file" >> $SETUP_LOG
echo "server=\"$OCS_SERVER_DIR\"" > "$OCS_AGENT_CONF_FILE.etc"
echo "******** Begin updated configuration file <$OCS_AGENT_CONF_FILE> ***********" >> $SETUP_LOG
cat $OCS_AGENT_CONF_FILE.etc >> $SETUP_LOG
echo "******** End updated configuration file <$OCS_AGENT_CONF_FILE> ***********" >> $SETUP_LOG
echo "Installing OCS Inventory NG Agent configuration file <$OCS_AGENT_CONFIG_DIR/$OCS_AGENT_CONF_FILE>"
echo "Installing OCS Inventory NG Agent configuration file <$OCS_AGENT_CONFIG_DIR/$OCS_AGENT_CONF_FILE>" >> $SETUP_LOG
cp -f "$OCS_AGENT_CONF_FILE.etc" "$OCS_AGENT_CONFIG_DIR/$OCS_AGENT_CONF_FILE" >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "*** ERROR: Unable to write OCS Inventory NG Agent configuration file <$OCS_AGENT_CONFIG_DIR/$OCS_AGENT_CONF_FILE> !"
    echo "*** ERROR: Unable to write OCS Inventory NG Agent configuration file <$OCS_AGENT_CONFIG_DIR/$OCS_AGENT_CONF_FILE>" >> $SETUP_LOG
    echo "Look at file $SETUP_LOG for detailled error and fix it manually"
    echo "before running another time OCS Inventory NG Agent setup."
    echo "Installation aborted !"
    exit 1
fi
echo "Installing OCS Inventory NG Agent option modules configuration file <$OCS_AGENT_CONFIG_DIR/$OCS_AGENT_MODULES_FILE>"
echo "Installing OCS Inventory NG Agent option modules configuration file <$OCS_AGENT_CONFIG_DIR/$OCS_AGENT_MODULES_FILE>" >> $SETUP_LOG
cp -f "etc/ocsinventory-agent/$OCS_AGENT_MODULES_FILE" "$OCS_AGENT_CONFIG_DIR/$OCS_AGENT_MODULES_FILE" >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "*** ERROR: Unable to write OCS Inventory NG Agent option modules configuration file <$OCS_AGENT_CONFIG_DIR/$OCS_AGENT_MODULES_FILE> !"
    echo "*** ERROR: Unable to write OCS Inventory NG Agent option modules configuration file <$OCS_AGENT_CONFIG_DIR/$OCS_AGENT_MODULES_FILE>" >> $SETUP_LOG
    echo "Look at file $SETUP_LOG for detailled error and fix it manually"
    echo "before running another time OCS Inventory NG Agent setup."
    echo "Installation aborted !"
    exit 1
fi
 
echo "Creating OCS Inventory NG Agent <$OCS_AGENT_STATE_DIR> state directory"
echo "Creating OCS Inventory NG Agent <$OCS_AGENT_STATE_DIR> state directory" >> $SETUP_LOG
mkdir -p "$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR" >> $SETUP_LOG 2>&1
if [ -d $OLD_OCS_AGENT_CONFIG_DIR ]
then
    echo "Migrating old OCS Inventory NG Agent for Linux settings from <$OLD_OCS_AGENT_CONFIG_DIR> to <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR>."
    echo "Migrating old OCS Inventory NG Agent for Linux settings from <$OLD_OCS_AGENT_CONFIG_DIR> to <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR>." >> $SETUP_LOG
    cp -Rf $OLD_OCS_AGENT_CONFIG_DIR/*  $OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR >> $SETUP_LOG 2>&1
    echo "Removing old OCS Inventory NG Agent for Linux configuration directory <$OLD_OCS_AGENT_CONFIG_DIR>."
    echo "Removing old OCS Inventory NG Agent for Linux configuration directory <$OLD_OCS_AGENT_CONFIG_DIR>." >> $SETUP_LOG
    rm -Rf $OLD_OCS_AGENT_CONFIG_DIR >> $SETUP_LOG 2>&1
fi
echo "Creating OCS Inventory NG Agent state file"
echo "Creating OCS Inventory NG Agent state file" >> $SETUP_LOG
echo "<CONF>" > "$OCS_AGENT_STATE_FILE.local"
echo "  <DEVICEID>$OCS_AGENT_DEVICE_ID</DEVICEID>" >> "$OCS_AGENT_STATE_FILE.local"
echo "  <OCSFSERVER>$OCS_SERVER_DIR</OCSFSERVER>" >> "$OCS_AGENT_STATE_FILE.local"
echo "</CONF>" >> "$OCS_AGENT_STATE_FILE.local"
echo "******** Begin updated state file <$OCS_AGENT_STATE_FILE> ***********" >> $SETUP_LOG
cat $OCS_AGENT_STATE_FILE.local >> $SETUP_LOG
echo "******** End updated state file <$OCS_AGENT_STATE_FILE> ***********" >> $SETUP_LOG
echo "Installing OCS Inventory NG Agent state file <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR/$OCS_AGENT_STATE_FILE>"
echo "Installing OCS Inventory NG Agent state file <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR/$OCS_AGENT_STATE_FILE>" >> $SETUP_LOG
cp -f "$OCS_AGENT_STATE_FILE.local" "$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR/$OCS_AGENT_STATE_FILE" >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
    echo "*** ERROR: Unable to write OCS Inventory NG Agent state file <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR/$OCS_AGENT_STATE_FILE> !"
    echo "*** ERROR: Unable to write OCS Inventory NG Agent state file <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR/$OCS_AGENT_STATE_FILE>" >> $SETUP_LOG
    echo "Look at file $SETUP_LOG for detailled error and fix it manually"
    echo "before running another time OCS Inventory NG Agent setup."
    echo "Installation aborted !"
    exit 1
fi 

echo "Creating OCS Inventory NG Agent administrative information file"
echo "Creating OCS Inventory NG Agent administrative information file" >> $SETUP_LOG
if [ -r "$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR/$OCS_AGENT_ADMININFO_FILE" ]
then
    echo "File <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR/$OCS_AGENT_ADMININFO_FILE> already exist. Skipping administrative information file"
    echo "File <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR/$OCS_AGENT_ADMININFO_FILE> already exist. Skipping administrative information file" >> $SETUP_LOG
else
    echo "<ADM>" > "$OCS_AGENT_ADMININFO_FILE.local"
    echo "  <ACCOUNTINFO>" >> "$OCS_AGENT_ADMININFO_FILE.local"
    echo "    <KEYNAME>TAG</KEYNAME>" >> "$OCS_AGENT_ADMININFO_FILE.local"
    echo "    <KEYVALUE>$OCS_AGENT_TAG_VALUE</KEYVALUE>" >> "$OCS_AGENT_ADMININFO_FILE.local"
    echo "  </ACCOUNTINFO>" >> "$OCS_AGENT_ADMININFO_FILE.local"
    echo "</ADM>" >> "$OCS_AGENT_ADMININFO_FILE.local"
    echo "******** Begin updated administrative information file <$OCS_AGENT_ADMININFO_FILE> ***********" >> $SETUP_LOG
    cat $OCS_AGENT_ADMININFO_FILE.local >> $SETUP_LOG
    echo "******** End updated administrative information file <$OCS_AGENT_ADMININFO_FILE> ***********" >> $SETUP_LOG
    echo "Installing OCS Inventory NG Agent administrative information file <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR/$OCS_AGENT_ADMININFO_FILE>"
    echo "Installing OCS Inventory NG Agent administrative information file <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR/$OCS_AGENT_ADMININFO_FILE>" >> $SETUP_LOG
    cp -f "$OCS_AGENT_ADMININFO_FILE.local" "$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR/$OCS_AGENT_ADMININFO_FILE" >> $SETUP_LOG 2>&1
    if [ $? -ne 0 ]
    then
        echo "*** ERROR: Unable to write OCS Inventory NG Agent administrative information file <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR/$OCS_AGENT_ADMININFO_FILE> !"
        echo "*** ERROR: Unable to write OCS Inventory NG Agent administrative information file <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR/$OCS_AGENT_ADMININFO_FILE>" >> $SETUP_LOG
        echo "Look at file $SETUP_LOG for detailled error and fix it manually"
        echo "before running another time OCS Inventory NG Agent setup."
        echo "Installation aborted !"
        exit 1
    fi 
fi
echo "OK, OCS Inventory NG Agent configuration files setup successfully ;-)"
echo "OCS Inventory NG Agent configuration files setup successfully" >> $SETUP_LOG
echo


if [ $INSTALLER_PERL_DAEMON_MODE -eq 0 ]
then
    echo
    echo "+----------------------------------------------------------+"
    echo "| Installing OCS Inventory NG Agent cron configuration...  |"
    echo "+----------------------------------------------------------+"
    echo
    if [ -r $CRON_CONF_DIR/$OCS_AGENT_CRON_FILE ]
    then
        echo "OCS Inventory NG Agent cron configuration file already exist, skipping"
        echo "OCS Inventory NG Agent cron configuration file already exist, skipping" >> $SETUP_LOG
    else
        echo "Creating OCS Inventory NG Agent cron configuration file"
        echo "Creating OCS Inventory NG Agent cron configuration file" >> $SETUP_LOG
        OCS_AGENT_CRON_HOUR=`date +%H`
        OCS_AGENT_CRON_MIN=`date +%M`
        cp etc/cron.d/$OCS_AGENT_CRON_FILE etc/cron.d/$OCS_AGENT_CRON_FILE.local >> $SETUP_LOG 2>&1
        $PERL_BIN -pi -e "s#HH#$OCS_AGENT_CRON_HOUR#g" etc/cron.d/$OCS_AGENT_CRON_FILE.local >> $SETUP_LOG 2>&1
        $PERL_BIN -pi -e "s#MM#$OCS_AGENT_CRON_MIN#g" etc/cron.d/$OCS_AGENT_CRON_FILE.local >> $SETUP_LOG 2>&1
        echo "******** Begin updated cron configuration file $OCS_AGENT_CRON_FILE ***********" >> $SETUP_LOG
        cat  etc/cron.d/$OCS_AGENT_CRON_FILE.local >> $SETUP_LOG
        echo "******** End updated cron configuration file $OCS_AGENT_CRON_FILE ***********" >> $SETUP_LOG
        echo "Installing OCS Inventory NG Agent cron configuration file <$CRON_CONF_DIR/$OCS_AGENT_CRON_FILE>"
        echo "Installing OCS Inventory NG Agent cron configuration file <$CRON_CONF_DIR/$OCS_AGENT_CRON_FILE>" >> $SETUP_LOG
        cp -f  etc/cron.d/$OCS_AGENT_CRON_FILE.local $CRON_CONF_DIR/$OCS_AGENT_CRON_FILE >> $SETUP_LOG 2>&1
        if [ $? -ne 0 ]
        then
            echo "*** ERROR: Unable to write OCS Inventory NG Agent cron configuration file <$CRON_CONF_DIR/$OCS_AGENT_CRON_FILE> !"
            echo "*** ERROR: Unable to write OCS Inventory NG Agent cron configuration file <$CRON_CONF_DIR/$OCS_AGENT_CRON_FILE>" >> $SETUP_LOG
            echo "Look at file $SETUP_LOG for detailled error and fix it manually"
            echo "before running another time OCS Inventory NG Agent setup."
            echo "Installation aborted !"
            exit 1
        fi
        echo "OK, OCS Inventory NG Agent cron configuration file setup successfully ;-)"
        echo "OCS Inventory NG Agent will be launched once a day at $OCS_AGENT_CRON_HOUR:$OCS_AGENT_CRON_MIN."
        echo "OCS Inventory NG Agent cron configuration file setup successfully" >> $SETUP_LOG
        echo "OCS Inventory NG Agent will be launched once a day at $OCS_AGENT_CRON_HOUR:$OCS_AGENT_CRON_MIN." >> $SETUP_LOG
    fi
else
    echo
    echo "+----------------------------------------------------------+"
    echo "| OCS Inventory NG Agent daemon scripts...                 |"
    echo "+----------------------------------------------------------+"
    echo
    if [ -r $CRON_CONF_DIR/$OCS_AGENT_CRON_FILE ]
    then
        echo "Removing OCS Inventory NG Agent for Linux cron configuration file <$CRON_CONF_DIR/$OCS_AGENT_CRON_FILE>."
        echo "Removing OCS Inventory NG Agent for Linux cron configuration file <$CRON_CONF_DIR/$OCS_AGENT_CRON_FILE>." >> $SETUP_LOG
        rm -f $CRON_CONF_DIR/$OCS_AGENT_CRON_FILE >> $SETUP_LOG 2>&1
        echo
    fi
    echo "Installing OCS Inventory NG Agent daemon script startup file <$DAEMON_SCRIPT_DIR/$OCS_AGENT_DAEMON_SCRIPT_FILE>"
    echo "Installing OCS Inventory NG Agent daemon script startup file <$DAEMON_SCRIPT_DIR/$OCS_AGENT_DAEMON_SCRIPT_FILE>" >> $SETUP_LOG
    cp -f etc/init.d/$OCS_AGENT_DAEMON_SCRIPT_FILE $DAEMON_SCRIPT_DIR/$OCS_AGENT_DAEMON_SCRIPT_FILE >> $SETUP_LOG 2>&1
    if [ $? -ne 0 ]
    then
        echo "*** ERROR: Unable to write OCS Inventory NG Agent daemon script startup file <$DAEMON_SCRIPT_DIR/$OCS_AGENT_DAEMON_SCRIPT_FILE> !"
        echo "*** ERROR: Unable to write OCS Inventory NG Agent daemon script startup file <$DAEMON_SCRIPT_DIR/$OCS_AGENT_DAEMON_SCRIPT_FILE>" >> $SETUP_LOG
        echo "Look at file $SETUP_LOG for detailled error and fix it manually"
        echo "before running another time OCS Inventory NG Agent setup."
        echo "Installation aborted !"
        exit 1
    fi
    echo
    echo "You choose to use OCS Inventory NG Agent in daemon mode."
    echo "You should take a look at file <$OCS_AGENT_DAEMON_SCRIPT_FILE> in directory <$DAEMON_SCRIPT_DIR>."
    echo "This is a sample script to launch OCS Inventory NG Agent in daemon mode."
    echo "You must adjust it according to the operating system, and add it to needed system runlevel."
    echo "CAUTION: Without adding to runlevel, daemon will not be started at boot time !"
    echo "You choose to use OCS Inventory NG Agent in daemon mode." >> $SETUP_LOG
    echo "You should take a look at file <$OCS_AGENT_DAEMON_SCRIPT_FILE> in directory <$DAEMON_SCRIPT_DIR>." >> $SETUP_LOG
    echo "This is a sample script to launch OCS Inventory NG Agent in daemon mode." >> $SETUP_LOG
    echo "You must adjust it according to the operating system, and add it to needed system runlevel." >> $SETUP_LOG
    echo "CAUTION: Without this script, daemon will not be started at boot time !" >> $SETUP_LOG
fi
if [ -r $CRON_CONF_DIR/$OLD_OCS_AGENT_CRON_FILE ]
then
    echo
    echo "Removing old OCS Inventory NG Agent for Linux cron configuration file <$CRON_CONF_DIR/$OLD_OCS_AGENT_CRON_FILE>."
    echo "Removing old OCS Inventory NG Agent for Linux cron configuration file <$CRON_CONF_DIR/$OLD_OCS_AGENT_CRON_FILE>." >> $SETUP_LOG
    rm -f $CRON_CONF_DIR/$OLD_OCS_AGENT_CRON_FILE >> $SETUP_LOG 2>&1
fi
echo


echo
echo "+----------------------------------------------------------+"
echo "| Installing Certificates...                               |"
echo "+----------------------------------------------------------+"
echo
echo "Installing Certificates" >> $SETUP_LOG
if [ `ls *.pem 2> /dev/null | wc -l` -eq 0 ]
then
    echo "There is no Certificate in directory `pwd`. Skipping Certificates install..."
    echo "There is no Certificate in directory `pwd`. Skipping Certificates install" >> $SETUP_LOG
else
    echo "Copying Certificates from directory <`pwd`> to directory <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR>..."
    echo "Copying Certificates from directory <`pwd`> to directory <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR>" >> $SETUP_LOG
    cp -f *.pem 1>>$SETUP_LOG 2>&1
    if [ $? -ne 0 ]
    then
        echo "*** ERROR: Unable to copy Certificates from directory <`pwd`> to directory <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR> !"
        echo "*** ERROR: Unable to copy Certificates from directory <`pwd`> to directory <$OCS_AGENT_STATE_DIR/$OCS_SERVER_DIR>" >> $SETUP_LOG
        echo "Look at file $SETUP_LOG for detailled error and fix it manually"
        echo "before running another time OCS Inventory NG Agent setup."
        echo "Installation aborted !"
        exit 1
    fi
fi
echo


echo
echo "+----------------------------------------------------------+"
echo "| Lauching OCS Inventory NG Agent...                       |"
echo "+----------------------------------------------------------+"
echo
echo "Lauching OCS Inventory NG Agent for testing" >> $SETUP_LOG
/bin/ocsinv -s $OCS_SERVER_DIR >> $SETUP_LOG 2>&1
if [ $? -ne 0 ]
then
	echo "*** ERROR: Unable to launch OCS Inventory NG Agent !"
	echo "*** ERROR: Unable to launch OCS Inventory NG Agent" >> $SETUP_LOG
	echo "Look at file $SETUP_LOG for detailled error and fix it manually"
	echo "before running another time OCS Inventory NG Agent setup."
	echo "Installation aborted !"
	exit 1
fi 
echo "OK, OCS Inventory NG Agent runs successfully ;-)"
echo "SUCCESS: OCS Inventory NG Agent runs successfully" >> $SETUP_LOG
echo

echo
echo "Setup has created a log file $SETUP_LOG. Please, save this file."
echo "If you encounter error while running OCS Inventory NG Agent,"
echo "we can ask you to show us his content !"
echo
echo "Enjoy OCS Inventory NG ;-)"
echo
exit 0
