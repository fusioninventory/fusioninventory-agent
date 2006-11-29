#!/bin/sh

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

