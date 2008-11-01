#!/bin/bash

FILES="unified_unix_agent-macosx*.zip ocsinventory-agent OCSNG.app OCSNG.pkg cacert.pem modules.conf ocsinventory-agent.cfg package-root"

echo "cleaning up"
for FILE in $FILES; do
  echo "removing: $FILE"
  sudo rm -R -f $FILE
done
