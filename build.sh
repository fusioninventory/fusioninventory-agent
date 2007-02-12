#!/bin/sh

PREFIX="/opt/ocsinventory-agent"
PERL="$PREFIX/bin/perl"
MAKE="gmake"

ETCDIR="$PREFIX/etc"
BASEDIR="$PREFIX/var/ocsinventory-agent"
LOGDIR="$PREFIX/log/ocsinventory-agent"
PIDFILE="$PREFIX/var/run"
#CC="/opt/SUNWspro/bin/cc"
rm -rf tmp 
mkdir tmp
cd tmp
for i in `ls ../tarballs/*.gz`; do
  gunzip < $i | tar xvf -
done
#export LD_LIBRARY_PATH="$PREFIXlib:$LD_LIBRARY_PATH"

cd perl-5.8.8
rm -f config.sh Policy.sh
# AIX
#./Configure -Dusenm -des -Dinstallprefix=$PREFIX -Dsiteprefix=$PREFIX -Dprefix=$PREFIX
./Configure -Dcc="gcc" -des -Dinstallprefix=$PREFIX -Dsiteprefix=$PREFIX -Dprefix=$PREFIX
$MAKE
$MAKE install
cd ../expat-2.0.0/
./configure --prefix=$PREFIX
$MAKE
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
cd ../XML-SAX-0.14/
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
cd ../Ocsinventory-Agent-Backend-CNAMTS-0.0.1/
$PERL Makefile.PL PREFIX=$PREFIX
$MAKE PREFIX=$PREFIX
$MAKE install PREFIX=$PREFIX

perl -pe "s!/etc/ocsinventory-agent!$ETCDIR!" $PREIX/bin/ocs-agent
perl -pe "s!/var/lib/ocsinventory-agent!$BASEDIR!" $PREIX/bin/ocs-agent
perl -pe "s!/var/log/ocsinventory-agent!$LOGDIR!" $PREIX/bin/ocs-agent
perl -pe "s!/var/run/ocsinventory-agent.pid!$PIDFILE!" $PREIX/bin/ocs-agent

mkdir -p $ETCDIR 
mkdir -p $BASEDIR 
mkdir -p $LOGDIR 
mkdir -p $PIDFILE 
