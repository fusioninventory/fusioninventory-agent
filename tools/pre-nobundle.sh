#!/bin/sh

make distclean
rm -f MANIFEST Makefile
sed -i 's/^bundle/#bundle/' Makefile.PL
rm -rf inc/BUNDLES*
perl Makefile.PL
make manifest

