#!/bin/sh
# A script to prepare a installation of Perl + OCSInventory-agent for
# Unix/Linux
# This in order to be able to provide an installation for system without
# Perl > 5.6

set -e

MAKE="make"
TMP="/home2/goneri/tmp"
PREFIX="$TMP/build/opt/ocsinventory-agent"

ETCDIR="$PREFIX/etc"
BASEDIR="$PREFIX/var/ocsinventory-agent"
LOGDIR="$PREFIX/log/ocsinventory-agent"
PIDFILE="$PREFIX/var/run"
PERLVERSION="5.10.0"

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
#./Configure -Dusenm -des -Dinstallprefix=$PREFIX -Dsiteprefix=$PREFIX -Dprefix=$PREFIX
#./Configure -Dcc="gcc" -des -Dinstallprefix=$PREFIX -Dsiteprefix=$PREFIX -Dprefix=$PREFIX
./Configure -des -Dinstallprefix=$PREFIX -Dsiteprefix=$PREFIX -Dprefix=$PREFIX
$MAKE
$MAKE install

PATH=$PREFIX/bin:$PATH
export PATH
cpanp 's conf prereqs 1; i XML::SAX'
cpanp 's conf prereqs 1; i XML::Simple'
cpanp 's conf prereqs 1; i LWP'
cpanp 's conf prereqs 1; i Proc::Daemon'
cpanp 's conf prereqs 1; i HTML::Parser' # For what? 
# Report error about IPv6 on Solaris 10
cpanp 's conf prereqs 1; i --force Net::IP'
cpanp 's conf prereqs 1; i --force PAR::Packer'
cpanp 's conf prereqs 1; i --force Net::SSLeay'

exit;

if [ ! openssl-0.9.8j.tar.gz ]; then
  wget -O openssl-0.9.8j.tar.gz.part http://www.openssl.org/source/openssl-0.9.8j.tar.gz
  mv openssl-0.9.8j.tar.gz.part openssl-0.9.8j.tar.gz 
fi 
gunzip < openssl-0.9.8j.tar.gz | tar xvf -
cd openssl-0.9.8j
./config --prefix=/home2/goneri/tmp/openssl
make
make install
ln -s apps bin

#for i in `ls ../tarballs/*.gz`; do
#  gunzip < $i | tar xvf -
#done

#cd ../expat-2.0.0/
#./configure --prefix=$PREFIX
#$MAKE
#cd ../Ocsinventory-Agent-0.0.2/
#$PERL Makefile.PL PREFIX=$PREFIX
#$MAKE PREFIX=$PREFIX
#$MAKE install PREFIX=$PREFIX

#:$PATH#perl -i -pe "s!/etc/ocsinventory-agent!$ETCDIR!" $PREFIX/bin/ocsinventory-agent
#perl -i -pe "s!/var/lib/ocsinventory-agent!$BASEDIR!" $PREFIX/bin/ocsinventory-agent
#perl -i -pe "s!/var/log/ocsinventory-agent!$LOGDIR!" $PREFIX/bin/ocsinventory-agent
#perl -i -pe "s!/var/run/ocsinventory-agent.pid!$PIDFILE!" $PREFIX/bin/ocsinventory-agent

#mkdir -p $ETCDIR 
#mkdir -p $BASEDIR 
#mkdir -p $LOGDIR 
#mkdir -p $PIDFILE 
