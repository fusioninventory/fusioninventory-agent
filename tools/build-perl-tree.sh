#!/bin/sh
# A script to prepare a installation of Perl + FusionInventory Agent for
# Unix/Linux
# This in order to be able to provide an installation for system without
# Perl >= 5.8

set -e

installMod () {
    modName=$1
    distName=$2

    if [ -z $distName ]; then
        distName=`echo $modName|sed 's,::,-,g'`
    fi
    archive=`ls $FILEDIR/$distName*.tar.gz`
    $PERL_PREFIX/bin/perl $CPANM --skip-installed $archive
    $PERL_PREFIX/bin/perl -M$modName -e1
}

cleanUp () {
    rm -rf $BUILDDIR $TMP/openssl $TMP/perl $TMP/Compress::Zlib

}

buildPerl () {

    cd $TMP
    if [ ! -f $FILEDIR/perl-$PERLVERSION.tar.gz ]; then
    echo $FILEDIR/perl-$PERLVERSION.tar.gz
        echo "Please run ./download-perl-dependencies.sh first to retrieve the dependencies"
        exit
    fi

    cd $BUILDDIR
    gunzip < $FILEDIR/perl-$PERLVERSION.tar.gz | tar xvf -
    cd perl-$PERLVERSION
    
    # AIX
    #./Configure -Dusethreads -Dusenm -des -Dinstallprefix=$PERL_PREFIX -Dsiteprefix=$PERL_PREFIX -Dprefix=$PERL_PREFIX
    #./Configure -Dusethreads -Dcc="gcc" -des -Dinstallprefix=$PERL_PREFIX -Dsiteprefix=$PERL_PREFIX -Dprefix=$PERL_PREFIX
    
    ./Configure -Duserelocatableinc -Dusethreads -des -Dinstallprefix=$PERL_PREFIX -Dsiteprefix=$PERL_PREFIX -Dprefix=$PERL_PREFIX
    $MAKE
    $MAKE install
    

}

buildOpenSSL () {

    cd $TMP
    if [ ! -f $FILEDIR/openssl-0.9.8n.tar.gz ]; then
        echo "Please run ./download-perl-dependencies.sh first to retrieve"
        echo "the dependencies"
        exit
    fi

    cd $BUILDDIR
    gunzip < $FILEDIR/openssl-0.9.8n.tar.gz | tar xvf -
    cd openssl-0.9.8n
    ./config no-shared --prefix=$TMP/openssl
    make depend
    make install
    # hack for Crypt::SSLeay
    mkdir $TMP/openssl/include/openssl/openssl
    cp $TMP/openssl/include/openssl/*.h $TMP/openssl/include/openssl/openssl

}
if [ ! -d '../tools' ]; then
    echo "Please run the script in the ./tools directory"
    exit 1
fi

ROOT="$PWD/.."
MAKE="make"
TMP="$PWD/tmp"
FILEDIR="$PWD/files"
PERL_PREFIX="$TMP/perl"
BUILDDIR="$TMP/build"
MODULES="Compress::Raw::Bzip2 URI XML::NamespaceSupport HTML::Tagset Class::Inspector Digest::MD5 Net::IP XML::Simple File::ShareDir File::Copy::Recursive Net::SNMP Net::IP Proc::Daemon Proc::PID::File Compress::Raw::Zlib Archive::Extract Digest::MD5 File::Copy File::Path File::Temp Net::NBName Net::SSLeay Parallel::ForkManager"
FINALDIR=$PWD
NO_CLEANUP=0
NO_PERL_REBUILD=0
NO_OPENSSL_REBUILD=0


PERLVERSION="5.12.1"

# Clean up
if [ "$NO_CLEANUP" = "0" ]; then
    cleanUp
fi

[ -d $TMP ] || mkdir $TMP
[ -d $BUILDDIR ] || mkdir $BUILDDIR

if [ ! -d $BUILDDIR ]; then
  echo "$BUILDDIR dir is missing"
fi



if [ "$NO_PERL_REBUILD" = "0" ]; then
    buildPerl
fi

if [ "$NO_OPENSSL_REBUILD" = "0" ]; then
    buildOpenSSL
fi
export OPENSSL_PREFIX=$TMP/openssl # Pour Net::SSLeay

# Net::SSLeay's Makefile.PL the OpenSSL directory as parmeter, so we can't
# use cpanm directly
cd $BUILDDIR
gunzip < $FILEDIR/Net-SSLeay-1.36.tar.gz | tar xvf -
cd Net-SSLeay-1.36
PERL_MM_USE_DEFAULT=1 $PERL_PREFIX/bin/perl Makefile.PL
make install

cd $BUILDDIR
gunzip < $FILEDIR/Crypt-SSLeay-0.57.tar.gz | tar xvf -
cd Crypt-SSLeay-0.57
PERL_MM_USE_DEFAULT=1 $PERL_PREFIX/bin/perl Makefile.PL --default --static --lib=$TMP/openssl
make install

cd $BUILDDIR
echo $PWD
archive=`ls $TMP/App-cpanminus-*.tar.gz`
echo $archive
gunzip < $archive | tar xvf -
CPANM=$BUILDDIR/App-cpanminus-1.0004/bin/cpanm

if [ -f "/usr/include/cups/cups.h" ]; then
    echo "CUPS found, enable Net::CUPS"
    installMod "Net::CUPS"
fi

installMod "LWP" "libwww-perl"
installMod "Compress::Zlib" "IO-Compress"

# Tree dependencies not pulled by cpanm
for modName in $MODULES; do
    installMod $modName
done


cd $TMP
TARBALLNAME=` $PERL_PREFIX/bin/perl -MConfig -e'print $Config{osname}."_".$Config{archname}."_".$Config{osvers}.".tar"'`
tar cf $FINALDIR/$TARBALLNAME perl
