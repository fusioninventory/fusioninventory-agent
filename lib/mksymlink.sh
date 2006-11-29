#!/bin/sh
# I use this script to install symlinks of module and being able to
# stay in the CVS directory for coding stuff.
# Goneri Le Bouder <goneri@rulezlan.org>  Wed, 29 Nov 2006 19:41:08 +0100

PWD=`pwd`
PREFIX="/usr/local"
PERLREL="5.8.8"


for dir in `find . -type d ! -name 'CVS'| sed 's/^\.//'`; do
  mkdir -p $PREFIX/share/perl/$PERLREL/Ocsinventory$dir
done

for file in `find . -type f -name '*.pm'|grep -v CVS| sed 's/\.//'`; do
  ln -s $PWD$file $PREFIX/share/perl/$PERLREL/Ocsinventory$file
done

find $PREFIX/share/perl/$PERLREL/Ocsinventory -type l -name '*.pm' >\
/usr/local/lib/perl/$PERLREL/auto/Ocsinventory/.packlist

