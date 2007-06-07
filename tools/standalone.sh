#!/bin/sh

MODULES="`cat MANIFEST  | grep pm$ | perl -pe 's/lib\/(.*)\.pm/ -M $1/; s/\//::/g; chomp'` -M XML::SAX::Expat -M XML::SAX::PurePerl -M PerlIO "
pp --lib lib $MODULES -o ocsinventory-agent.bin ocsinventory-agent 
#pp --clean --lib lib $MODULES -p ocsinventory-agent 
