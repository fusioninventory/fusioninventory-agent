package Ocsinventory::Agent::Backend::OS::Solaris;

use strict;
use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::Generic"];

sub check {$^O =~ /^solaris$/}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};
  
  my $OSName;
  my $OSComment;
  my $OSVersion;
  my $OSLevel;
  #Operating system informations
  chomp($OSName=`uname -s`);
  chomp($OSVersion=`uname -v`);
  chomp($OSLevel=`uname -r`);
  chomp($OSComment=`uname -i`);   

#  $OSName =~ s/SunOS/Solaris/;
  $inventory->setHardware({
      OSNAME => "$OSName $OSLevel",
      OSCOMMENTS => $OSComment,
      OSVERSION => $OSVersion
    });
}


1;
