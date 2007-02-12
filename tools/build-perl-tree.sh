#!/bin/sh
# A script to prepare a installation of Perl + OCSInventory-agent for
# Unix/Linux
# This in order to be able to provide an installation for system without
# Perl > 5.6

PREFIX="/opt/ocsinventory-agent"
PERL="$PREFIX/bin/perl"
MAKE="make"

ETCDIR="$PREFIX/etc"
BASEDIR="$PREFIX/var/ocsinventory-agent"
LOGDIR="$PREFIX/log/ocsinventory-agent"
PIDFILE="$PREFIX/var/run"
rm -rf tmp 
mkdir tmp
cd tmp
for i in `ls ../tarballs/*.gz`; do
  gunzip < $i | tar xvf -
done

cd perl-5.8.8
rm -f config.sh Policy.sh
# AIX
#./Configure -Dusenm -des -Dinstallprefix=$PREFIX -Dsiteprefix=$PREFIX -Dprefix=$PREFIX
./Configure -Dcc="gcc" -des -Dinstallprefix=$PREFIX -Dsiteprefix=$PREFIX -Dprefix=$PREFIX
$MAKE
$MAKE install
#cd ../expat-2.0.0/
#./configure --prefix=$PREFIX
#$MAKE
cd ../Net-IP-1.25
$PERL Makefile.PL PREFIX=$PREFIX
$MAKE PREFIX=$PREFIX
$MAKE install PREFIX=$PREFIX
cd ../XML-NamespaceSupport-1.09/
$PERL Makefile.PL PREFIX=$PREFIX
$MAKE PREFIX=$PREFIX
$MAKE install PREFIX=$PREFIX
cd ../XML-Parser-2.34
$PERL Makefile.PL PREFIX=$PREFIX
$MAKE PREFIX=$PREFIX
$MAKE install PREFIX=$PREFIX
cd ../XML-SAX-0.15/
$PERL Makefile.PL PREFIX=$PREFIX
$MAKE PREFIX=$PREFIX
$MAKE install PREFIX=$PREFIX
#cd ../XML-SAX-Expat-0.37/
#$PERL Makefile.PL PREFIX=$PREFIX
#$MAKE PREFIX=$PREFIX
#$MAKE install PREFIX=$PREFIX
cd ../XML-Simple-2.16/
$PERL Makefile.PL PREFIX=$PREFIX
$MAKE PREFIX=$PREFIX
$MAKE install PREFIX=$PREFIX
cd ../URI-1.35/
$PERL Makefile.PL PREFIX=$PREFIX
$MAKE PREFIX=$PREFIX
$MAKE install PREFIX=$PREFIX
cd ../HTML-Parser-3.56/
$PERL Makefile.PL PREFIX=$PREFIX
$MAKE PREFIX=$PREFIX
$MAKE install PREFIX=$PREFIX
cd ../Proc-Daemon-0.03/
$PERL Makefile.PL PREFIX=$PREFIX
$MAKE PREFIX=$PREFIX
$MAKE install PREFIX=$PREFIX
cd ../libwww-perl-5.805/
$PERL Makefile.PL PREFIX=$PREFIX
$MAKE PREFIX=$PREFIX
$MAKE install PREFIX=$PREFIX
cd ../Compress-Raw-Zlib-2.003/
$PERL Makefile.PL PREFIX=$PREFIX
$MAKE PREFIX=$PREFIX
$MAKE install PREFIX=$PREFIX
cd ../IO-Compress-Base-2.003/
$PERL Makefile.PL PREFIX=$PREFIX
$MAKE PREFIX=$PREFIX
$MAKE install PREFIX=$PREFIX
cd ../IO-Compress-Zlib-2.003/
$PERL Makefile.PL PREFIX=$PREFIX
$MAKE PREFIX=$PREFIX
$MAKE install PREFIX=$PREFIX
cd ../Compress-Zlib-2.003/
$PERL Makefile.PL PREFIX=$PREFIX
$MAKE PREFIX=$PREFIX
$MAKE install PREFIX=$PREFIX

cd ../Ocsinventory-Agent-0.0.2/
$PERL Makefile.PL PREFIX=$PREFIX
$MAKE PREFIX=$PREFIX
$MAKE install PREFIX=$PREFIX

perl -i -pe "s!/etc/ocsinventory-agent!$ETCDIR!" $PREFIX/bin/ocsinventory-agent
perl -i -pe "s!/var/lib/ocsinventory-agent!$BASEDIR!" $PREFIX/bin/ocsinventory-agent
perl -i -pe "s!/var/log/ocsinventory-agent!$LOGDIR!" $PREFIX/bin/ocsinventory-agent
perl -i -pe "s!/var/run/ocsinventory-agent.pid!$PIDFILE!" $PREFIX/bin/ocsinventory-agent

mkdir -p $ETCDIR 
mkdir -p $BASEDIR 
mkdir -p $LOGDIR 
mkdir -p $PIDFILE 
