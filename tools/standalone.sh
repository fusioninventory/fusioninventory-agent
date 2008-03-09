#!/bin/sh

[ -f standalone.sh ] && cd ..
if [ ! -f tools/standalone.sh ]; then
    echo "Can't find tools/standalone.sh"
    exit 1
fi

MODULES="`cat MANIFEST | grep -v ^inc/ | grep pm$ | perl -pe 's/lib\/(.*)\.pm/ -M $1/; s/\//::/g; chomp'` -M XML::SAX::Expat -M XML::SAX::PurePerl -M PerlIO "

for i in `echo $MODULES| perl -nle 's/\-M//g;print'`; do  perl -I "lib" -M$i -e "1" || MISSING="$MISSING $i" ;done

if [ ! -z "$MISSING" ]; then
  echo "Some modules are missing in your installation, please install them first."
  echo "->$MISSING"
  exit 1
fi

pp --lib lib $MODULES -o ocsinventory-agent.bin ocsinventory-agent 
if [ -f ocsinventory-agent.bin ]; then
    echo "ocsinventory-agent.bin generated!"
else
    echo "Failed to generate ocsinventory-agent.bin!"
fi
