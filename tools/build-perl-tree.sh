#!/bin/sh
# A script to prepare a installation of Perl + FusionInventory Agent for
# Unix/Linux
# This in order to be able to provide an installation for system without
# Perl >= 5.8

set -e

MAKE="make"
TMP="$PWD/tmp"
PREFIX="$TMP/perl"
BUILDDIR="$TMP/build"
MODULES="Compress::Zlib Digest::MD5 Net::IP XML::Simple Crypt::SSLeay File::ShareDir File::Copy::Recursive Net::SNMP HTTP::Daemon"

PERLVERSION="5.12.1"

[ -d $TMP ] || mkdir $TMP
if [ -d $BUILDDIR ]; then
    echo "Please remove $BUILDDIR first"
    exit 0
fi

cd $TMP
if [ ! -f perl-$PERLVERSION.tar.gz ]; then
  wget -O perl-$PERLVERSION.tar.gz.part http://cpan.perl.org/src/perl-$PERLVERSION.tar.gz
  mv perl-$PERLVERSION.tar.gz.part perl-$PERLVERSION.tar.gz 
fi
wget -c http://www.openssl.org/source/openssl-0.9.8n.tar.gz
wget -c http://search.cpan.org/CPAN/authors/id/F/FL/FLORA/Net-SSLeay-1.36.tar.gz


mkdir $BUILDDIR
if [ ! -d $BUILDDIR ]; then
  echo "$BUILDDIR dir is missing"
fi

cd $BUILDDIR
gunzip < ../perl-$PERLVERSION.tar.gz | tar xvf -
cd perl-$PERLVERSION

# AIX
#./Configure -Dusethreads -Dusenm -des -Dinstallprefix=$PREFIX -Dsiteprefix=$PREFIX -Dprefix=$PREFIX
#./Configure -Dusethreads -Dcc="gcc" -des -Dinstallprefix=$PREFIX -Dsiteprefix=$PREFIX -Dprefix=$PREFIX
./Configure -Duserelocatableinc -Dusethreads -des -Dinstallprefix=$PREFIX -Dsiteprefix=$PREFIX -Dprefix=$PREFIX
$MAKE
$MAKE install


export PATH=$PREFIX/bin:$PATH

cd $BUILDDIR
gunzip < ../openssl-0.9.8n.tar.gz | tar xvf -
cd openssl-0.9.8n
./config no-shared --prefix=$TMP/openssl
make depend
make install
export OPENSSL_PREFIX=$TMP/openssl # Pour Net::SSLeay
export CRYPT_SSLEAY_DEFAULT=$TMP/openssl # Utile pour Crypt::SSLeay

# Net::SSLeay's Makefile.PL the OpenSSL directory as parmeter, so we can't
# use cpanm directly
cd $BUILDDIR
gunzip < ../Net-SSLeay-1.36.tar.gz | tar xvf -
cd Net-SSLeay-1.36
PERL_MM_USE_DEFAULT=1 perl Makefile.PL
make install

cd $TMP

wget http://xrl.us/cpanm
perl cpanm -L $MODULES

TARBALLNAME=`./perl/bin/perl -MConfig -e'print $Config{osname}."_".$Config{archname}."_".$Config{osvers}.".tar"'`
tar cf $TARBALLNAME perl
