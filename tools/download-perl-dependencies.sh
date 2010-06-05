#!/bin/sh

PERLVERSION="5.12.1"

# one some platforms like MacOS X wget is non standard, use curl instead and in BSD, use fetch
if [ ! -z $(which wget) ]; then
  WGET="wget -c"
  WPRINT="wget -nv -O -"
else
  if [ ! -z $(which curl) ]; then
    WGET="curl --location  -O"
    WPRINT="curl -s -L"
  else
    if [ ! -z $(which fetch) ]; then
      WGET="fetch"
      WPRINT="fetch -v -o -"
    fi
  fi
fi

MODULES="HTML::Parser App::cpanminus URI HTML::Tagset Crypt::SSLeay
Net::SSLeay XML::SAX
XML::NamespaceSupport HTML::Tagset Class::Inspector LWP Compress::Zlib
Digest::MD5 Net::IP XML::Simple File::ShareDir File::Copy::Recursive
Net::SNMP Net::IP Proc::Daemon Proc::PID::File Compress::Zlib
Compress::Raw::Zlib Archive::Extract Digest::MD5
File::Path File::Temp Net::NBName Net::SSLeay
Parallel::ForkManager Nmap::Parser Net::CUPS Compress::Zlib
Compress::Raw::Bzip2 Nmap::Scanner"

[ -d "tmp" ] || mkdir tmp
cd tmp


$WGET http://cpan.perl.org/src/perl-$PERLVERSION.tar.gz
$WGET http://www.openssl.org/source/openssl-0.9.8n.tar.gz

for modName in $MODULES; do
    echo "$modName"
    echo http://cpanmetadb.appspot.com/v1.0/package/$modName
    distfile=`$WPRINT http://cpanmetadb.appspot.com/v1.0/package/$modName|grep ^distfile:|awk '{print $2}'`
    echo http://search.cpan.org/CPAN/authors/id/$distfile
    $WGET  http://search.cpan.org/CPAN/authors/id/$distfile
done
