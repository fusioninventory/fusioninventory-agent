#!/bin/sh

for walk in `locate *.walk`; do
  echo processing $walk
  ./bin/fusioninventory-netinventory --models-dir /home/goneri/models+dev-20130501-1400 --file $walk > /tmp/myxml
  if [ -s "/tmp/myxml" ]; then
      ./bin/fusioninventory-injector -f /tmp/myxml -u http://localhost/~goneri/glpigit/plugins/fusioninventory/ -v
  fi
done
