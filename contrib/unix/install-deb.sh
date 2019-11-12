#!/bin/bash

# Set default value for parameters
# Change it accoring to your needs. It is the default value used if no --version parameter is used.
version=${version:-2.5.1-1}


# Get named parameters
while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi
  shift
done

# Welcome message
clear
echo
echo
echo "Welcome to the FusionInventory Agent Installation script"
echo

# Help Needed ?
if [ ! -z ${help+x} ]
then
        echo "This script is intended to install the FusionInventory agent on Debian/Ubuntu distribution."
        echo "The --version parameter is used to pass the target version in form of 2.5.1-1 or 2.5.1 (if no sub-version exists)."
        echo "The --taskcollect parameter is used to specify if the collect task must be instaled. It is $true by default."
        echo "The --tasknetwork parameter is used to specify if the network task must be instaled. It is $true by default."
        echo "The --taskdeploy parameter is used to specify if the deploy task must be instaled. It is $true by default."
        echo "The --taskesx parameter is used to specify if the esx task must be instaled. It is $true by default."
	echo "The --agentconfig parameter is used to configure the agent. Use it to adapt the installation to your environment."
	echo "   All parameters from http://fusioninventory.org/documentation/agent/man/agent.cfg.html are available."
	echo "   Parameters have to be separated by a pipe | in the form of"
	echo "   server = myserver.mydomain.local/glpi/plugins/fusioninventory|httpd-trust = 192.168.0.25"
        echo "The --help parameter display this help. It superseeds all other parameter."
        exit 1
fi

taskscollect=${taskcollect:-$true}
tasksnetwork=${tasknetwork:-$true}
tasksdeploy=${taskdeploy:-$true}
tasksesx=${taskesx:-$true}
agentconfig=${agentconfig:-"server = https://myserver.mydomain.com/glpi/plugins/fusioninventory/|no-ssl-check 1"}

# Test if wget is installed.
type wget >/dev/null 2>&1 || { echo >&2 "I require wget but it's not installed.  Aborting."; exit 1; }

shortversion="${version::5}"

echo "Target Version is  $version"

BaseUrl=https://github.com/fusioninventory/fusioninventory-agent/releases/download/$shortversion/
downloadurlagent=$BaseUrl\fusioninventory-agent_$version\_all.deb
downloadurlcollect=$BaseUrl\fusioninventory-agent-task-collect_$version\_all.deb
downloadurlnetwork=$BaseUrl\fusioninventory-agent-task-network_$version\_all.deb
downloadurldeploy=$BaseUrl\fusioninventory-agent-task-deploy_$version\_all.deb
downloadurlesx=$BaseUrl\fusioninventory-agent-task-esx_$version\_all.deb

# Setup agent

# Setup dependencies for Agent Core
echo "installing agent dependencies"
apt-get -y install dmidecode hwdata ucf hdparm >> FusionInventoryInstallation.log 2>/dev/null
apt-get -y install perl libuniversal-require-perl libwww-perl libparse-edid-perl >> FusionInventoryInstallation.log 2>/dev/null
apt-get -y install libproc-daemon-perl libfile-which-perl libhttp-daemon-perl >> FusionInventoryInstallation.log 2>/dev/null
apt-get -y install libxml-treepp-perl libyaml-perl libnet-cups-perl libnet-ip-perl >> FusionInventoryInstallation.log 2>/dev/null
apt-get -y install libdigest-sha-perl libsocket-getaddrinfo-perl libtext-template-perl >> FusionInventoryInstallation.log 2>/dev/null
apt-get -y install libxml-xpath-perl >> FusionInventoryInstallation.log 2>/dev/null
apt-get -y install libwrite-net-perl >> FusionInventoryInstallation.log 2>/dev/null

echo "Downloading Agent from  $BaseUrl"
wget $downloadurlagent -q --show-progress
echo "Installing agent"
dpkg -i fusioninventory-agent_$version\_all.deb
sleep 2
echo
echo

if $taskcollect
then
	echo "collect task is requested"
	wget $downloadurlcollect -q --show-progress
	dpkg -i fusioninventory-agent-task-collect_$version\_all.deb
else
        echo "collect task is NOT requested"
fi

sleep 2
echo
echo

if $tasknetwork
then
    echo "network task is requested"
	echo "installing dependencies"
	apt -y install libnet-snmp-perl libcrypt-des-perl libnet-nbname-perl libdigest-hmac-perl >> FusionInventoryInstallation.log 2>/dev/null
	wget $downloadurlnetwork -q --show-progress
	dpkg -i fusioninventory-agent-task-network_$version\_all.deb
else
        echo "network task is NOT requested"
fi

sleep 2
echo
echo

if $taskdeploy
then
    echo "deploy task is requested"
	echo "installing dependencies"
	apt -y install libfile-copy-recursive-perl  libparallel-forkmanager-perl >> FusionInventoryInstallation.log 2>/dev/null
	wget $downloadurldeploy -q --show-progress
	dpkg -i fusioninventory-agent-task-deploy_$version\_all.deb
else
        echo "deploy task is NOT requested"
fi

sleep 2
echo
echo

if $taskesx
then
    echo "esx task is requested"
	echo "installing dependencies"
	wget $downloadurlesx -q --show-progress
	dpkg -i fusioninventory-agent-task-esx_$version\_all.deb
else
        echo "esx task is NOT requested"
fi

sleep 2
echo
echo

# Configuring agent
echo "Configuring agent"
echo $agentconfig | tr '|' '\n' > /etc/fusioninventory/conf.d/config.cfg

echo "Applying config"
service fusioninventory-agent start

echo
echo
echo "Setup Finished."
echo "You could find the dependencies installation log in FusionInventoryInstallation.log"



