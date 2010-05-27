#!/bin/sh
# A script to prepare a installation of Perl + FusionInventory Agent for
# Unix/Linux
# This in order to be able to provide an installation for system without
# Perl >= 5.8

set -e

if [ ! -d '../tools' ]; then
    echo "Please run the script in the ./tools directory"
    exit 1
fi

ROOT="$PWD/.."
MAKE="make"
TMP="$PWD/tmp"
PREFIX="$TMP/perl"
BUILDDIR="$TMP/build"
MODULES="XML::NamespaceSupport HTML::Tagset Class::Inspector LWP Compress::Zlib Digest::MD5 Net::IP XML::Simple File::ShareDir File::Copy::Recursive Net::SNMP"
FINALDIR=$PWD

PERLVERSION="5.12.1"

# Clean up
rm -rf $BUILDDIR $TMP/openssl $TMP/perl $TMP/Compress::Zlib $TMP/App-cpanminus-1.0004

[ -d $TMP ] || mkdir $TMP

cd $TMP
if [ ! -f perl-$PERLVERSION.tar.gz ]; then
  wget -O perl-$PERLVERSION.tar.gz.part http://cpan.perl.org/src/perl-$PERLVERSION.tar.gz
  mv perl-$PERLVERSION.tar.gz.part perl-$PERLVERSION.tar.gz 
fi
wget -c http://www.openssl.org/source/openssl-0.9.8n.tar.gz
wget -c http://search.cpan.org/CPAN/authors/id/F/FL/FLORA/Net-SSLeay-1.36.tar.gz
wget -c http://search.cpan.org/CPAN/authors/id/D/DL/DLAND/Crypt-SSLeay-0.57.tar.gz
wget -c http://search.cpan.org/CPAN/authors/id/M/MI/MIYAGAWA/App-cpanminus-1.0004.tar.gz

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
# hack for Crypt::SSLeay
mkdir $TMP/openssl/include/openssl/openssl
cp $TMP/openssl/include/openssl/*.h $TMP/openssl/include/openssl/openssl
export OPENSSL_PREFIX=$TMP/openssl # Pour Net::SSLeay

# Net::SSLeay's Makefile.PL the OpenSSL directory as parmeter, so we can't
# use cpanm directly
cd $BUILDDIR
gunzip < ../Net-SSLeay-1.36.tar.gz | tar xvf -
cd Net-SSLeay-1.36
PERL_MM_USE_DEFAULT=1 perl Makefile.PL
make install

cd $BUILDDIR
gunzip < ../Crypt-SSLeay-0.57.tar.gz | tar xvf -
cd Crypt-SSLeay-0.57
PERL_MM_USE_DEFAULT=1 perl Makefile.PL --default --static --lib=$TMP/openssl
make install

cd $TMP

cd $BUILDDIR
gunzip < ../App-cpanminus-1.0004.tar.gz | tar xvf -
CPANM=$PWD/App-cpanminus-1.0004/bin/cpanm

# Tree dependencies not pulled by cpanm
for module in $MODULES; do
    perl $CPANM $module
    perl -M$module -e1
done

cd $ROOT
perl Makefile.PL
make manifest
make
make test

TARBALLNAME=`./perl/bin/perl -MConfig -e'print $Config{osname}."_".$Config{archname}."_".$Config{osvers}.".tar"'`
tar cf $FINALDIR/$TARBALLNAME perl
