package Ocsinventory::Agent::Backend::OS::BSD;

use strict;

use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::Generic"];

sub check { $^O =~ /freebsd|openbsd|netbsd/ }

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
  my @kern_version = `sysctl -n kern.version`;
  chomp ($OSComment = $kern_version[1]); # second line
  $OSComment =~ s/^\s*//; # skip leading spaces

  # if there is a problem use uname -v
  chomp($OSComment=`uname -v`) unless $OSComment; 
  
  $inventory->setHardware({
      OSNAME => $OSName,
      OSCOMMENTS => $OSComment,
      OSVERSION => $OSVersion,
    });
}
1;
