#!/bin/sh


MODULES="HTML::Parser App::cpanminus URI HTML::Tagset Crypt::SSLeay
Net::SSLeay XML::SAX
XML::NamespaceSupport HTML::Tagset Class::Inspector LWP Compress::Zlib
Digest::MD5 Net::IP XML::Simple File::ShareDir File::Copy::Recursive
Net::SNMP Net::IP Proc::Daemon Proc::PID::File Compress::Zlib
Compress::Raw::Zlib Archive::Extract Digest::MD5
File::Path File::Temp Net::NBName Net::SSLeay
Parallel::ForkManager Nmap::Parser Net::CUPS Compress::Zlib
Compress::Raw::Bzip2"

[ -d "tmp" ] || mkdir tmp
cd tmp

for modName in $MODULES; do
    echo "$modName"
    echo http://cpanmetadb.appspot.com/v1.0/package/$modName
    distfile=`curl -s -L http://cpanmetadb.appspot.com/v1.0/package/$modName|grep ^distfile:|awk '{print $2}'`
    echo http://search.cpan.org/CPAN/authors/id/$distfile
    curl -L -O  http://search.cpan.org/CPAN/authors/id/$distfile
done
