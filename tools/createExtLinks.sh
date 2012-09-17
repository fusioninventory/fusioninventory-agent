#!/bin/sh
# Create symblink to the subi task modules

for task in Deploy Network ESX; do
    taskLcName=`perl -e" print lc \"$task\""`
    ln -f -v -s $PWD/../agent-task-$taskLcName/lib/FusionInventory/Agent/Task/* lib/FusionInventory/Agent/Task/
done
ln -f -v -s "$PWD/../agent-task-esx/lib/FusionInventory/VMware" lib/FusionInventory/VMware
ln -f -v -s $PWD/../agent-task-network/lib/FusionInventory/Agent/SNMP.pm lib/FusionInventory/Agent/SNMP.pm
mkdir -p lib/FusionInventory/Agent/SNMP
ln -f -v -s $PWD/../agent-task-network/lib/FusionInventory/Agent/SNMP/Live.pm lib/FusionInventory/Agent/SNMP/Live.pm
ln -f -v -s $PWD/../agent-task-network/lib/FusionInventory/Agent/Tools/* lib/FusionInventory/Agent/Tools/
ln -f -v -s $PWD/../agent-task-esx/fusioninventory-esx .
