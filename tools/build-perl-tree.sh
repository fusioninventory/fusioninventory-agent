#!/bin/sh
# A script to prepare a installation of Perl + FusionInventory Agent for
# Unix/Linux
# This in order to be able to provide an installation for system without
# Perl >= 5.8

set -e

MAKE="make"
TMP="$HOME/tmp"
PREFIX="$HOME/perl"

PERLVERSION="5.10.1"

if [ ! -d $TMP ]; then
  echo "tmp $TMP dir is missing"
fi
cd $TMP
if [ ! -f perl-$PERLVERSION.tar.gz ]; then
  wget -O perl-$PERLVERSION.tar.gz.part http://cpan.perl.org/src/perl-$PERLVERSION.tar.gz
  mv perl-$PERLVERSION.tar.gz.part perl-$PERLVERSION.tar.gz 
fi
gunzip < perl-$PERLVERSION.tar.gz | tar xvf -
cd perl-$PERLVERSION

# AIX
#./Configure -Dusethreads -Dusenm -des -Dinstallprefix=$PREFIX -Dsiteprefix=$PREFIX -Dprefix=$PREFIX
#./Configure -Dusethreads -Dcc="gcc" -des -Dinstallprefix=$PREFIX -Dsiteprefix=$PREFIX -Dprefix=$PREFIX
./Configure -Dusethreads -des -Dinstallprefix=$PREFIX -Dsiteprefix=$PREFIX -Dprefix=$PREFIX
$MAKE
$MAKE install

