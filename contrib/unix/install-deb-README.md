Original contrib from [J-C-P InstallFusionInventoryAgentForDebian repository](https://github.com/J-C-P/InstallFusionInventoryAgentForDebian)

# InstallFusionInventoryAgentForDebian
Script to make the FusionInventory agent installation unattended on Debian and Ubuntu systems.

## Prerequisites
- Internet connection
- wget package

## How to
To install FusionInventory agent on Debian or Ubuntu, check the options (end of the line) and execute 
```
wget -O - https://raw.github.com/fusioninventory/fusioninventory-agent/develop/contrib/unix/install-deb.sh | bash -s -- --version 2.5.1-1 --taskcollect true --tasknetwork true --tasknetwork true --taskesx true --agentconfig "server = https://myserver.mydomain.local/glpi/plugins/fusioninventory|no-ssl-check = 1|httpd-trust = 192.168.0.25"
```

## Tested on
- Debian 10 x64 (kernel 4.19.0-6-amd64)
- Ubuntu 18.04 LTS (4.15.0-64-generic)

## To get help
run
```
wget -O - https://raw.github.com/fusioninventory/fusioninventory-agent/develop/contrib/unix/install-deb.sh | bash -s -- --help
```
