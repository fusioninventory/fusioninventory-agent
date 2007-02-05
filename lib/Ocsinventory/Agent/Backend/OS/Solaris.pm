package Ocsinventory::Agent::Backend::OS::Solaris;

use strict;
sub check {
  my $r;
  $r = 1 if $^O =~ /^solaris$/;
  $r;
}

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

  $inventory->setHardware({
      OSNAME => $OSName,
      OSCOMMENTS => $OSComment,
      OSVERSION => "$OSLevel $OSVersion"
    });
}


1;
