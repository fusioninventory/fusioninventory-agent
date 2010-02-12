#!/bin/sh

echo "WARNINGS: Very experimental tool"

[ -f standalone.sh ] && cd ..
if [ ! -f tools/standalone.sh ]; then
    echo "Can't find tools/standalone.sh"
    exit 1
fi

if [ ! -f MANIFEST ]; then
    echo "Can't find the MANIFEST, please run:"
    echo " perl Makefile.PL"
    echo " make manifest"
    exit 1
fi

if [ ! -x "`which pp 2>/dev/null`" ]; then
    echo "Can't find the pp command. Please install PAR::Packer:"
    echo " -CPAN: 'cpan PAR::Packer'"
    echo " -source: sownload the archive from"
    echo "  http://search.cpan.org/dist/PAR-Packer/"
    echo " -Debian/Ubuntu: 'aptitude install libpar-packer-perl' OR 'aptitude install libpar-perl'"
    exit 1
fi

BACKENDMODULE=`cat MANIFEST | perl -pe 's/.*// unless (/FusionInventory\/Agent\/Backend\// && !/^inc/ && /pm$/); s/lib\/(.*)\.pm/ $1/; s/\//::/g; chomp'`

cat > lib/FusionInventory/Agent/Backend/ModuleToLoad.pm <<EOF
# This is a workaround for PAR::Packer. Since it resets @INC
# I can't find the backend modules to load dynamically. So
# I prepare a list and include it.
package FusionInventory::Agent::Backend::ModuleToLoad;

our @list = qw/ $BACKENDMODULE /; 

1;
EOF

MODULES="`cat MANIFEST | perl -pe 's/.*// unless (!/^inc/ && /pm$/); s/lib\/(.*)\.pm/ -M $1/; s/\//::/g; chomp'` -M XML::SAX::PurePerl -M PerlIO -M Getopt::Long -M Digest::MD5 -M FusionInventory::Agent::Backend::ModuleToLoad"

for i in `echo $MODULES| perl -nle 's/\-M//g;print'`; do  perl -I "lib" -M$i -e "1" || MISSING="$MISSING $i" ;done

if [ ! -z "$MISSING" ]; then
  echo "Some modules are missing in your installation or failed to build, please install them first."
  echo "->$MISSING"
  exit 1
fi

#pp --lib lib $MODULES -o ocsinventory-agent.bin ocsinventory-agent
pp --lib lib $MODULES -B -p ocsinventory-agent -vvv -o ocsinventory-agent.par
pp -o ocsinventory-agent.bin ocsinventory-agent.par

if [ -f ocsinventory-agent.bin ]; then
    echo "ocsinventory-agent.bin generated!"
else
    echo "Failed to generate ocsinventory-agent.bin!"
fi
