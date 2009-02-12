#!/bin/sh

# Hack because of
# http://rt.cpan.org/Public/Bug/Display.html?id=43060
perl Makefile.PL
make manifest
make dist
gunzip < Ocsinventory-Agent-0.0.10beta3.tar.gz | tar xf -
perl -i -pe 's/^exit;//' Ocsinventory-Agent-0.0.10beta3/inc/BUNDLES/libwww-perl-5.823/Makefile.PL
rm Ocsinventory-Agent-0.0.10beta3.tar.gz
tar cf Ocsinventory-Agent-0.0.10beta3.tar Ocsinventory-Agent-0.0.10beta3
gzip Ocsinventory-Agent-0.0.10beta3.tar

