package Ocsinventory::Agent::Backend::OS::BSD;

use strict;

use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::Generic"];

sub check { $^O =~ /freebsd|openbsd|netbsd|gnukfreebsd|gnuknetbsd/ }

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $OSName;
  my $OSComment;
  my $OSVersion;
  my $OSLevel;

  # Operating system informations
  chomp($OSName=`uname -s`);
  chomp($OSVersion=`uname -r`);

  # Retrieve the origin of the kernel configuration file
  my ($date, $origin, $kernconf);
  for (`sysctl -n kern.version`) {
      $date = $1 if /^\S.*\#\d+:\s*(.*)/;
      ($origin,$kernconf) = ($1,$2) if /^\s+(.+):(.+)$/;
  }
  $kernconf =~ s/\/.*\///; # remove the path
  $OSComment = $kernconf." (".$date.")\n".$origin;
  # if there is a problem use uname -v
  chomp($OSComment=`uname -v`) unless $OSComment; 
  
  $inventory->setHardware({
      OSNAME => $OSName,
      OSCOMMENTS => $OSComment,
      OSVERSION => $OSVersion,
    });
}
1;
