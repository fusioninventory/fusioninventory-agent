#!/bin/sh
# Create symblink to the subi task modules
set -e

for task in Deploy Network ESX; do
    taskLcName=`perl -e" print lc \"$task\""`
    ln -s $PWD/../agent-task-$taskLcName/lib/FusionInventory/Agent/Task/* lib/FusionInventory/Agent/Task/
done
if [ ! -e lib/FusionInventory/VMware ]; then
    ln -s "$PWD/../agent-task-esx/lib/FusionInventory/VMware" lib/FusionInventory/VMware
fi
if [ ! -e lib/FusionInventory/Agent/SNMP.pm ]; then
    ln -s $PWD/../agent-task-netdiscovery/lib/FusionInventory/Agent/SNMP.pm lib/FusionInventory/Agent/SNMP.pm
fi

if [ ! -e fusioninventory-esx ]; then
    ln -s $PWD/../agent-task-esx/fusioninventory-esx .
fi
